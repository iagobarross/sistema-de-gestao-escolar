package com.fateczl.sistemaDeGestaoEscolar.atividade;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface AtividadeRepository extends JpaRepository<Atividade, Long>{
    
    List<Atividade> findByMatrizCurricularIdOrderByDataEntregaAsc(Long matrizId);

    @Query("""
            SELECT a FROM Atividade a
            WHERE a.matrizCurricular.turma.id = :turmaId
            ORDER BY a.dataEntrega ASC
            """)
    List<Atividade> findByTurmaId(@Param("turmaId") Long turmaId);

    @Query("""
            SELECT a FROM Atividade a
            WHERE a.matrizCurricular.professor.id = :professorId
            ORDER BY a.dataEntrega ASC
            """)
    List<Atividade> findByProfessorId(@Param("professorId") Long professorId);
}

