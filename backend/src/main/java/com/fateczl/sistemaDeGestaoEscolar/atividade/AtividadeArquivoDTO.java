package com.fateczl.sistemaDeGestaoEscolar.atividade;

import lombok.Data;

@Data
public class AtividadeArquivoDTO {
    private String arquivoBase64;
    private String arquivoNome;
    private String arquivoTipo;
}
