package com.fateczl.sistemaDeGestaoEscolar.chat;

import lombok.Data;

@Data
public class MensagemPrivadaDTO {
    // O texto da mensagem que o utilizador digitou
    private String conteudo;

    // O ID do utilizador que vai receber esta mensagem (ex: ID do Professor)
    private Long destinatarioId;
}