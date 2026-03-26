package com.fateczl.sistemaDeGestaoEscolar.academico.nota;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class NotaResponseDTO {
    private Long id;
    private Long avaliacaoId;
    private String tituloAvaliacao;
    private int bimestre;
    private Long alunoId;
    private String nomeAluno;
    private String matriculaAluno;
    private double valor;
    private double notaMaxima;
    private String observacao;
    private LocalDateTime lancadaEm;
}