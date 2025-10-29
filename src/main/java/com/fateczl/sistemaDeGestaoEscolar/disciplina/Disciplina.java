package com.fateczl.sistemaDeGestaoEscolar.disciplina;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name="disciplina")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(of="id")
public class Disciplina {
    @Id
	@GeneratedValue(strategy=GenerationType.IDENTITY)
	@Column(name="disciplina_id")
	private Long id;
    @Column(unique = true, nullable = false, length = 20)
    private String codigo;
    private String nome;
    private String descricao;
    private double notaMinima;
    private int cargaHoraria;
}
