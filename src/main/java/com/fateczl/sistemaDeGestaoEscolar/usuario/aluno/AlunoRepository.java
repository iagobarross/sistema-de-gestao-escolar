package com.fateczl.sistemaDeGestaoEscolar.usuario.aluno;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;


@Repository
@Transactional
public interface AlunoRepository extends JpaRepository<Aluno, Long> {
    
    List<Aluno> findByNomeStartsWith (String nome);
	
	boolean existsByMatricula(String matricula);
}
    

