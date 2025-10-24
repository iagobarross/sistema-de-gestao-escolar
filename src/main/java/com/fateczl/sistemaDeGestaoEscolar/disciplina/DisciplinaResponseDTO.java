package com.fateczl.sistemaDeGestaoEscolar.disciplina;

import lombok.Data;

@Data
public class DisciplinaResponseDTO {
    private Long id;
    private String nome;
    private String descricao;
    private double notaMinima;
    private int cargaHoraria;
}
