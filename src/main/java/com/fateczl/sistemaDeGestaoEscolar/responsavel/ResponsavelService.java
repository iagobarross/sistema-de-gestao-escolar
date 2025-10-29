// Pacote: com.fateczl.sistemaDeGestaoEscolar.responsavel
package com.fateczl.sistemaDeGestaoEscolar.responsavel;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import com.fateczl.sistemaDeGestaoEscolar.config.exception.BusinessException;
import com.fateczl.sistemaDeGestaoEscolar.config.exception.ResourceNotFoundException;

@Service
public class ResponsavelService {

    @Autowired
    private ResponsavelRepository responsavelRepository;

    public List<Responsavel> findAll() {
        return responsavelRepository.findAll(Sort.by("nome").ascending());
    }

    public Responsavel findById(Long id) {
        return responsavelRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Responsável não encontrado com o ID: " + id));
    }

    public Responsavel create(Responsavel responsavel) {
        if (responsavelRepository.existsByCpf(responsavel.getCpf()))
            throw new BusinessException("CPF já cadastrado.");
        return responsavelRepository.save(responsavel);
    }

    public Responsavel update(Long id, Responsavel dadosAtualizacao) {
        Responsavel responsavelDB = this.findById(id);

        responsavelRepository.findByCpfAndIdNot(dadosAtualizacao.getCpf(), id)
                .ifPresent(r -> {
                    throw new BusinessException("CPF já pertence a outro responsável.");
                });

        responsavelDB.setNome(dadosAtualizacao.getNome());
        responsavelDB.setCpf(dadosAtualizacao.getCpf());
        responsavelDB.setTelefone(dadosAtualizacao.getTelefone());
        return responsavelRepository.save(responsavelDB);
    }

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