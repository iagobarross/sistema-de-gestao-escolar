// Pacote: com.fateczl.sistemaDeGestaoEscolar.responsavel
package com.fateczl.sistemaDeGestaoEscolar.responsavel;


import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import java.util.List;

import com.fateczl.sistemaDeGestaoEscolar.usuario.Usuario;
import com.fateczl.sistemaDeGestaoEscolar.usuario.aluno.Aluno;

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
}