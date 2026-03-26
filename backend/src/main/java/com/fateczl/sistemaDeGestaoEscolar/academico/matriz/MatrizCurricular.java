package com.fateczl.sistemaDeGestaoEscolar.academico.matriz;

import com.fateczl.sistemaDeGestaoEscolar.academico.StatusMatriz;
import com.fateczl.sistemaDeGestaoEscolar.disciplina.Disciplina;
import com.fateczl.sistemaDeGestaoEscolar.turma.Turma;
import com.fateczl.sistemaDeGestaoEscolar.usuario.funcionario.Funcionario;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;
import lombok.AllArgsConstructor;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "matriz_curricular",
uniqueConstraints = @UniqueConstraint(
    name = "uk_matriz_turma_disciplina_ano",
    columnNames = {"turma_id", "disciplina_id", "ano"}))
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@EqualsAndHashCode(of = "id")
public class MatrizCurricular {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "turma_id", nullable = false)
    private Turma turma;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "disciplina_id", nullable = false)
    private Disciplina disciplina;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "professor_id", nullable = false)
    private Funcionario professor;

    @Column(nullable = false)
    private int ano;

    @Column(nullable = false)
    private int cargaHorariaTotal;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private StatusMatriz status = StatusMatriz.ATIVA;

    
}
