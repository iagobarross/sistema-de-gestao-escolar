package com.fateczl.sistemaDeGestaoEscolar.usuario.professor;

import org.springframework.stereotype.Component;
import java.util.List;
import java.util.stream.Collectors;

@Component
public class ProfessorMapper {

    public ProfessorResponseDTO toResponseDTO(Professor professor) {
        ProfessorResponseDTO dto = new ProfessorResponseDTO();

        dto.setId(professor.getId());
        dto.setNome(professor.getNome());
        dto.setEmail(professor.getEmail());
        dto.setDataCriacao(professor.getDataCriacao());
        dto.setEspecialidade(professor.getEspecialidade());

        if (professor.getEscola() != null) {
            dto.setEscolaId(professor.getEscola().getId());
            dto.setNomeEscola(professor.getEscola().getNome());
        }

        if (professor.getTurmas() != null) {
            List<String> nomesTurmas = professor.getTurmas().stream()
                    .map(t -> t.getSerie() + " (" + t.getTurno() + ")")
                    .collect(Collectors.toList());
            dto.setTurmas(nomesTurmas);
        }

        return dto;
    }

    public List<ProfessorResponseDTO> toResponseDTOList(List<Professor> professores) {
        return professores.stream().map(this::toResponseDTO).collect(Collectors.toList());
    }

    public Professor toEntity(ProfessorRequestDTO dto) {
        Professor professor = new Professor();
        professor.setNome(dto.getNome());
        professor.setEmail(dto.getEmail());
        professor.setSenha(dto.getSenha());
        professor.setEspecialidade(dto.getEspecialidade());
        return professor;
    }
}