package com.fateczl.sistemaDeGestaoEscolar.usuario.aluno;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;

import com.fateczl.sistemaDeGestaoEscolar.config.exception.BusinessException;
import com.fateczl.sistemaDeGestaoEscolar.config.exception.ResourceNotFoundException;

@Service
public class AlunoService {

    @Autowired
    private AlunoRepository alunoRepository;

    public List<Aluno> findAll() {
        return alunoRepository.findAll(Sort.by("nome").ascending());
    }

    public Aluno findById(Long id) {
        return alunoRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Aluno não encontrado com o ID: " + id));
    }
    public List<Aluno> findByName(String nome){
        return alunoRepository.findByNomeStartsWith(nome);
    }

    public Aluno create(Aluno aluno) {
        if (alunoRepository.existsByMatricula(aluno.getMatricula()))
            throw new BusinessException("Matrícula já cadastrada.");
        return alunoRepository.save(aluno);
    }

    public Aluno update(Long id, Aluno alunoAtualizado) {
        Aluno aluno = this.findById(id);
        aluno.setNome(alunoAtualizado.getNome());
        aluno.setEmail(alunoAtualizado.getEmail());
        aluno.setMatricula(alunoAtualizado.getMatricula());
        aluno.setResponsavelId(alunoAtualizado.getResponsavelId());
        return alunoRepository.save(aluno);
    }

    public void deleteById(Long id) {
        try {
            alunoRepository.deleteById(id);
        } catch (DataIntegrityViolationException e) {
            throw new BusinessException("Não é possível deletar o aluno. Verifique se ele possui associações ativas.");
        }
    }

}
    


