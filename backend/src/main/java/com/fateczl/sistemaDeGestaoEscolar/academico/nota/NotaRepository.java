package com.fateczl.sistemaDeGestaoEscolar.academico.nota;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

@Repository
public interface NotaRepository extends JpaRepository<Nota,Long>{
    
    List<Nota> findByAvaliacaoId(Long avaliacaoId);

    Optional<Nota> findByAvaliacaoIdAndAlunoId(Long avaliacaoId, Long alunoId);

    boolean existsByAvaliacaoIdAndAlunoId(Long avaliacaoId, Long alunoId);

    @Query("""
            SELECT n FROM Nota n
            WHERE n.avaliacao.matrizCurricular.id = :matrizId
            AND n.aluno.id = :alunoId
            ORDER BY n.avaliacao.bimestre, n.avaliacao.dataAplicacao
            """)
    List<Nota> findByMatrizAndAluno(
        @Param ("matrizId") Long matrizId,
        @Param("alunoId") Long alunoId);

    @Query("""
            SELECT SUM(n.valor * a.peso) / SUM(a.peso)
            FROM Nota n JOIN n.avaliacao a
            WHERE a.matrizCurricular.id = :matrizId
            AND n.aluno.id = :alunoId
            AND a.bimestre = :bimestre
            """)
    Double calcularMediaBimestre(
        @Param("matrizId") Long matrizId,
        @Param("alunoId") Long alunoId,
        @Param("bimestre") int bimestre);

    @Query("""
            SELECT SUM(n.valor * a.peso) / SUM(a.peso)
            FROM Nota n JOIN n.avaliacao a
            WHERE a.matrizCurricular.id = :matrizId
            AND n.aluno.id = :alunoId 
            """)
    Double calcularMediaGeral(
        @Param("matrizId") Long matrizId,
        @Param("alunoId") Long alunoId);

    @Query("""
            SELECT n.aluno.id, SUM(n.valor * av.peso) / SUM(av.peso)
            FROM Nota n JOIN n.avaliacao av
            WHERE av.matrizCurricular.turma.id = :turmaId
            AND av.matrizCurricular.disciplina.id = :disciplinaId
            GROUP BY n.aluno.id
            """)
    List<Object[]> findMediasPorAlunoNaTurma(
        @Param("turmaId") Long turmaId,
        @Param("disciplinaId") Long disciplinaId);
    
    long countByAvaliacaoId(Long avaliacaoId);
}
