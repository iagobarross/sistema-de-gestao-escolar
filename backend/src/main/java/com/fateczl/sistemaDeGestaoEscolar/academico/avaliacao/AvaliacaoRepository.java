package com.fateczl.sistemaDeGestaoEscolar.academico.avaliacao;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface AvaliacaoRepository extends JpaRepository<Avaliacao, Long> {

    List<Avaliacao> findByMatrizCurricularIdOrderByDataAplicacaoAsc(Long matrizId);

    List<Avaliacao> findByMatrizCurricularIdAndBimestreOrderByDataAplicacaoAsc(Long matrizId, int bimestre);

    List<Avaliacao> findByMatrizCurricularProfessorIdAndDataAplicacaoAfterOrderByDataAplicacaoAsc(Long professorId,
            java.time.LocalDate hoje);
}