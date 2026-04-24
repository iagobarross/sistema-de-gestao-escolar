package com.fateczl.sistemaDeGestaoEscolar.notificacao;

import com.fateczl.sistemaDeGestaoEscolar.escola.EscolaRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
@Slf4j
public class AgendadorNotificacoes {

    private final NotificacaoService notificacaoService;
    private final EscolaRepository escolaRepository;

    /**
     * Roda toda segunda-feira às 7h da manhã.
     * Analisa todos os alunos de todas as escolas e gera notificações
     * para os coordenadores sobre casos de baixo desempenho ou frequência.
     *
     * Para testar manualmente, troque o cron por:
     * "0 * * * * *" (executa a cada minuto)
     * "0 0 7 * * MON" (executa a cada segunda-feira às 7h da manhã)
     */
    @Scheduled(cron = "0 * * * * *")
    public void analisarTodasAsEscolas() {
        log.info("=== Iniciando análise semanal de desempenho e frequência ===");

        escolaRepository.findAll().forEach(escola -> {
            try {
                log.info("Analisando escola: {}", escola.getNome());
                int geradas = notificacaoService.analisarEGerarNotificacoes(escola.getId());
                log.info("Escola {}: {} notificações geradas", escola.getNome(), geradas);
            } catch (Exception e) {
                log.error("Erro ao analisar escola {}: {}", escola.getNome(), e.getMessage());
            }
        });

        log.info("=== Análise semanal concluída ===");
    }
}