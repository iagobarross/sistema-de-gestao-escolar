// Pacote: com.fateczl.sistemaDeGestaoEscolar.turma
package com.fateczl.sistemaDeGestaoEscolar.turma;

import com.fateczl.sistemaDeGestaoEscolar.aluno.Aluno;
// Importe outras entidades relacionadas se necessário (MatrizDisciplina, DiarioDeClasse)
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import java.util.List;

@Entity
@Table(name = "turmas")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(of = "id")
public class Turma {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private int ano;

    @Column(nullable = false, length = 50)
    private String serie;

    @Column(nullable = false, length = 50)
    private String turno; // (Manhã, Tarde, Noite)

    // Relacionamento N:M com Aluno (Turma é a dona da relação)
    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(name = "turma_alunos", // Nome da tabela de junção
            joinColumns = @JoinColumn(name = "turma_id"), inverseJoinColumns = @JoinColumn(name = "aluno_id"))
    private List<Aluno> alunos;

    // Relacionamento 1:N com MatrizDisciplina
    // @OneToMany(mappedBy = "turma", cascade = CascadeType.ALL, fetch =
    // FetchType.LAZY)
    // private List<MatrizDisciplina> matrizesDisciplinas;
}