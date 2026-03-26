package com.fateczl.sistemaDeGestaoEscolar.academico.frequencia;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

@Repository
public interface FrequenciaRepository extends JpaRepository<Frequencia, Long> {

    List<Frequencia> findByAulaId(Long aulaId);

    boolean existsByAulaIdAndAlunoId(Long aulaId, Long alunoId);

    Optional<Frequencia> findByAulaIdAndAlunoId(Long aulaId, Long alunoId);

    @Query("""
            SELECT
                SUM(CASE WHEN f.presente = true THEN 1.0 ELSE 0.0 END) / COUNT(f)
            FROM Frequencia f
            WHERE f.aula.matrizCurricular.id = :matrizId
            AND f.aluno.id = :alunoId
            """)
    Double calcularPercentualPresenca(
            @Param("matrizId") Long matrizId,
            @Param("alunoId") Long alunoId);

    @Query("""
        SELECT COUNT(f) FROM Frequencia f
        WHERE f.aula.matrizCurricular.id = :matrizId
        AND f.aluno.id = :alunoId
        AND f.presente = false
    """)
    long contarFaltas(
            @Param("matrizId") Long matrizId,
            @Param("alunoId") Long alunoId);
            

    @Query("""
            SELECT f.aluno.id, AVG(CASE WHEN f.presente THEN 1.0 ELSE 0.0 END)
            FROM Frequencia f
            WHERE f.aula.matrizCurricular.turma.id = :turmaId
            GROUP BY f.aluno.id
            HAVING AVG(CASE WHEN f.presente THEN 1.0 ELSE 0.0 END) < :limiar
            """)
    List<Object[]> findAlunosComBaixaFrequencia(
            @Param("turmaId") Long turmaId,
            @Param("limiar") double limiar);

}
