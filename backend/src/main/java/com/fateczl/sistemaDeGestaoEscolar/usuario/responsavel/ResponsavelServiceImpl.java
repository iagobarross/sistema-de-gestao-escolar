package com.fateczl.sistemaDeGestaoEscolar.usuario.responsavel;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.data.domain.Sort;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import com.fateczl.sistemaDeGestaoEscolar.config.exception.BusinessException;
import com.fateczl.sistemaDeGestaoEscolar.config.exception.ResourceNotFoundException;

@Service
public class ResponsavelServiceImpl implements ResponsavelService{
    
    @Autowired
    private ResponsavelRepository responsavelRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;
    
    @Override
    public List<Responsavel> findAll() {
        return responsavelRepository.findAll(Sort.by("nome").ascending());
    }

    @Override
    public Responsavel findById(Long id) {
        return responsavelRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Responsável não encontrado com o ID: " + id));
    }

    @Override
    public Responsavel create(Responsavel responsavel) {
        if (responsavelRepository.existsByCpf(responsavel.getCpf()))
            throw new BusinessException("CPF já cadastrado.");
        if (responsavelRepository.existsByEmail(responsavel.getEmail()))    
            throw new BusinessException("Email já cadastrado.");
        if(responsavel.getSenha()==null || responsavel.getSenha().isEmpty())    
            throw new BusinessException("Senha é obrigatória.");
        responsavel.setSenha(passwordEncoder.encode(responsavel.getSenha()));
        return responsavelRepository.save(responsavel);
    }

    @Override
    public Responsavel update(Long id, Responsavel dadosAtualizacao) {
        Responsavel responsavelDB = this.findById(id);

        responsavelRepository.findByCpfAndIdNot(dadosAtualizacao.getCpf(), id)
                .ifPresent(r -> {
                    throw new BusinessException("CPF já pertence a outro responsável.");
                });
                responsavelRepository.findByEmailAndIdNot(dadosAtualizacao.getEmail(), id)
                .ifPresent(r -> {
                    throw new BusinessException("Email já pertence a outro responsável.");
                });        
        responsavelDB.setNome(dadosAtualizacao.getNome());
        responsavelDB.setEmail(dadosAtualizacao.getEmail());
        responsavelDB.setCpf(dadosAtualizacao.getCpf());
        responsavelDB.setTelefone(dadosAtualizacao.getTelefone());
        if(dadosAtualizacao.getSenha()!=null && !dadosAtualizacao.getSenha().isEmpty()) {
            responsavelDB.setSenha(passwordEncoder.encode(dadosAtualizacao.getSenha()));
        }
        return responsavelRepository.save(responsavelDB);
    }

    @Override
    public void deleteById(Long id) {
        if (!responsavelRepository.existsById(id)) {
            throw new ResourceNotFoundException("Responsável não encontrado com o ID: " + id);
        }
        try {
            responsavelRepository.deleteById(id);
        } catch (DataIntegrityViolationException e) {
            throw new BusinessException(
                    "Não é possível deletar o responsável. Verifique se ele possui alunos associados.");
        }
    }

}
