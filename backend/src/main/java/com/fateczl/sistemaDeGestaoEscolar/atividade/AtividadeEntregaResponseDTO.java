package com.fateczl.sistemaDeGestaoEscolar.atividade;

import java.time.LocalDateTime;

import lombok.Data;

@Data
public class AtividadeEntregaResponseDTO {
    private Long id;
    private Long atividadeId;
    private String tituloAtividade;
    private Long alunoId;
    private String nomeAluno;
    private String matriculaAluno;
    private String conteudo;
    private LocalDateTime entregueEm;
    private StatusEntrega status;
}
