// Pacote: com.fateczl.sistemaDeGestaoEscolar.turma
package com.fateczl.sistemaDeGestaoEscolar.turma;

import org.springframework.stereotype.Component;
import java.util.List;
import java.util.stream.Collectors;

@Component
public class TurmaMapper {

    public TurmaResponseDTO toResponseDTO(Turma turma) {
        TurmaResponseDTO dto = new TurmaResponseDTO();
        dto.setId(turma.getId());
        dto.setAno(turma.getAno());
        dto.setSerie(turma.getSerie());
        dto.setTurno(turma.getTurno());
        return dto;
    }

    public List<TurmaResponseDTO> toResponseDTOList(List<Turma> turmas) {
        return turmas.stream().map(this::toResponseDTO).collect(Collectors.toList());
    }

    public Turma toEntity(TurmaRequestDTO dto) {
        Turma turma = new Turma();
        turma.setAno(dto.getAno());
        turma.setSerie(dto.getSerie());
        turma.setTurno(dto.getTurno());
        return turma;
    }
}