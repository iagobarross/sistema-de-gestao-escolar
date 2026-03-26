package com.fateczl.sistemaDeGestaoEscolar.academico.avaliacao;

import java.util.List;

public interface AvaliacaoService {
    Avaliacao findById(Long id);
    List<Avaliacao> findByMatriz(Long matrizId);
    List<Avaliacao> findByMatrizAndBimestre(Long matrizId, int bimestre);
    List<Avaliacao> findProximasDosProfessor(Long professorId);
    Avaliacao create(AvaliacaoRequestDTO dto);
    Avaliacao update (Long id, AvaliacaoRequestDTO dto);
    void deleteById(Long id);
}
