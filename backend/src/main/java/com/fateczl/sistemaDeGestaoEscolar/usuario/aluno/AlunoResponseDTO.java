// Pacote: com.fateczl.sistemaDeGestaoEscolar.aluno
package com.fateczl.sistemaDeGestaoEscolar.usuario.aluno;

import lombok.Data;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

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
    private List<String> turmas;
}