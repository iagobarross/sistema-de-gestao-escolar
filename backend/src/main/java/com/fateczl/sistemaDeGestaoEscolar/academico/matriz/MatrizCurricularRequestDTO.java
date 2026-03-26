package com.fateczl.sistemaDeGestaoEscolar.academico.matriz;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import lombok.Data;

@Data
public class MatrizCurricularRequestDTO {
    
    @NotNull(message = "Turma é obrigatória")
    private Long turmaId;

    @NotNull(message = "Disciplina é obrigatória")
    private Long disciplinaId;

    @NotNull(message = "Professor é obrigatório")
    private Long professorId;

    @NotNull(message = "Ano é obrigatório")
    @Min(value = 2020, message = "Ano inválido")
    @Max(value = 2099, message = "Ano inválido")
    private Integer ano;

    @Positive(message = "Carga horária deve ser positiva")
    private int cargaHorariaTotal;
}
