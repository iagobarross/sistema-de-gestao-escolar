package com.fateczl.sistemaDeGestaoEscolar.academico.aula;

import java.time.LocalDate;

import lombok.Data;

@Data
public class AulaResponseDTO {
    private Long id;
    private Long matrizCurricularId;
    private String nomeDisciplina;
    private String nomeTurma;
    private LocalDate data;
    private String conteudo;
    private int numeroAula;
    private boolean chamadaLancada;
}
