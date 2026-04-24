package com.fateczl.sistemaDeGestaoEscolar.notificacao;

import java.time.LocalDateTime;

import lombok.Data;

@Data
public class NotificacaoResponseDTO {
    private Long id;
    private Long alunoId;
    private String nomeAluno;
    private String matriculaAluno;
    private String nomeTurma;
    private String conteudoIA;
    private String resumo;
    private TipoNotificacao tipo;
    private StatusNotificacao status;
    private LocalDateTime criadaEm;
    private LocalDateTime encaminhadaEm;
}
