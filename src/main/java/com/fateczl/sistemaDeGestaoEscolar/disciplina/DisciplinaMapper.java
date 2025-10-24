package com.fateczl.sistemaDeGestaoEscolar.disciplina;

import java.util.List;
import java.util.stream.Collectors;

import org.springframework.stereotype.Component;

@Component
public class DisciplinaMapper {
    
    public DisciplinaResponseDTO toResponseDTO(Disciplina disciplina){
        DisciplinaResponseDTO dto = new DisciplinaResponseDTO();
        dto.setId(disciplina.getId());
        dto.setNome(disciplina.getNome());
        dto.setDescricao(disciplina.getDescricao());
        dto.setNotaMinima(disciplina.getNotaMinima());
        dto.setCargaHoraria(disciplina.getCargaHoraria());
        return dto;
    }

    public List<DisciplinaResponseDTO> toResponseDTOList(List<Disciplina> disciplinas){
        return disciplinas.stream().map(this::toResponseDTO).collect(Collectors.toList());
    }

    public Disciplina toEntity(DisciplinaRequestDTO dto){
        Disciplina disciplina = new Disciplina();
        disciplina.setNome(dto.getNome());
        disciplina.setDescricao(dto.getDescricao());
        disciplina.setNotaMinima(dto.getNotaMinima());
        disciplina.setCargaHoraria(dto.getCargaHoraria());
        return disciplina;
    }
}
