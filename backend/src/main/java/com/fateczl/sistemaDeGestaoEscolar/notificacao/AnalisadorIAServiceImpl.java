package com.fateczl.sistemaDeGestaoEscolar.notificacao;

import com.fateczl.sistemaDeGestaoEscolar.academico.aula.AulaRepository;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.http.MediaType;

import com.fateczl.sistemaDeGestaoEscolar.academico.nota.BoletimDisciplinaDTO;
import com.fateczl.sistemaDeGestaoEscolar.usuario.aluno.Aluno;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@RequiredArgsConstructor
@Slf4j
public class AnalisadorIAServiceImpl implements AnalisadorIAService {
    
    private final AulaRepository aulaRepository;

    @Value("${gemini.api.key}")
    private String apiKey;

    @Value("${gemini.model}")
    private String modelo;

    @Value("${gemini.api.url}")
    private String apiUrl;

    private final RestTemplate restTemplate = new RestTemplate();
    
    @Override
    public String gerarNotificacao(Aluno aluno, List<BoletimDisciplinaDTO> boletim, List<String> problemas,
            String nomeTurma) {
        String prompt = montarPrompt(aluno, boletim, problemas, nomeTurma);

        try{
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            headers.set("x-goog-api-key", apiKey);
            
            Map<String, Object> part = new HashMap<>();
            part.put("text", prompt);

            Map<String, Object> content = new HashMap<>();
            content.put("parts", List.of(part));

            Map<String, Object> body = new HashMap<>();
            body.put("content", List.of(content));

            Map<String, Object> generationConfig = new HashMap<>();
            generationConfig.put("maxOutputTokens", 600);
            body.put("generationConfig", generationConfig);

            HttpEntity<Map<String,Object>> requisicao = new HttpEntity<>(body, headers);

            String urlCompleta = apiUrl + modelo + ":generateContent";

            ResponseEntity<Map> resposta = restTemplate.postForEntity(urlCompleta, requisicao, Map.class);

            if(resposta.getStatusCode() == HttpStatus.OK && resposta.getBody() != null){
                List<Map<String, Object>> candidates = (List<Map<String, Object>>) resposta.getBody().get("candidates");
                if (candidates != null && !candidates.isEmpty()){
                    Map<String,Object> responseContent = (Map<String, Object>) candidates.get(0).get("content");
                    List<Map<String, Object>> parts = (List<Map<String, Object>>) responseContent.get("parts");
                    if (parts != null && !parts.isEmpty()){
                        return (String) parts.get(0).get("text");
                    }
                }
            }

        } catch (Exception e) {
            log.error("Erro ao chamar a API do Gemini para o aluno {}: {}", aluno.getNome(), e.getMessage());
            return gerarTextoFallback(aluno, problemas);
        }
        
        return gerarTextoFallback(aluno, problemas);
        
    }

    private String montarPrompt(Aluno aluno,
                                List<BoletimDisciplinaDTO> boletim,
                                List<String> problemas,
                                String nomeTurma) {

        String resumoDisciplinas = boletim.stream()
                .filter(d -> "REPROVADO".equals(d.getSituacao()) || "RECUPERACAO".equals(d.getSituacao()))
                .map(d -> String.format("- %s: média %.1f (mín. %.1f) — %d faltas",
                        d.getNomeDisciplina(),
                        d.getMediaFinal() != null ? d.getMediaFinal() : 0.0,
                        d.getNotaMinima(),
                        d.getFaltas()))
                .collect(Collectors.joining("\n"));

        String resumoFrequencia = boletim.stream()
                .filter(d -> d.getPercentualPresenca() != null && d.getPercentualPresenca() < 75.0)
                .map(d -> String.format("- %s: %.0f%% de presença (%d faltas de %d aulas)",
                        d.getNomeDisciplina(),
                        d.getPercentualPresenca(),
                        d.getFaltas(),
                        d.getTotalAulas()))
                .collect(Collectors.joining("\n"));

        return """
                Você é um assistente pedagógico especializado em comunicação escolar.
                Analise os dados abaixo de um aluno e escreva uma notificação profissional
                e empática para o coordenador pedagógico.
                                
                DADOS DO ALUNO:
                Nome: %s
                Turma: %s
                                
                PROBLEMAS DE DESEMPENHO (situação abaixo do esperado):
                %s
                                
                PROBLEMAS DE FREQUÊNCIA (abaixo de 75%%):
                %s
                                
                INSTRUÇÕES:
                - Escreva em português brasileiro, tom profissional e acolhedor
                - Máximo de 180 palavras
                - Destaque os dados numéricos específicos
                - Sugira 2 ações concretas que o coordenador pode tomar
                - NÃO use saudações ou despedidas — apenas o conteúdo da notificação
                - Comece diretamente com a situação do aluno
                """.formatted(
                aluno.getNome(),
                nomeTurma,
                resumoDisciplinas.isEmpty() ? "Nenhum" : resumoDisciplinas,
                resumoFrequencia.isEmpty() ? "Nenhum" : resumoFrequencia
        );
    }

     private String gerarTextoFallback(Aluno aluno, List<String> problemas) {
        return String.format(
                "O aluno %s apresenta os seguintes pontos de atenção que requerem intervenção: %s. " +
                "Recomenda-se agendar uma reunião com o responsável e verificar a situação " +
                "junto ao professor da disciplina em questão.",
                aluno.getNome(),
                String.join("; ", problemas)
        );
    }
    
}
