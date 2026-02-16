// Pacote: com.fateczl.sistemaDeGestaoEscolar.aluno
package com.fateczl.sistemaDeGestaoEscolar.usuario.aluno;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

import com.fateczl.sistemaDeGestaoEscolar.escola.Escola;
import com.fateczl.sistemaDeGestaoEscolar.usuario.Role;
import com.fateczl.sistemaDeGestaoEscolar.usuario.responsavel.Responsavel;
import com.fateczl.sistemaDeGestaoEscolar.turma.Turma;
import com.fateczl.sistemaDeGestaoEscolar.usuario.Usuario;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToMany;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.experimental.SuperBuilder;

@Entity
@Table(name = "aluno")
@Getter
@Setter
@SuperBuilder
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
    private List<Turma> turmas;

    public Aluno(Long id, String nome, String email, String senha, boolean ativo, LocalDateTime dataCriacao, String matricula, LocalDate dataNascimento, Escola escola, Responsavel responsavel, List<Turma> turmas){
        super(id, nome, email, senha, Role.ALUNO, ativo, dataCriacao);
        this.matricula = matricula;
        this.dataNascimento = dataNascimento;
        this.escola = escola;
        this.responsavel = responsavel;
        this.turmas = turmas;
    }
}