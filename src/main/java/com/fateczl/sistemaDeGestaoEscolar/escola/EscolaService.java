package com.fateczl.sistemaDeGestaoEscolar.escola;

import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;

import com.fateczl.sistemaDeGestaoEscolar.config.exception.BusinessException;
import com.fateczl.sistemaDeGestaoEscolar.config.exception.ResourceNotFoundException;


@Service
public class EscolaService {
	@Autowired
	private EscolaRepository escolaRepository;
	
	public List<Escola> findAll(){
		return escolaRepository.findAll(Sort.by("nome").ascending());
	}
	
	public Escola findById(Long id) {
		return escolaRepository.findById(id)
				.orElseThrow(() -> new ResourceNotFoundException("Escola não encontrada com o ID: " + id));
	}
	
	public Escola create(Escola escola) {
		if(escolaRepository.existsById(escola.getId()))
			throw new BusinessException("CNPJ já cadastrado.");
		return escolaRepository.save(escola);
	}
	
	public Escola update(Long id, Escola escolaAtualizada) {
		Escola escola = this.findById(id);
		escola.setNome(escolaAtualizada.getNome());
		escola.setCodigo(escolaAtualizada.getCodigo());
		escola.setCnpj(escolaAtualizada.getCnpj());
		escola.setEndereco(escola.getEndereco());
		return escolaRepository.save(escola);
	}
	
	public void deleteById(Long id) {
		try{
			escolaRepository.deleteById(id);
		} catch (DataIntegrityViolationException e) {
			throw new BusinessException("Não é possível deletar a escola. Verifique se ela possui turmas ou alunos associados.");
		}
	}
	
	
	
}
