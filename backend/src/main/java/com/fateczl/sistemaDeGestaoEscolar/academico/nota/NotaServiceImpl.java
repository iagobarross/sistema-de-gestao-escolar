package com.fateczl.sistemaDeGestaoEscolar.academico.nota;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.fateczl.sistemaDeGestaoEscolar.academico.aula.AulaRepository;
import com.fateczl.sistemaDeGestaoEscolar.academico.avaliacao.AvaliacaoRepository;
import com.fateczl.sistemaDeGestaoEscolar.academico.frequencia.FrequenciaRepository;
import com.fateczl.sistemaDeGestaoEscolar.academico.matriz.MatrizCurricular;
import com.fateczl.sistemaDeGestaoEscolar.academico.matriz.MatrizCurricularRepository;
import com.fateczl.sistemaDeGestaoEscolar.config.exception.BusinessException;
import com.fateczl.sistemaDeGestaoEscolar.config.exception.ResourceNotFoundException;
import com.fateczl.sistemaDeGestaoEscolar.usuario.aluno.AlunoRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class NotaServiceImpl implements NotaService {

    private final NotaRepository notaRepository;
    private final AvaliacaoRepository avaliacaoRepository;
    private final AlunoRepository alunoRepository;
    private final MatrizCurricularRepository matrizRepository;
    private final FrequenciaRepository frequenciaRepository;
    private final AulaRepository aulaRepository;

    @Override
    @Transactional
    public List<Nota> lancarNotas(LancarNotasRequestDTO dto) {
        var avaliacao = avaliacaoRepository.findById(dto.getAvaliacaoId())
                .orElseThrow(() -> new ResourceNotFoundException("Avaliação não encontrada"));

        List<Nota> notas = dto.getNotas().stream()
                .filter(item -> item.getValor() != null)
                .map(item -> {
                    var aluno = alunoRepository.findById(item.getAlunoId())
                            .orElseThrow(
                                    () -> new ResourceNotFoundException("Aluno não encontrado: " + item.getAlunoId()));

                    Nota nota = notaRepository
                            .findByAvaliacaoIdAndAlunoId(dto.getAvaliacaoId(), item.getAlunoId())
                            .orElse(new Nota());

                    nota.setAvaliacao(avaliacao);
                    nota.setAluno(aluno);
                    nota.setValor(item.getValor());
                    nota.setObservacao(item.getObservacao());
                    nota.setLancadaEm(java.time.LocalDateTime.now());
                    return nota;
                }).collect(java.util.stream.Collectors.toList());
        return notaRepository.saveAll(notas);
    }

    @Override
    @Transactional
    public Nota corrigirNota(Long notaId, double novoValor, String observacao) {
        Nota nota = notaRepository.findById(notaId)
                .orElseThrow(() -> new ResourceNotFoundException("Nota não encontrada com o ID: " + notaId));

        double max = nota.getAvaliacao().getNotaMaxima();
        if (novoValor < 0 || novoValor > max)
            throw new BusinessException("Valor inválido. Deve estar entre 0 e " + max);

        nota.setValor(novoValor);
        nota.setObservacao(observacao);
        nota.setLancadaEm(java.time.LocalDateTime.now());
        return notaRepository.save(nota);
    }

    @Override
    public List<Nota> findByAvaliacao(Long avaliacaoId) {
        return notaRepository.findByAvaliacaoId(avaliacaoId);
    }

    @Override
    public List<BoletimDisciplinaDTO> gerarBoletim(Long alunoId, int ano) {
        var aluno = alunoRepository.findById(alunoId)
                .orElseThrow(() -> new ResourceNotFoundException("Aluno não encontrado"));

        List<Long> turmaIds = aluno.getTurmas().stream()
                .map(t -> t.getId())
                .collect(Collectors.toList());

        List<BoletimDisciplinaDTO> boletim = new ArrayList<>();

        for (Long turmaId : turmaIds) {
            List<MatrizCurricular> matrizes = matrizRepository
                    .findByTurmaIdAndAnoOrderByDisciplinaNomeAsc(turmaId, ano);

            for (MatrizCurricular matriz : matrizes) {
                BoletimDisciplinaDTO item = new BoletimDisciplinaDTO();
                item.setDisciplinaId(matriz.getDisciplina().getId());
                item.setNomeDisciplina(matriz.getDisciplina().getNome());
                item.setNomeProfessor(matriz.getProfessor().getNome());
                item.setNotaMinima(matriz.getDisciplina().getNotaMinima());

                item.setMediaBimestre1(notaRepository
                        .calcularMediaBimestre(matriz.getId(), alunoId, 1));
                item.setMediaBimestre2(notaRepository
                        .calcularMediaBimestre(matriz.getId(), alunoId, 2));
                item.setMediaBimestre3(notaRepository
                        .calcularMediaBimestre(matriz.getId(), alunoId, 3));
                item.setMediaBimestre4(notaRepository
                        .calcularMediaBimestre(matriz.getId(), alunoId, 4));
                item.setMediaFinal(notaRepository
                        .calcularMediaGeral(matriz.getId(), alunoId));

                long totalAulas = aulaRepository
                        .countByMatrizCurricularId(matriz.getId());
                long faltas = frequenciaRepository.contarFaltas(matriz.getId(), alunoId);
                Double pct = frequenciaRepository
                        .calcularPercentualPresenca(matriz.getId(), alunoId);

                item.setTotalAulas(totalAulas);
                item.setFaltas(faltas);
                item.setPercentualPresenca(pct != null ? pct * 100 : null);

                double notaMin = matriz.getDisciplina().getNotaMinima();
                Double mediaFinal = item.getMediaFinal();
                if (mediaFinal == null) {
                    item.setSituacao("SEM DADOS");
                } else if (mediaFinal >= notaMin && (pct == null || pct >= 0.75)) {
                    item.setSituacao("APROVADO");
                } else if (mediaFinal >= notaMin - 1.0) {
                    item.setSituacao("RECUPERAÇÃO");
                } else {
                    item.setSituacao("REPROVADO");
                }

                boletim.add(item);

            }
        }

        return boletim;
    }

}
