package com.fateczl.sistemaDeGestaoEscolar.atividade;

import java.time.LocalDateTime;

import lombok.Data;

@Data
public class AtividadeAlunoStatusDTO {
    private Long alunoId;
    private String nomeAluno;
    private String matriculaAluno;

    private Long entregaId;
    private String status;
    private String conteudo;
    private String arquivoNome;
    private String arquivoTipo;
    private boolean temArquivo;
    private LocalDateTime entregueEm;
}
