// Pacote: com.fateczl.sistemaDeGestaoEscolar.turma
package com.fateczl.sistemaDeGestaoEscolar.turma;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import lombok.Data;

@Data
public class TurmaRequestDTO {

    @NotNull(message = "Ano é obrigatório")
    @Positive(message = "Ano deve ser um número positivo")
    private int ano;

    @NotBlank(message = "Série é obrigatória")
    private String serie;

    @NotBlank(message = "Turno é obrigatório")
    private String turno;
}