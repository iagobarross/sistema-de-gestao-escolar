package com.fateczl.sistemaDeGestaoEscolar.atividade;

import java.time.LocalDate;

import jakarta.validation.constraints.FutureOrPresent;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class AtividadeRequestDTO {
    
    @NotNull
    private Long matrizCurricularId;

    @NotBlank
    @Size(max = 200)
    private String titulo;

    private String descricao;

    @NotNull
    @FutureOrPresent
    private LocalDate dataEntrega;
}
