package com.fateczl.sistemaDeGestaoEscolar.usuario.aluno;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import com.fateczl.sistemaDeGestaoEscolar.config.exception.BusinessException;
import com.fateczl.sistemaDeGestaoEscolar.config.exception.ResourceNotFoundException;
import com.fateczl.sistemaDeGestaoEscolar.escola.Escola;
import com.fateczl.sistemaDeGestaoEscolar.escola.EscolaRepository;
import com.fateczl.sistemaDeGestaoEscolar.usuario.responsavel.Responsavel;
import com.fateczl.sistemaDeGestaoEscolar.usuario.responsavel.ResponsavelRepository;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AlunoServiceImpl implements AlunoService{
    @Autowired
    private AlunoRepository alunoRepository;

    @Autowired
    private AlunoMapper alunoMapper;

    @Autowired
    private EscolaRepository escolaRepository; // Injeção necessária

    @Autowired
    private ResponsavelRepository responsavelRepository; // Injeção necessária

    @Autowired
    private PasswordEncoder passwordEncoder; // Injeção necessária

    @Override
    public Page<Aluno> findAll(Pageable pageable, String nome, String matricula, Long escolaId){
        return alunoRepository.findAll(AlunoSpecification.comFiltros(nome, matricula, escolaId), pageable);
    }

    @Override
    public Aluno findById(Long id) {
        return alunoRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Aluno não encontrado com o ID: " + id));
    }

    @Override
    public Aluno create(Aluno alunoMapeado, Long escolaId, Long responsavelId) {
        // 1. Validar duplicidade de Email e Matrícula
        if (alunoRepository.existsByEmail(alunoMapeado.getEmail())) {
            throw new BusinessException("Email já cadastrado.");
        }
        if (alunoRepository.existsByMatricula(alunoMapeado.getMatricula())) {
            throw new BusinessException("Matrícula já cadastrada.");
        }
        if (alunoMapeado.getSenha() == null || alunoMapeado.getSenha().isEmpty() || alunoMapeado.getSenha().length() < 6 ) {
        	throw new BusinessException("A senha é obrigatória e deve ter no mínimo 6 caracteres.");
        }

        // 2. Buscar entidades relacionadas
        Escola escola = escolaRepository.findById(escolaId)
                .orElseThrow(() -> new ResourceNotFoundException("Escola não encontrada com o ID: " + escolaId));

        Responsavel responsavel = responsavelRepository.findById(responsavelId)
                .orElseThrow(
                        () -> new ResourceNotFoundException("Responsável não encontrado com o ID: " + responsavelId));

        // 3. Associar entidades e criptografar senha
        alunoMapeado.setEscola(escola);
        alunoMapeado.setResponsavel(responsavel);
        alunoMapeado.setSenha(passwordEncoder.encode(alunoMapeado.getSenha()));

        // 4. Salvar
        return alunoRepository.save(alunoMapeado);
    }

    @Override
    public Aluno update(Long id, Aluno dadosAtualizacao, Long escolaId, Long responsavelId) {
        // 1. Buscar Aluno existente
        Aluno alunoDB = this.findById(id);

        // 2. Validar duplicidade em outros registros
        alunoRepository.findByEmailAndIdNot(dadosAtualizacao.getEmail(), id)
                .ifPresent(a -> {
                    throw new BusinessException("Email já pertence a outro aluno.");
                });

        alunoRepository.findByMatriculaAndIdNot(dadosAtualizacao.getMatricula(), id)
                .ifPresent(a -> {
                    throw new BusinessException("Matrícula já pertence a outro aluno.");
                });

        // 3. Buscar entidades relacionadas
        Escola escola = escolaRepository.findById(escolaId)
                .orElseThrow(() -> new ResourceNotFoundException("Escola não encontrada com o ID: " + escolaId));

        Responsavel responsavel = responsavelRepository.findById(responsavelId)
                .orElseThrow(
                        () -> new ResourceNotFoundException("Responsável não encontrado com o ID: " + responsavelId));

        // 4. Atualizar dados (Merge)
        alunoDB.setNome(dadosAtualizacao.getNome());
        alunoDB.setEmail(dadosAtualizacao.getEmail());
        alunoDB.setMatricula(dadosAtualizacao.getMatricula());
        alunoDB.setDataNascimento(dadosAtualizacao.getDataNascimento());
        alunoDB.setEscola(escola);
        alunoDB.setResponsavel(responsavel);

        // 5. Atualizar senha (somente se uma nova senha foi fornecida)
        if (dadosAtualizacao.getSenha() != null && !dadosAtualizacao.getSenha().isEmpty()) {
            alunoDB.setSenha(passwordEncoder.encode(dadosAtualizacao.getSenha()));
        }

        return alunoRepository.save(alunoDB);
    }

    @Override
    public void deleteById(Long id) {
        if (!alunoRepository.existsById(id)) {
            throw new ResourceNotFoundException("Aluno não encontrado com o ID: " + id);
        }
        try {
            alunoRepository.deleteById(id);
        } catch (DataIntegrityViolationException e) {
            throw new BusinessException(
                    "Não é possível deletar o aluno. Verifique se ele possui notas, turmas ou frequências associadas.");
        }
    }
}
