package com.fateczl.sistemaDeGestaoEscolar.academico.matriz;

import java.util.List;

public interface MatrizCurricularService {
    MatrizCurricular findById(Long id);
    List<MatrizCurricular> findByTurmaAndAno(Long turmaId, int ano);
    List<MatrizCurricular> findByProfessorAndAno(Long professorId, int ano);
    MatrizCurricular create(MatrizCurricularRequestDTO dto);
    MatrizCurricular update(Long id, MatrizCurricularRequestDTO dto);
    void encerrar(Long id);
    void deleteById(Long id);
}
