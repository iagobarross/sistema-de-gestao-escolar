package com.fateczl.sistemaDeGestaoEscolar.usuario.aluno;

import lombok.Data;

@Data
public class AlunoResponseDTO {
    private String matricula;
    private String curso;
    private String responsavel;
    private Long responsavelId;
    private String nome;
    private String email;
    private String dataNascimento;
    private String telefone;
    private String CPF;
    
}
