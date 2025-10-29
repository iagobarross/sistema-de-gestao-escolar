// Pacote: com.fateczl.sistemaDeGestaoEscolar.turma
package com.fateczl.sistemaDeGestaoEscolar.turma;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;
import java.util.Optional;

@Repository
@Transactional
public interface TurmaRepository extends JpaRepository<Turma, Long> {

    // Para validação no Service
    boolean existsByAnoAndSerieAndTurno(int ano, String serie, String turno);

    Optional<Turma> findByAnoAndSerieAndTurnoAndIdNot(int ano, String serie, String turno, Long id);
}