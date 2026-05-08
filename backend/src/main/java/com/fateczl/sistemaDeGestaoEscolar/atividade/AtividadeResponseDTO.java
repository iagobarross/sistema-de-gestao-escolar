package com.fateczl.sistemaDeGestaoEscolar.atividade;

import java.time.LocalDate;
import java.time.LocalDateTime;

import lombok.Data;

@Data
public class AtividadeResponseDTO {
    private Long id;
    private Long matrizCurricularId;
    private String nomeDisciplina;
    private String nomeTurma;
    private String nomeProfessor;
    private String titulo;
    private String descricao;
    private LocalDate dataEntrega;
    private LocalDateTime criadaEm;
    private long totalEntregas;
    private long totalAlunos;
}
