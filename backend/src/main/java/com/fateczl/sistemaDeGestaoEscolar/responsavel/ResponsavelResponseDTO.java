// Pacote: com.fateczl.sistemaDeGestaoEscolar.responsavel
package com.fateczl.sistemaDeGestaoEscolar.responsavel;

import lombok.Data;

@Data
public class ResponsavelResponseDTO {
    private Long id;
    private String nome;
    private String cpf;
    private String telefone;
    private String email;
}