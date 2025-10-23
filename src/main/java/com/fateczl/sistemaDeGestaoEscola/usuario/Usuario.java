package com.fateczl.sistemaDeGestaoEscola.usuario;

import java.time.LocalDateTime;

import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.MappedSuperclass;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.experimental.SuperBuilder;

@MappedSuperclass
@Getter
@Setter
@NoArgsConstructor
@SuperBuilder
abstract class Usuario {
	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long id;
	private String nome;
	private String email;
	private String senha;
	private boolean autenticacaoDupla;
	private LocalDateTime dataCriacao;
	
	@jakarta.persistence.PrePersist
	public void aoCriar() {
	    this.dataCriacao = LocalDateTime.now();
	}
}
