    package com.fateczl.sistemaDeGestaoEscolar.academico.aula;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface AulaRepository extends JpaRepository<Aula, Long>{
    
    List<Aula> findByMatrizCurricularIdOrderByDataAscNumeroAulaAsc(Long matrizId);

    @Query("SELECT COALESCE(MAX(a.numeroAula), 0) FROM Aula a WHERE a.matrizCurricular.id = :matrizId")
    int findUltimoNumeroAula(@Param("matrizId") Long matrizId);

    @Query("""
            SELECT a FROM Aula a
            WHERE a.matrizCurricular.professor.id = :professorId
            AND a.data = :data
            ORDER BY a.matrizCurricular.turma.serie
            """)
    List<Aula> findAulasHoje(
        @Param("professorId") Long professorId,
        @Param("data") LocalDate data);
    
    Optional<Aula> findByMatrizCurricularIdAndData(Long matrizId, LocalDate data);

    long countByMatrizCurricularId(Long matrizId);
}
