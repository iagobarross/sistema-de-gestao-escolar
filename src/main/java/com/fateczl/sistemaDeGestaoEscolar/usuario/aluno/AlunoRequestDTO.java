package com.fateczl.sistemaDeGestaoEscolar.usuario.aluno;

import lombok.Data;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import jakarta.validation.constraints.Email;
import org.hibernate.validator.constraints.br.CPF;


@Data
public class AlunoRequestDTO {
    
    @NotBlank(message = "Matrícula é obrigatória")
    private String matricula;

    @NotBlank(message = "Curso é obrigatório")
    private String curso;   

    @NotBlank(message = "Nome é obrigatório")
    private String nome;

    @NotBlank(message = "Email é obrigatório")  
    @Email(message = "Email inválido")
    private String email;

    @NotBlank(message = "Senha é obrigatória")
    @Size(min = 8, message = "Senha deve ter no mínimo 6 caracteres")   
    private String senha;

    @NotBlank(message = "dataNascimento é obrigatória")
    private String dataNascimento;

    @NotBlank(message = "telefone é obrigatório")
    private String telefone;

    @NotBlank(message = "CPF é obrigatório")
    @CPF(message = "CPF inválido")
    private String CPF;
    
    // id do responsável (p.ex. id de um usuário responsável)
    private Long responsavelId;
}
