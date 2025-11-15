package com.fateczl.sistemaDeGestaoEscolar.disciplina;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface DisciplinaRepository extends JpaRepository<Disciplina,Long> {

    boolean existsByCodigo(String codigo);
    
}
