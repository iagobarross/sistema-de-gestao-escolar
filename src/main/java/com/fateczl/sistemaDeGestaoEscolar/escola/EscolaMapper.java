package com.fateczl.sistemaDeGestaoEscolar.escola;

import java.util.List;
import java.util.stream.Collectors;

import org.springframework.stereotype.Component;

@Component
public class EscolaMapper {
	
	public EscolaResponseDTO toResponseDTO(Escola escola) {
		EscolaResponseDTO dto = new EscolaResponseDTO();
		dto.setId(escola.getId());
		dto.setNome(escola.getNome());
		dto.setCodigo(escola.getCodigo());
		dto.setEndereco(escola.getEndereco());
		return dto;
	}
	
	public List<EscolaResponseDTO> toResponseDTOList(List<Escola> escolas){
		return escolas.stream().map(this::toResponseDTO).collect(Collectors.toList());
	}
	
	public Escola toEntity(EscolaRequestDTO dto) {
		Escola escola = new Escola();
		escola.setNome(dto.getNome());
		escola.setCodigo(dto.getCodigo());
		escola.setCnpj(dto.getCnpj());
		escola.setEndereco(dto.getEndereco());
		return escola;
	}
}
