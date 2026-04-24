package com.fateczl.sistemaDeGestaoEscolar.notificacao;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.fateczl.sistemaDeGestaoEscolar.academico.nota.BoletimDisciplinaDTO;
import com.fateczl.sistemaDeGestaoEscolar.academico.nota.NotaService;
import com.fateczl.sistemaDeGestaoEscolar.comunicado.Comunicado;
import com.fateczl.sistemaDeGestaoEscolar.comunicado.ComunicadoRepository;
import com.fateczl.sistemaDeGestaoEscolar.config.exception.ResourceNotFoundException;
import com.fateczl.sistemaDeGestaoEscolar.usuario.aluno.Aluno;
import com.fateczl.sistemaDeGestaoEscolar.usuario.aluno.AlunoRepository;
import com.fateczl.sistemaDeGestaoEscolar.usuario.funcionario.Funcionario;
import com.fateczl.sistemaDeGestaoEscolar.usuario.funcionario.FuncionarioRepository;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@RequiredArgsConstructor
@Slf4j
public class NotificacaoServiceImpl implements NotificacaoService {

    private final NotificacaoRepository notificacaoRepository;
    private final AlunoRepository alunoRepository;
    private final FuncionarioRepository funcionarioRepository;
    private final ComunicadoRepository comunicadoRepository;
    private final NotaService notaService;
    private final AnalisadorIAService analisadorIA;

    @Override
    @Transactional
    public int analisarEGerarNotificacoes(Long escolaId) {
        int anoAtual = LocalDateTime.now().getYear();
        int mesAtual = LocalDateTime.now().getMonthValue();

        Funcionario coordenador = funcionarioRepository.findAll().stream()
                .filter(f -> f.getRole().name().equals("COORDENADOR")
                        && f.getEscola() != null
                        && f.getEscola().getId().equals(escolaId))
                .findFirst()
                .orElseThrow(
                        () -> new ResourceNotFoundException("Nenhum coordenador encontrado para a escola " + escolaId));

        List<Aluno> alunos = alunoRepository.findAll(
                (root, query, builder) -> builder.equal(root.get("escola").get("id"), escolaId));

        int notificacoesGeradas = 0;

        for (Aluno aluno : alunos) {
            if (notificacaoRepository.existsByAlunoIdAndAnoReferenciaAndMesReferencia(aluno.getId(), anoAtual,
                    mesAtual)) {
                log.debug("Aluno {} já analisado em {}/{}", aluno.getNome(), mesAtual, anoAtual);
                continue;
            }

            List<BoletimDisciplinaDTO> boletim;
            try {
                boletim = notaService.gerarBoletim(aluno.getId(), anoAtual);
            } catch (Exception e) {
                log.warn("Erro ao gerar boletim para aluno {}: {}", aluno.getNome(), e.getMessage());
                continue;
            }

            if (boletim.isEmpty())
                continue;

            List<String> problemas = new ArrayList<>();
            boolean temBaixoDesempenho = false;
            boolean temBaixaFrequencia = false;

            for (BoletimDisciplinaDTO item : boletim) {
                if ("REPROVADO".equals(item.getSituacao()) || "RECUPERACAO".equals(item.getSituacao())) {
                    double media = item.getMediaFinal() != null ? item.getMediaFinal() : 0.0;
                    problemas.add(String.format("Nota %.1f em %s (mínimo %.1f)",
                            media, item.getNomeDisciplina(), item.getNotaMinima()));
                    temBaixoDesempenho = true;
                }
                if (item.getPercentualPresenca() != null && item.getPercentualPresenca() < 75.0) {
                    problemas.add(String.format("Frequência %.0f%% em %s",
                            item.getPercentualPresenca(), item.getNomeDisciplina()));
                    temBaixaFrequencia = true;
                }
            }

            if (problemas.isEmpty())
                continue;

            TipoNotificacao tipo;
            if (temBaixoDesempenho && temBaixaFrequencia) {
                tipo = TipoNotificacao.DESEMPENHO_E_FREQUENCIA;
            } else if (temBaixoDesempenho) {
                tipo = TipoNotificacao.BAIXO_DESEMPENHO;
            } else {
                tipo = TipoNotificacao.BAIXA_FREQUENCIA;
            }

            String nomeTurma = aluno.getTurmas() != null && !aluno.getTurmas().isEmpty()
                    ? aluno.getTurmas().get(0).getSerie() + " — " + aluno.getTurmas().get(0).getTurno()
                    : "Turma não informada";

            String resumo = problemas.stream().limit(3).collect(Collectors.joining(" | "));

            log.info("Gerando notificação por IA para o aluno: {}", aluno.getNome());
            String conteudoIA = analisadorIA.gerarNotificacao(aluno, boletim, problemas, nomeTurma);

            Notificacao notificacao = new Notificacao();
            notificacao.setAluno(aluno);
            notificacao.setCoordenador(coordenador);
            notificacao.setConteudoIA(conteudoIA);
            notificacao.setResumo(resumo);
            notificacao.setTipo(tipo);
            notificacao.setStatus(StatusNotificacao.PENDENTE);
            notificacao.setCriadaEm(LocalDateTime.now());
            notificacao.setAnoReferencia(anoAtual);
            notificacao.setMesReferencia(mesAtual);

            notificacaoRepository.save(notificacao);
            notificacoesGeradas++;

        }

        log.info("Análise concluída para escola {}: {} notificações geradas", escolaId, notificacoesGeradas);
        return notificacoesGeradas;
    }

    @Override
    public List<Notificacao> findByCoordenador(Long coordenadorId) {
        return notificacaoRepository.findByCoordenadorIdOrderByCriadaEmDesc(coordenadorId);
    }

    @Override
    public long contarPendentes(Long coordenadorId) {
        return notificacaoRepository.countByCoordenadorIdAndStatus(
                coordenadorId, StatusNotificacao.PENDENTE);
    }

    @Override
    public Notificacao marcarComoLida(Long notificacaoId) {
        Notificacao n = buscarOuLancarErro(notificacaoId);
        if (n.getStatus() == StatusNotificacao.PENDENTE) {
            n.setStatus(StatusNotificacao.LIDA);
            notificacaoRepository.save(n);
        }
        return n;
    }

    @Override
    @Transactional
    public Notificacao encaminharAoResponsavel(Long notificacaoId) {
        Notificacao notificacao = buscarOuLancarErro(notificacaoId);

        Aluno aluno = notificacao.getAluno();

        if (aluno.getResponsavel() == null) {
            throw new ResourceNotFoundException(
                    "Aluno " + aluno.getNome() + " não possui responsável cadastrado.");
        }

        // Cria o Comunicado que o responsável verá no app
        Comunicado comunicado = new Comunicado();
        comunicado.setTitulo("Aviso sobre desempenho de " + aluno.getNome());
        comunicado.setCorpo(notificacao.getConteudoIA());
        comunicado.setAluno(aluno);
        comunicado.setResponsavel(aluno.getResponsavel());
        comunicado.setAutor(notificacao.getCoordenador());
        comunicado.setLido(false);
        comunicado.setCriadoEm(LocalDateTime.now());
        comunicadoRepository.save(comunicado);

        // Atualiza o status da notificação
        notificacao.setStatus(StatusNotificacao.ENCAMINHADA);
        notificacao.setEncaminhadaEm(LocalDateTime.now());
        return notificacaoRepository.save(notificacao);
    }

    private Notificacao buscarOuLancarErro(Long id) {
        return notificacaoRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Notificação não encontrada com o ID: " + id));
    }

}
