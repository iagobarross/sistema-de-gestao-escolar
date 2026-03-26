package com.fateczl.sistemaDeGestaoEscolar.academico.nota;

import lombok.Data;

@Data
public class BoletimDisciplinaDTO {
    
    private Long disciplinaId;
    private String nomeDisciplina;
    private String nomeProfessor;
    private double notaMinima;

    private Double mediaBimestre1;
    private Double mediaBimestre2;
    private Double mediaBimestre3;
    private Double mediaBimestre4;
    private Double mediaFinal;

    private long totalAulas;
    private long faltas;
    private Double percentualPresenca;
    private String situacao;
}
