package com.fateczl.sistemaDeGestaoEscolar.usuario.aluno;

import java.util.stream.Collectors;

import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.util.List;

@Component
public class AlunoMapper {

    public AlunoResponseDTO toResponseDTO(Aluno aluno) {
        AlunoResponseDTO dto = new AlunoResponseDTO();
        dto.setMatricula(aluno.getMatricula());
        dto.setNome(aluno.getNome());
        dto.setEmail(aluno.getEmail());
        dto.setDataNascimento(aluno.getDataNascimento().toString());
        dto.setResponsavelId(aluno.getResponsavelId());
        return dto;
    }

    public Aluno toEntity(AlunoRequestDTO dto) {
        Aluno aluno = new Aluno();
        aluno.setMatricula(dto.getMatricula());
        aluno.setNome(dto.getNome());
        aluno.setEmail(dto.getEmail());
        aluno.setDataNascimento(LocalDate.parse(dto.getDataNascimento()));
        aluno.setResponsavelId(dto.getResponsavelId());
        return aluno;
    }

    public List<AlunoResponseDTO> toResponseDTOList(List<Aluno> alunos) {
        return alunos.stream().map(this::toResponseDTO).collect(Collectors.toList());
    }
}
