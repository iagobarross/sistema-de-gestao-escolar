package com.fateczl.sistemaDeGestaoEscolar.escola;

import java.util.List;

public interface EscolaService {

	public List<Escola> findAll();

	public Escola findById(Long id);
	
	public List<Escola> findByName(String nome);

	public Escola create(Escola escola);
	
	public Escola update(Long id, Escola escolaAtualizada);
	
	public void deleteById(Long id);
}
