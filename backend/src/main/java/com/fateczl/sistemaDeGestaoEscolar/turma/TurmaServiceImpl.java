package com.fateczl.sistemaDeGestaoEscolar.turma;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.data.domain.Sort;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.fateczl.sistemaDeGestaoEscolar.academico.StatusMatriz;
import com.fateczl.sistemaDeGestaoEscolar.academico.matriz.MatrizCurricular;
import com.fateczl.sistemaDeGestaoEscolar.academico.matriz.MatrizCurricularRepository;
import com.fateczl.sistemaDeGestaoEscolar.config.exception.BusinessException;
import com.fateczl.sistemaDeGestaoEscolar.config.exception.ResourceNotFoundException;
import com.fateczl.sistemaDeGestaoEscolar.usuario.Role;
import com.fateczl.sistemaDeGestaoEscolar.usuario.Usuario;
import com.fateczl.sistemaDeGestaoEscolar.usuario.UsuarioRepository;
import com.fateczl.sistemaDeGestaoEscolar.usuario.aluno.Aluno;
import com.fateczl.sistemaDeGestaoEscolar.usuario.aluno.AlunoMapper;
import com.fateczl.sistemaDeGestaoEscolar.usuario.aluno.AlunoRepository;
import com.fateczl.sistemaDeGestaoEscolar.usuario.aluno.AlunoResponseDTO;
import com.fateczl.sistemaDeGestaoEscolar.usuario.funcionario.Funcionario;
import com.fateczl.sistemaDeGestaoEscolar.usuario.funcionario.FuncionarioRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class TurmaServiceImpl implements TurmaService {

    private final TurmaRepository turmaRepository;

    private final AlunoRepository alunoRepository; // Necessário para associações

    private final AlunoMapper alunoMapper;
    
    private final FuncionarioRepository funcionarioRepository;

    private final MatrizCurricularRepository matrizRepository;

    // --- CRUD Básico (Padrão Disciplina) ---

    @Override
    public List<Turma> findAll() {
        String emailLogado = SecurityContextHolder.getContext().getAuthentication().getName();
        Funcionario funcionarioLogado = funcionarioRepository.findByEmail(emailLogado).orElse(null);

        List<Turma> todasTurmas = turmaRepository.findAll(Sort.by("ano", "serie", "turno").ascending());

        if (funcionarioLogado != null && funcionarioLogado.getRole() != Role.ADMIN && funcionarioLogado.getEscola() != null) {
            Long escolaId = funcionarioLogado.getEscola().getId();
            return todasTurmas.stream().filter(turma -> {
                if (turma.getAlunos() != null && !turma.getAlunos().isEmpty()) {
                    // Deduz a escola da turma baseada no registro do primeiro aluno
                    return turma.getAlunos().get(0).getEscola().getId().equals(escolaId);
                }
                return false; 
            }).collect(Collectors.toList());
        }

        return todasTurmas;
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

    @Transactional // Importante para garantir que a conexão com o banco persista durante a chamada
    public String matricularAlunoViaProcedure(Long alunoId, Long turmaId) {
        // Chama o repositório
        return turmaRepository.matricularAluno(alunoId, turmaId);
    }

    public List<Turma> findTurmasByProfessor(Long professorId) {
        int anoAtual = LocalDate.now().getYear();
        
        List<MatrizCurricular> matrizes = matrizRepository.findAll().stream()
                .filter(m -> m.getProfessor() != null && m.getProfessor().getId().equals(professorId))
                .filter(m -> m.getAno() == anoAtual)
                .filter(m -> m.getStatus() == StatusMatriz.ATIVA)
                .collect(Collectors.toList());

        return matrizes.stream()
                .map(MatrizCurricular::getTurma)
                .distinct()
                .collect(Collectors.toList());
    }

}
