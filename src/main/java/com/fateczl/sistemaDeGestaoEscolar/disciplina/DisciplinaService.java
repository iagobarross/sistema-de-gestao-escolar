package com.fateczl.sistemaDeGestaoEscolar.disciplina;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;

import com.fateczl.sistemaDeGestaoEscolar.config.exception.BusinessException;
import com.fateczl.sistemaDeGestaoEscolar.config.exception.ResourceNotFoundException;

@Service
public class DisciplinaService {
    
    @Autowired
    private DisciplinaRepository disciplinaRepository;

    public List<Disciplina> findAll(){
        return disciplinaRepository.findAll(Sort.by("nome").ascending());
    }

    public Disciplina findById(Long id){
        return disciplinaRepository.findById(id)
				.orElseThrow(() -> new ResourceNotFoundException("Disciplina não encontrada com o ID: " + id));
    }

    public Disciplina create(Disciplina disciplina) {
		if(disciplinaRepository.existsById(disciplina.getId()))
			throw new BusinessException("Disciplina já cadastrada.");
		return disciplinaRepository.save(disciplina);
	}

    public Disciplina update(Long id, Disciplina disciplinaAtualizada) {
		Disciplina disciplina = this.findById(id);
		disciplina.setNome(disciplinaAtualizada.getNome());
        disciplina.setDescricao(disciplinaAtualizada.getDescricao());
        disciplina.setNotaMinima(disciplinaAtualizada.getNotaMinima());
        disciplina.setCargaHoraria(disciplinaAtualizada.getCargaHoraria());
		return disciplinaRepository.save(disciplina);
	}

    public void deleteById(Long id) {
		try{
			disciplinaRepository.deleteById(id);
		} catch (DataIntegrityViolationException e) {
			throw new BusinessException("Não é possível deletar a disciplina. Verifique se ela possui turmas ou alunos associados.");
		}
	}
}
