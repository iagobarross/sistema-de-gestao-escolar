package com.fateczl.sistemaDeGestaoEscolar.academico.avaliacao;

import java.time.LocalDate;

import com.fateczl.sistemaDeGestaoEscolar.academico.TipoAvaliacao;

import lombok.Data;

@Data
public class AvaliacaoResponseDTO {
    private Long id;
    private Long matrizCurricularId;
    private String nomeDisciplina;
    private String nomeTurma;
    private String titulo;
    private TipoAvaliacao tipo;
    private LocalDate dataAplicacao;
    private double notaMaxima;
    private int bimestre;
    private double peso;
    private long totalNotasLancadas;
    private long totalAlunos;
}
