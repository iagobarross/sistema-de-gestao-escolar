// Pacote: com.fateczl.sistemaDeGestaoEscolar.responsavel
package com.fateczl.sistemaDeGestaoEscolar.responsavel;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.Optional;

@Repository
public interface ResponsavelRepository extends JpaRepository<Responsavel, Long> {

    boolean existsByCpf(String cpf);

    Optional<Responsavel> findByCpfAndIdNot(String cpf, Long id);
}