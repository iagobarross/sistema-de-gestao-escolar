// Pacote: com.fateczl.sistemaDeGestaoEscolar.aluno
package com.fateczl.sistemaDeGestaoEscolar.usuario.aluno;

import lombok.Data;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Data
public class AlunoResponseDTO {

    private Long id;
    private String nome;
    private String email;
    private LocalDateTime dataCriacao;
    private Long escolaId;

    private String matricula;
    private LocalDate dataNascimento;
    private Long responsavelId;

    private String nomeEscola;
    private String nomeResponsavel;
    private List<String> turmas;
}