package com.fateczl.sistemaDeGestaoEscolar.config.exception;

import lombok.Data;
import java.time.LocalDateTime;
import java.util.List;

@Data
public class RespostaErro {
    private LocalDateTime timestamp;
    private Integer status;
    private String erro;
    private String caminho;

    // Este campo só será preenchido se o erro for de validação (ex: @CNPJ falhou)
    private List<ErroValidacao> validacoes;
}