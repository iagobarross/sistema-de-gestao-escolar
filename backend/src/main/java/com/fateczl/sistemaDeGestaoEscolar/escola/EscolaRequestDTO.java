package com.fateczl.sistemaDeGestaoEscolar.escola;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class EscolaRequestDTO {
	@NotBlank(message = "Código é obrigatório")
	private String codigo;
	
	@NotBlank(message = "Nome é obrigatório")
	private String nome;
	
	@NotBlank(message = "CNPJ é obrigatório")
	@Size(min = 14, max = 14, message = "CNPJ deve ter 14 dígitos")
	private String cnpj;
	
	@NotBlank(message = "Endereço é obrigatório")
	private String endereco;
}
