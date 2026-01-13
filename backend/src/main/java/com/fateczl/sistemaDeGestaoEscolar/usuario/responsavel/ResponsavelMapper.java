package com.fateczl.sistemaDeGestaoEscolar.usuario.responsavel;

import org.springframework.stereotype.Component;
import java.util.List;
import java.util.stream.Collectors;

@Component
public class ResponsavelMapper {

    public ResponsavelResponseDTO toResponseDTO(Responsavel responsavel) {
        ResponsavelResponseDTO dto = new ResponsavelResponseDTO();
        dto.setId(responsavel.getId());
        dto.setNome(responsavel.getNome());
        dto.setCpf(responsavel.getCpf());
        dto.setTelefone(responsavel.getTelefone());
        dto.setEmail(responsavel.getEmail());
        return dto;
    }

    public List<ResponsavelResponseDTO> toResponseDTOList(List<Responsavel> responsaveis) {
        return responsaveis.stream().map(this::toResponseDTO).collect(Collectors.toList());
    }

    public Responsavel toEntity(ResponsavelRequestDTO dto) {
        Responsavel responsavel = new Responsavel();
        responsavel.setNome(dto.getNome());
        responsavel.setCpf(dto.getCpf());
        responsavel.setEmail(dto.getEmail());
        responsavel.setSenha(dto.getSenha());
        responsavel.setTelefone(dto.getTelefone());
        return responsavel;
    }
}