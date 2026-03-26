package com.fateczl.sistemaDeGestaoEscolar.academico.avaliacao;

import java.time.LocalDate;

import com.fateczl.sistemaDeGestaoEscolar.academico.TipoAvaliacao;

import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.FutureOrPresent;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class AvaliacaoRequestDTO {
    
    @NotNull(message = "Matriz curricular é obrigatória")
    private Long matrizCurricularId;

    @NotBlank(message = "Título é obrigatório")
    @Size(max = 150)
    private String titulo;

    @NotNull(message = "Tipo é obrigatório")
    private TipoAvaliacao tipo;

    @NotNull(message = "Data de aplicação é obrigatória")
    @FutureOrPresent(message = "Data deve ser hoje ou no futuro")
    private LocalDate dataAplicacao;

    @DecimalMin(value = "0.1") 
    @DecimalMax(value = "10.0")
    private double notaMaxima = 10.0;

    @Min(1)
    @Max(4)
    private int bimestre;

    @DecimalMin("0.1")
    @DecimalMax("5.0")
    private double peso = 1.0;
}
