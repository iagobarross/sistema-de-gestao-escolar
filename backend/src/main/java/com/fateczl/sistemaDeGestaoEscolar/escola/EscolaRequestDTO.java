package com.fateczl.sistemaDeGestaoEscolar.escola;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;
import org.hibernate.validator.constraints.br.CNPJ;

@Data
public class EscolaRequestDTO {
	@NotBlank(message = "Código é obrigatório")
	private String codigo;
	
	@NotBlank(message = "Nome é obrigatório")
	private String nome;
	
	@NotBlank(message = "CNPJ é obrigatório")
	@CNPJ(message= " CNPJ em formato inválido")
	private String cnpj;
	
	@NotBlank(message = "Endereço é obrigatório")
	private String endereco;
}
