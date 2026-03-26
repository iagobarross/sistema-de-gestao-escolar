package com.fateczl.sistemaDeGestaoEscolar.academico.frequencia;

import lombok.Data;

@Data
public class FrequenciaResponseDTO {
    private Long id;
    private Long aulaId;
    private Long alunoId;
    private String nomeAluno;
    private String matriculaAluno;
    private boolean presente;
    private String justificativa;
}
