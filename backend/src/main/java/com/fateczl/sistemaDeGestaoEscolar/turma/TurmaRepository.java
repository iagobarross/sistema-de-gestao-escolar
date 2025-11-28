// Pacote: com.fateczl.sistemaDeGestaoEscolar.turma
package com.fateczl.sistemaDeGestaoEscolar.turma;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.query.Procedure;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

@Repository
@Transactional
public interface TurmaRepository extends JpaRepository<Turma, Long> {

    boolean existsByAnoAndSerieAndTurno(int ano, String serie, String turno);

    Optional<Turma> findByAnoAndSerieAndTurnoAndIdNot(int ano, String serie, String turno, Long id);

    @Procedure(procedureName = "sp_matricular_aluno", outputParameterName = "p_resultado")
    String matricularAluno(
        @Param("p_aluno_id") Long alunoId, 
        @Param("p_turma_id") Long turmaId
    );
    
}