package com.fateczl.sistemaDeGestaoEscolar.usuario.professor;

import java.time.LocalDateTime;
import java.util.List;

import com.fateczl.sistemaDeGestaoEscolar.escola.Escola;
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

@Entity
@Table(name = "professor")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class Professor extends Usuario {

    @Column(nullable = false, length = 100)
    private String especialidade;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "escola_id", nullable = false)
    private Escola escola;

    /*@ManyToMany(mappedBy = "professores", fetch = FetchType.LAZY)
    private List<Turma> turmas;*/

    public Professor(Long id, String nome, String email, String senha, boolean ativo, LocalDateTime dataCriacao,
            String especialidade, Escola escola) { //List<Turma> turmas
        super(id, nome, email, senha, ativo, dataCriacao);
        this.especialidade = especialidade;
        this.escola = escola;
        //this.turmas = turmas;
    }
}