package com.fateczl.sistemaDeGestaoEscolar.academico.matriz;

import com.fateczl.sistemaDeGestaoEscolar.academico.StatusMatriz;

import lombok.Data;

@Data
public class MatrizCurricularResponseDTO {
    private Long id;
    private Long turmaId;
    private String nomeTurma;
    private Long disciplinaId;
    private String nomeDisciplina;
    private Long professorId;
    private String nomeProfessor;
    private int ano;
    private int cargaHorariaTotal;
    private long aulasRealizadas;
    private StatusMatriz status;
}
