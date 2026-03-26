package com.fateczl.sistemaDeGestaoEscolar.academico.frequencia;

import java.util.List;

import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class LancarChamadaRequestDTO {
    
    @NotNull
    private Long aulaId;

    @NotEmpty(message = "Lista de presenças não pode ser vazia")
    private List<PresencaItemDTO> presencas;

    @Data
    public static class PresencaItemDTO{
        @NotNull
        private Long alunoId;
        private boolean presente;
        private String justificativa;
    }
    
}
