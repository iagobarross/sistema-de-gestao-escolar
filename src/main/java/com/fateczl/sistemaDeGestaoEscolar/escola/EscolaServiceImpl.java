package com.fateczl.sistemaDeGestaoEscolar.escola;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;

import com.fateczl.sistemaDeGestaoEscolar.config.exception.BusinessException;
import com.fateczl.sistemaDeGestaoEscolar.config.exception.ResourceNotFoundException;

@Service
public class EscolaServiceImpl implements EscolaService{
@Autowired
	private EscolaRepository escolaRepository;
	
    @Override
	public List<Escola> findAll(){
		return escolaRepository.findAll(Sort.by("nome").ascending());
	}
	
    @Override
	public Escola findById(Long id) {
		return escolaRepository.findById(id)
				.orElseThrow(() -> new ResourceNotFoundException("Escola não encontrada com o ID: " + id));
	}
	
    @Override
	public List<Escola> findByName(String nome) {
		return escolaRepository.findByNomeStartsWith(nome);
	}
	
    @Override
	public Escola create(Escola escola) {
		if(escolaRepository.existsByCnpj(escola.getCnpj()))
			throw new BusinessException("CNPJ já cadastrado.");
		return escolaRepository.save(escola);
	}
	
    @Override
	public Escola update(Long id, Escola escolaAtualizada) {
		Escola escola = this.findById(id);
		escola.setNome(escolaAtualizada.getNome());
		escola.setCodigo(escolaAtualizada.getCodigo());
		escola.setCnpj(escolaAtualizada.getCnpj());
		escola.setEndereco(escolaAtualizada.getEndereco());
		return escolaRepository.save(escola);
	}
	
    @Override
	public void deleteById(Long id) {
		try{
			escolaRepository.deleteById(id);
		} catch (DataIntegrityViolationException e) {
			throw new BusinessException("Não é possível deletar a escola. Verifique se ela possui turmas ou alunos associados.");
		}
	}
	
}