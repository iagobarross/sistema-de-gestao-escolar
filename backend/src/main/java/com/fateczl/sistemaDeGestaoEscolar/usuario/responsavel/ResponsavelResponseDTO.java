package com.fateczl.sistemaDeGestaoEscolar.usuario.responsavel;

import lombok.Data;

@Data
public class ResponsavelResponseDTO {
    private Long id;
    private String nome;
    private String cpf;
    private String telefone;
    private String email;
}