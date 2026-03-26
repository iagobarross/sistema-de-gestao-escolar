package com.fateczl.sistemaDeGestaoEscolar.academico.aula;

import java.time.LocalDate;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class AulaRequestDTO {
    
    @NotNull(message = "Matriz curricular é obrigatória")
    private Long matrizCurricularId;

    @NotNull(message = "Data é obrigatória")
    private LocalDate data;

    @NotBlank(message = "Conteúdo é obrigatório")
    private String conteudo;
}
