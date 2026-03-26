package com.fateczl.sistemaDeGestaoEscolar.academico.avaliacao;

import java.time.LocalDate;

import com.fateczl.sistemaDeGestaoEscolar.academico.TipoAvaliacao;
import com.fateczl.sistemaDeGestaoEscolar.academico.matriz.MatrizCurricular;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "avaliacao")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(of = "id")
public class Avaliacao {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "matriz_curricular_id", nullable = false)
    private MatrizCurricular matrizCurricular;

    @Column(nullable = false, length = 150)
    private String titulo;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private TipoAvaliacao tipo;

    @Column(nullable = false)
    private LocalDate dataAplicacao;
    
    @Column(nullable = false)
    private double notaMaxima = 10.0;

    @Column(nullable = false)
    private int bimestre;

    @Column(nullable = false)
    private double peso = 1.0;
    
}
