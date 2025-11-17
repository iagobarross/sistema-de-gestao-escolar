package com.fateczl.sistemaDeGestaoEscolar.turma;

import java.util.List;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.fateczl.sistemaDeGestaoEscolar.config.exception.BusinessException;
import com.fateczl.sistemaDeGestaoEscolar.config.exception.ResourceNotFoundException;
import com.fateczl.sistemaDeGestaoEscolar.usuario.aluno.Aluno;
import com.fateczl.sistemaDeGestaoEscolar.usuario.aluno.AlunoMapper;
import com.fateczl.sistemaDeGestaoEscolar.usuario.aluno.AlunoRepository;
import com.fateczl.sistemaDeGestaoEscolar.usuario.aluno.AlunoResponseDTO;

@Service
public class TurmaServiceImpl implements TurmaService{
    @Autowired
    private TurmaRepository turmaRepository;

    @Autowired
    private AlunoRepository alunoRepository; // Necessário para associações
    
    @Autowired
    private AlunoMapper alunoMapper;

    // --- CRUD Básico (Padrão Disciplina) ---

    @Override
    public List<Turma> findAll() {
        return turmaRepository.findAll(Sort.by("ano", "serie", "turno").ascending());
    }

    @Override
    public Turma findById(Long id) {
        return turmaRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Turma não encontrada com o ID: " + id));
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<AlunoResponseDTO> findAlunosByTurmaId(Long turmaId) {
        Turma turma = this.findById(turmaId);
        

        return turma.getAlunos().stream()
                .map(alunoMapper::toResponseDTO) // O mapeamento ocorre aqui
                .collect(Collectors.toList());
    }

    @Override
    public Turma create(Turma turma) {
        if (turmaRepository.existsByAnoAndSerieAndTurno(turma.getAno(), turma.getSerie(), turma.getTurno()))
            throw new BusinessException("Esta turma (Ano, Série, Turno) já está cadastrada.");
        return turmaRepository.save(turma);
    }

    @Override
    public Turma update(Long id, Turma dadosAtualizacao) {
        Turma turmaDB = this.findById(id);

        turmaRepository.findByAnoAndSerieAndTurnoAndIdNot(
                dadosAtualizacao.getAno(), dadosAtualizacao.getSerie(), dadosAtualizacao.getTurno(), id)
                .ifPresent(t -> {
                    throw new BusinessException("Esta turma (Ano, Série, Turno) já pertence a outro registro.");
                });

        turmaDB.setAno(dadosAtualizacao.getAno());
        turmaDB.setSerie(dadosAtualizacao.getSerie());
        turmaDB.setTurno(dadosAtualizacao.getTurno());
        return turmaRepository.save(turmaDB);
    }

    @Override
    public void deleteById(Long id) {
        if (!turmaRepository.existsById(id)) {
            throw new ResourceNotFoundException("Turma não encontrada com o ID: " + id);
        }
        try {
            turmaRepository.deleteById(id);
        } catch (DataIntegrityViolationException e) {
            // Esta exceção será lançada se houver alunos (turma_alunos) ou
            // matrizes/diarios/horarios associados a esta turma.
            throw new BusinessException(
                    "Não é possível deletar a turma. Verifique se ela possui alunos ou disciplinas associadas.");
        }
    }

    // --- Gerenciamento de Associações (Lógica de Negócio) ---

    @Override
    @Transactional
    public void adicionarAluno(Long turmaId, Long alunoId) {
        Turma turma = this.findById(turmaId);
        Aluno aluno = alunoRepository.findById(alunoId)
                .orElseThrow(() -> new ResourceNotFoundException("Aluno não encontrado com o ID: " + alunoId));

        if (turma.getAlunos().contains(aluno)) {
            throw new BusinessException("Aluno já está matriculado nesta turma.");
        }
        turma.getAlunos().add(aluno);
        turmaRepository.save(turma); // Salva o dono do relacionamento (Turma)
    }

    @Override
    @Transactional
    public void removerAluno(Long turmaId, Long alunoId) {
        Turma turma = this.findById(turmaId);
        Aluno aluno = alunoRepository.findById(alunoId)
                .orElseThrow(() -> new ResourceNotFoundException("Aluno não encontrado com o ID: " + alunoId));

        if (!turma.getAlunos().contains(aluno)) {
            throw new BusinessException("Aluno não pertence a esta turma.");
        }
        turma.getAlunos().remove(aluno);
        turmaRepository.save(turma);
    }    
    
}
