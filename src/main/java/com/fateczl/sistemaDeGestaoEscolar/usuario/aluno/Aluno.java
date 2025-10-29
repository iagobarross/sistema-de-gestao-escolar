// Pacote: com.fateczl.sistemaDeGestaoEscolar.aluno
package com.fateczl.sistemaDeGestaoEscolar.aluno;

import com.fateczl.sistemaDeGestaoEscolar.escola.Escola;
import com.fateczl.sistemaDeGestaoEscolar.responsavel.Responsavel;
import com.fateczl.sistemaDeGestaoEscolar.usuario.Usuario; // Herança correta

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDate;
import java.util.List;

@Entity // <--- Tem que ser @Entity
@Table(name = "alunos")
// REMOVA QUALQUER ANOTAÇÃO @Inheritance AQUI SE ELA EXISTIR.
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class Aluno extends Usuario { // <--- Herda de Usuario

    @Column(nullable = false, unique = true, length = 50)
    private String matricula;

    private LocalDate dataNascimento;

    // --- Relacionamento N:1 com Escola (Correto) ---
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "escola_id", nullable = false)
    private Escola escola;

    // --- Relacionamento N:1 com Responsavel ---
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "responsavel_id", nullable = false)
    private Responsavel responsavel;

    // --- Relacionamento N:M com Turma ---
    @ManyToMany(mappedBy = "alunos", fetch = FetchType.LAZY)
    private List<com.fateczl.sistemaDeGestaoEscolar.turma.Turma> turmas;
}