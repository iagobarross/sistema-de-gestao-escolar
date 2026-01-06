package com.fateczl.sistemaDeGestaoEscolar.usuario.professor;

import lombok.Data;
import java.time.LocalDateTime;
import java.util.List;

@Data
public class ProfessorResponseDTO {

    private Long id;
    private String nome;
    private String email;
    private LocalDateTime dataCriacao;
    private String especialidade;
    private Long escolaId;
    private String nomeEscola;
    private List<String> turmas;
}