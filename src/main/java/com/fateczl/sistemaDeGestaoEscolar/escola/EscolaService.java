package com.fateczl.sistemaDeGestaoEscolar.escola;

import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;


@Service
public class EscolaService {
	@Autowired
	private EscolaRepository escolaRepository;
	
	public Escola saveOrUpdate(Escola escola) {
		return escolaRepository.save(escola);
	}
	
	public List<Escola> findAll(){
		return escolaRepository.findAll(Sort.by("nome").ascending());
	}
	
	public void deleteById(Long id) {
		escolaRepository.deleteById(id);
	}
	
	public Optional<Escola> findById(Long id) {
	    return escolaRepository.findById(id);
	}
	
	
}
