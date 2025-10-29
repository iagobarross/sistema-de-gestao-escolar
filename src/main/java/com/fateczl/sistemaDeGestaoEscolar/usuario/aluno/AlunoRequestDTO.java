// Pacote: com.fateczl.sistemaDeGestaoEscolar.aluno
package com.fateczl.sistemaDeGestaoEscolar.aluno;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Past;
import jakarta.validation.constraints.Size;
import lombok.Data;
import java.time.LocalDate;

@Data
public class AlunoRequestDTO {

    // --- Campos do Usuario ---
    @NotBlank(message = "Nome é obrigatório")
    @Size(min = 3, message = "Nome deve ter no mínimo 3 caracteres")
    private String nome;

    @NotBlank(message = "Email é obrigatório")
    @Email(message = "Email deve ser válido")
    private String email;

    @NotBlank(message = "Senha é obrigatória")
    @Size(min = 6, message = "Senha deve ter no mínimo 6 caracteres")
    private String senha;

    @NotNull(message = "ID da Escola é obrigatório")
    private Long escolaId;

    // --- Campos do Aluno ---
    @NotBlank(message = "Matrícula é obrigatória")
    private String matricula;

    @NotNull(message = "Data de Nascimento é obrigatória")
    @Past(message = "Data de Nascimento deve ser no passado")
    private LocalDate dataNascimento;

    @NotNull(message = "ID do Responsável é obrigatório")
    private Long responsavelId;
}