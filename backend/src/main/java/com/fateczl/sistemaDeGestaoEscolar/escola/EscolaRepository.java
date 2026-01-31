package com.fateczl.sistemaDeGestaoEscolar.escola;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface EscolaRepository extends JpaRepository<Escola,Long> {

	List<Escola> findByNomeStartsWith (String nome);
	
	boolean existsByCnpj(String cnpj);

	boolean existsByCodigo(String codigo);

	boolean existsByCnpjAndIdNot(String cnpj, Long id);

	boolean existsByCodigoAndIdNot(String codigo, Long id);

}
