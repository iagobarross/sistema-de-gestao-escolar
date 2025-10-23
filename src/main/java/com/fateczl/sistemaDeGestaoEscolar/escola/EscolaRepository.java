package com.fateczl.sistemaDeGestaoEscolar.escola;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

@Repository
@Transactional
public interface EscolaRepository extends JpaRepository<Escola,Long> {

}
