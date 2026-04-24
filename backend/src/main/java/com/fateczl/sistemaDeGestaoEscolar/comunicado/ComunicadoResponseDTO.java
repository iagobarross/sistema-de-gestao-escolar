package com.fateczl.sistemaDeGestaoEscolar.comunicado;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class ComunicadoResponseDTO {
    private Long id;
    private String titulo;
    private String corpo;
    private String nomeAluno;
    private String nomeAutor;
    private String nomeEscola;
    private boolean lido;
    private LocalDateTime criadoEm;
    private LocalDateTime lidoEm;
}