package com.fateczl.sistemaDeGestaoEscolar.academico.nota;

import java.util.List;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class LancarNotasRequestDTO {
    
    @NotNull
    private Long avaliacaoId;

    @NotEmpty(message = "Lista de notas não pode ser vazia")
    private List<NotaItemDTO> notas;

    @Data
    public static class NotaItemDTO{

        @NotNull
        private Long alunoId;

        @DecimalMin(value = "0.0", message = "Nota não pode ser negativa")
        @NotNull(message = "Valor é obrigatório")
        private Double valor;

        private String observacao;
    }
}
