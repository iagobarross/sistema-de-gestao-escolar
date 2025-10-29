package com.fateczl.sistemaDeGestaoEscolar.disciplina;

import java.util.List;

public interface DisciplinaService {
	
	public List<Disciplina> findAll();

	public Disciplina findById(Long id);

	public Disciplina create(Disciplina disciplina);

	public Disciplina update(Long id, Disciplina disciplinaAtualizada);

	public void deleteById(Long id);	
} 

