package com.fateczl.sistemaDeGestaoEscolar.usuario.funcionario;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class FuncionarioResponseDTO {

    private Long id;
    private String nome;
    private String email;
    private String cargo;
    private LocalDateTime dataCriacao;

    // Dados do relacionamento (evita loop infinito de JSON ao retornar a Entidade Escola inteira)
    private Long escolaId;
    private String nomeEscola;
}