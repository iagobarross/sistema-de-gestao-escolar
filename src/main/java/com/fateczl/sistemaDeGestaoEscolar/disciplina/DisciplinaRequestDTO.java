package com.fateczl.sistemaDeGestaoEscolar.disciplina;

import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import lombok.Data;

@Data
public class DisciplinaRequestDTO {
    @NotBlank(message = "Nome é obrigatório")
	private String nome;

    @NotBlank(message = "Código é obrigatório")
    private String codigo;

    @NotBlank(message = "Descrição é obrigatória")
    private String descricao;

    @NotNull(message = "Nota mínima é obrigatória")
    @DecimalMin(value = "5.0", message = "A nota mínima deve ser 5.0 ou superior")
    @DecimalMax(value = "10.0", message = "A nota mínima não pode ser superior a 10.0")
    private double notaMinima;

    @NotNull(message = "Carga horária é obrigatória")
    @Positive(message = "A carga horária deve ser positiva.")
    private int cargaHoraria;
}
