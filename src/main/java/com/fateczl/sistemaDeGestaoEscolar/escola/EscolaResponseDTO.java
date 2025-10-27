package com.fateczl.sistemaDeGestaoEscolar.escola;

import lombok.Data;

@Data
public class EscolaResponseDTO {
	private Long id;
	private String codigo;
	private String nome;
	private String cnpj;
	private String endereco;
	
}
