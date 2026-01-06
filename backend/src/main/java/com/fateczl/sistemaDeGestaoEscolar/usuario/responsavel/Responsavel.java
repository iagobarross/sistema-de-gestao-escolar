// Pacote: com.fateczl.sistemaDeGestaoEscolar.responsavel
package com.fateczl.sistemaDeGestaoEscolar.responsavel;


import java.time.LocalDateTime;
import java.util.List;

import com.fateczl.sistemaDeGestaoEscolar.usuario.Usuario;
import com.fateczl.sistemaDeGestaoEscolar.usuario.aluno.Aluno;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "responsavel")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class Responsavel extends Usuario{

    @Column(nullable = false, unique = true, length = 11)
    private String cpf;

    @Column(length = 20)
    private String telefone;

    // Relacionamento 1:N com Aluno
    @OneToMany(mappedBy = "responsavel", fetch = FetchType.LAZY)
    private List<Aluno> alunos;

    public Responsavel(Long id, String nome, String email, String senha, boolean ativo, LocalDateTime dataCriacao, String cpf, String telefone, List<Aluno> alunos){
        super(id, nome, email, senha, ativo, dataCriacao);
        this.cpf = cpf;
        this.telefone = telefone;
        this.alunos = alunos;
    }

}