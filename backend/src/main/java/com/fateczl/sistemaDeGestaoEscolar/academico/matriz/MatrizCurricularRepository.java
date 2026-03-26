package com.fateczl.sistemaDeGestaoEscolar.academico.matriz;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

@Repository
public interface MatrizCurricularRepository extends JpaRepository<MatrizCurricular, Long> {

    boolean existsByTurmaIdAndDisciplinaIdAndAno(Long turmaId, Long disciplinaId, int ano);

    List<MatrizCurricular> findByTurmaIdAndAnoOrderByDisciplinaNomeAsc(Long turmaId, int ano);

    List<MatrizCurricular> findByProfessorIdAndAnoOrderByTurmaSerie(Long professorId, int ano);

    Optional<MatrizCurricular> findByTurmaIdAndDisciplinaIdAndProfessorIdAndAno(Long turmaId, Long disciplinaId,
            Long professorId, int ano);

    @Query("""
                SELECT m FROM MatrizCurricular m
                WHERE m.professor.id = :professorId
                AND m.ano = :ano
                AND m.status = 'ATIVA'
                ORDER BY m.turma.serie, m.disciplina.nome
            """)
    List<MatrizCurricular> findAtivasByProfessorAndAno(
            @Param("professorId") Long professorId,
            @Param("ano") int ano);

}
