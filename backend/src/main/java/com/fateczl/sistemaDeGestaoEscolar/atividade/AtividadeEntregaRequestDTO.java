package com.fateczl.sistemaDeGestaoEscolar.atividade;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class AtividadeEntregaRequestDTO {
    
    @NotNull
    private Long atividadeId;
    private String conteudo;
}
