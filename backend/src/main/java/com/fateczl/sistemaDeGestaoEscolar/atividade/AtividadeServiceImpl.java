package com.fateczl.sistemaDeGestaoEscolar.atividade;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.fateczl.sistemaDeGestaoEscolar.academico.matriz.MatrizCurricularRepository;
import com.fateczl.sistemaDeGestaoEscolar.config.exception.ResourceNotFoundException;
import com.fateczl.sistemaDeGestaoEscolar.usuario.aluno.AlunoRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class AtividadeServiceImpl implements AtividadeService{

    private final AtividadeRepository atividadeRepository;
    private final AtividadeEntregaRepository entregaRepository;
    private final MatrizCurricularRepository matrizRepository;
    private final AlunoRepository alunoRepository;

    @Override
    @Transactional
    public Atividade criar(AtividadeRequestDTO dto) {
        var matriz = matrizRepository.findById(dto.getMatrizCurricularId())
            .orElseThrow(() -> new ResourceNotFoundException("Matriz não encontrada"));
        Atividade a = new Atividade();
        a.setMatrizCurricular(matriz);
        a.setTitulo(dto.getTitulo());
        a.setDescricao(dto.getDescricao());
        a.setDataEntrega(dto.getDataEntrega());
        a.setCriadaEm(LocalDateTime.now());
        return atividadeRepository.save(a);
    }

    @Override
    public List<Atividade> findByMatriz(Long matrizId) {
        return atividadeRepository.findByMatrizCurricularIdOrderByDataEntregaAsc(matrizId);
    }

    @Override
    public List<Atividade> findByTurma(Long turmaId) {
        return atividadeRepository.findByTurmaId(turmaId);
    }

    @Override
    public List<Atividade> findByProfessor(Long professorId) {
        return atividadeRepository.findByProfessorId(professorId);
    }

    @Override
    public void deletar(Long id) {
        if (!atividadeRepository.existsById(id))
            throw new ResourceNotFoundException("Atividade não encontrada");
        atividadeRepository.deleteById(id);
    }

    @Override
    @Transactional
    public AtividadeEntrega entregar(Long alunoId, AtividadeEntregaRequestDTO dto) {
        var atividade = atividadeRepository.findById(dto.getAtividadeId())
            .orElseThrow(() -> new ResourceNotFoundException("Atividade não encontrada"));
        var aluno = alunoRepository.findById(alunoId)
            .orElseThrow(() -> new ResourceNotFoundException("Aluno não encontrado"));

        AtividadeEntrega entrega = entregaRepository
            .findByAtividadeIdAndAlunoId(dto.getAtividadeId(), alunoId)
            .orElse(new AtividadeEntrega());

        entrega.setAtividade(atividade);
        entrega.setAluno(aluno);
        entrega.setConteudo(dto.getConteudo());
        entrega.setEntregueEm(LocalDateTime.now());
        entrega.setStatus(LocalDate.now().isAfter(atividade.getDataEntrega())
            ? StatusEntrega.ATRASADA : StatusEntrega.ENTREGUE);
        return entregaRepository.save(entrega);
    }

    @Override
    public List<AtividadeEntrega> findEntregasByAtividade(Long atividadeId) {
        return entregaRepository.findByAtividadeId(atividadeId);
    }

    @Override
    public List<AtividadeEntrega> findEntregasByAluno(Long alunoId) {
        return entregaRepository.findByAlunoId(alunoId);
    }
    
}
