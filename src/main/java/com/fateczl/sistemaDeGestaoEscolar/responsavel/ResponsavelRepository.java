// Pacote: com.fateczl.sistemaDeGestaoEscolar.responsavel
package com.fateczl.sistemaDeGestaoEscolar.responsavel;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;
import java.util.Optional;

@Repository
@Transactional
public interface ResponsavelRepository extends JpaRepository<Responsavel, Long> {

    // Para validação no Service
    boolean existsByCpf(String cpf);

    Optional<Responsavel> findByCpfAndIdNot(String cpf, Long id);
}