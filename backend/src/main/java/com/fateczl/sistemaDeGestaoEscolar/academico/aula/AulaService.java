package com.fateczl.sistemaDeGestaoEscolar.academico.aula;

import java.util.List;

public interface AulaService {
    Aula findById(Long id);
    List<Aula> findByMatriz(Long matrizId);
    List<Aula> findAulasHojeDoProfessor (Long professorId);
    Aula registrar(AulaRequestDTO dto);
    Aula atualizar(Long id, AulaRequestDTO dto);
    void deletar(Long id);
}
