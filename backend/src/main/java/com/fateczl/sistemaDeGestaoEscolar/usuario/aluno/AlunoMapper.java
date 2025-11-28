package com.fateczl.sistemaDeGestaoEscolar.usuario.aluno;

import org.springframework.stereotype.Component;
import java.util.List;
import java.util.stream.Collectors;

@Component
public class AlunoMapper {

    public AlunoResponseDTO toResponseDTO(Aluno aluno) {
        AlunoResponseDTO dto = new AlunoResponseDTO();

        // --- Dados do Usuario ---
        dto.setId(aluno.getId());
        dto.setNome(aluno.getNome());
        dto.setEmail(aluno.getEmail());
        dto.setDataCriacao(aluno.getDataCriacao());

        // --- Dados do Aluno ---
        dto.setMatricula(aluno.getMatricula());
        dto.setDataNascimento(aluno.getDataNascimento());

        // --- Dados de Relacionamento ---
        if (aluno.getEscola() != null) {
            dto.setEscolaId(aluno.getEscola().getId());
            dto.setNomeEscola(aluno.getEscola().getNome());
        }
        if (aluno.getResponsavel() != null) {
            dto.setResponsavelId(aluno.getResponsavel().getId());
            dto.setNomeResponsavel(aluno.getResponsavel().getNome());
        }
        if (aluno.getTurmas() != null) {
        	List<String> nomesTurmas = aluno.getTurmas().stream().map(t -> t.getSerie() + " (" + t.getTurno() + ")")
        			.collect(Collectors.toList());
        	dto.setTurmas(nomesTurmas);
        }

        return dto;
    }

    public List<AlunoResponseDTO> toResponseDTOList(List<Aluno> alunos) {
        return alunos.stream().map(this::toResponseDTO).collect(Collectors.toList());
    }

    public Aluno toEntity(AlunoRequestDTO dto) {
        Aluno aluno = new Aluno();

        // --- Dados do Usuario ---
        aluno.setNome(dto.getNome());
        aluno.setEmail(dto.getEmail());
        aluno.setSenha(dto.getSenha()); // A senha será criptografada no Service

        // --- Dados do Aluno ---
        aluno.setMatricula(dto.getMatricula());
        aluno.setDataNascimento(dto.getDataNascimento());

        // IDs de relacionamento (Escola e Responsavel)
        // NÃO são definidos aqui. O Service irá buscar as entidades
        // e associá-las ao Aluno antes de salvar.

        return aluno;
    }
}