package com.fateczl.sistemaDeGestaoEscolar.usuario.funcionario;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class FuncionarioRequestDTO {

    @NotBlank(message = "Nome é obrigatório")
    @Size(min = 3, message = "Nome deve ter no mínimo 3 caracteres")
    private String nome;

    @NotBlank(message = "Email é obrigatório")
    @Email(message = "Email deve ser válido")
    private String email;

    // A senha pode ser nula na atualização, mas na criação validamos no Service
    private String senha;

    @NotNull(message = "O cargo do funcionário é obrigatório")
    private Funcionario.Cargo cargo;

    // Pode ser nulo, pois um ADMIN (da prefeitura) não pertence a uma escola específica
    private Long escolaId;
}