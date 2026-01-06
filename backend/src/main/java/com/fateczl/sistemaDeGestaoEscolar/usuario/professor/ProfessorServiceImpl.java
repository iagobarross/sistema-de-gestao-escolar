package com.fateczl.sistemaDeGestaoEscolar.usuario.professor;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Sort;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import com.fateczl.sistemaDeGestaoEscolar.config.exception.BusinessException;
import com.fateczl.sistemaDeGestaoEscolar.config.exception.ResourceNotFoundException;
import com.fateczl.sistemaDeGestaoEscolar.escola.Escola;
import com.fateczl.sistemaDeGestaoEscolar.escola.EscolaRepository;

@Service
public class ProfessorServiceImpl implements ProfessorService {

    @Autowired
    private ProfessorRepository professorRepository;

    @Autowired
    private EscolaRepository escolaRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Override
    public List<Professor> findAll() {
        return professorRepository.findAll(Sort.by("nome").ascending());
    }

    @Override
    public Professor findById(Long id) {
        return professorRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Professor não encontrado com o ID: " + id));
    }

    @Override
    public Professor create(Professor professorMapeado, Long escolaId) {
        if (professorRepository.existsByEmail(professorMapeado.getEmail())) {
            throw new BusinessException("Email já cadastrado.");
        }

        Escola escola = escolaRepository.findById(escolaId)
                .orElseThrow(() -> new ResourceNotFoundException("Escola não encontrada."));

        professorMapeado.setEscola(escola);
        professorMapeado.setSenha(passwordEncoder.encode(professorMapeado.getSenha()));

        return professorRepository.save(professorMapeado);
    }

    @Override
    public Professor update(Long id, Professor dadosAtualizacao, Long escolaId) {
        Professor professorDB = this.findById(id);

        professorRepository.findByEmailAndIdNot(dadosAtualizacao.getEmail(), id)
                .ifPresent(p -> {
                    throw new BusinessException("Email já pertence a outro professor.");
                });

        Escola escola = escolaRepository.findById(escolaId)
                .orElseThrow(() -> new ResourceNotFoundException("Escola não encontrada."));

        professorDB.setNome(dadosAtualizacao.getNome());
        professorDB.setEmail(dadosAtualizacao.getEmail());
        professorDB.setEspecialidade(dadosAtualizacao.getEspecialidade());
        professorDB.setEscola(escola);

        if (dadosAtualizacao.getSenha() != null && !dadosAtualizacao.getSenha().isEmpty()) {
            professorDB.setSenha(passwordEncoder.encode(dadosAtualizacao.getSenha()));
        }

        return professorRepository.save(professorDB);
    }

    @Override
    public void deleteById(Long id) {
        if (!professorRepository.existsById(id)) {
            throw new ResourceNotFoundException("Professor não encontrado.");
        }
        professorRepository.deleteById(id);
    }
}