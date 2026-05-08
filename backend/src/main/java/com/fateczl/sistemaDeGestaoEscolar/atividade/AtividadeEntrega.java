package com.fateczl.sistemaDeGestaoEscolar.atividade;

import java.time.LocalDateTime;

import com.fateczl.sistemaDeGestaoEscolar.usuario.aluno.Aluno;

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
@Table(name = "atividade_entrega",
    uniqueConstraints = @UniqueConstraint(columnNames = {"atividade_id", "aluno_id"}))
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(of = "id")
public class AtividadeEntrega {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "atividade_id", nullable = false)
    private Atividade atividade;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "aluno_id", nullable = false)
    private Aluno aluno;

    @Column(columnDefinition = "TEXT")
    private String conteudo;

    private LocalDateTime entregueEm;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private StatusEntrega status = StatusEntrega.PENDENTE;
}
