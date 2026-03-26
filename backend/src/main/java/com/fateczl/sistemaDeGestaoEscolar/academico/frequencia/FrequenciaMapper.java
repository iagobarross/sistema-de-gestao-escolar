package com.fateczl.sistemaDeGestaoEscolar.academico.frequencia;

import org.springframework.stereotype.Component;

import java.util.List;
import java.util.stream.Collectors;

@Component
public class FrequenciaMapper {

    public FrequenciaResponseDTO toDTO(Frequencia f) {
        FrequenciaResponseDTO dto = new FrequenciaResponseDTO();
        dto.setId(f.getId());
        dto.setAulaId(f.getAula().getId());
        dto.setAlunoId(f.getAluno().getId());
        dto.setNomeAluno(f.getAluno().getNome());
        dto.setMatriculaAluno(f.getAluno().getMatricula());
        dto.setPresente(f.isPresente());
        dto.setJustificativa(f.getJustificativa());
        return dto;
    }

    public List<FrequenciaResponseDTO> toDTOList(List<Frequencia> lista) {
        return lista.stream().map(this::toDTO).collect(Collectors.toList());
    }
}