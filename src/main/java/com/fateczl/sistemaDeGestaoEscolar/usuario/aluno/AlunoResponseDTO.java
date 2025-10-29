// Pacote: com.fateczl.sistemaDeGestaoEscolar.aluno
package com.fateczl.sistemaDeGestaoEscolar.aluno;

import lombok.Data;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
public class AlunoResponseDTO {

    // --- Campos do Usuario ---
    private Long id;
    private String nome;
    private String email;
    private LocalDateTime dataCriacao;
    private Long escolaId;

    // --- Campos do Aluno ---
    private String matricula;
    private LocalDate dataNascimento;
    private Long responsavelId;

    // --- Campos de Relacionamento (Nomes para clareza) ---
    private String nomeEscola; // Boa prática
    private String nomeResponsavel; // Boa prática
}