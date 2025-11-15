// Pacote: com.fateczl.sistemaDeGestaoEscolar.usuario
package com.fateczl.sistemaDeGestaoEscolar.usuario;

import jakarta.persistence.Column;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.MappedSuperclass; // <-- ESSA ANOTAÇÃO É A CHAVE
import lombok.AllArgsConstructor;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

@MappedSuperclass // Diz ao JPA para incluir os campos desta classe nas tabelas filhas
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(of = "id")
public abstract class Usuario { // Recomenda-se ser abstrata

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long id;

	@Column(nullable = false, length = 150)
	private String nome;

	@Column(nullable = false, unique = true, length = 100)
	private String email;

	@Column(nullable = false)
	private String senha;

	// Use um valor default ou defina-o no construtor
	private boolean ativo = true;

	private LocalDateTime dataCriacao = LocalDateTime.now();

	// Outros campos comuns (como autenticacao/perfil)
}