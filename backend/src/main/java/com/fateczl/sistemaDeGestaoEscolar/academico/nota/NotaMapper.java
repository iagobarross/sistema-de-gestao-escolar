package com.fateczl.sistemaDeGestaoEscolar.academico.nota;

import org.springframework.stereotype.Component;

import java.util.List;
import java.util.stream.Collectors;

@Component
public class NotaMapper {

    public NotaResponseDTO toDTO(Nota nota) {
        NotaResponseDTO dto = new NotaResponseDTO();
        dto.setId(nota.getId());
        dto.setAlunoId(nota.getAluno().getId());
        dto.setNomeAluno(nota.getAluno().getNome());
        dto.setMatriculaAluno(nota.getAluno().getMatricula());
        dto.setValor(nota.getValor());
        dto.setObservacao(nota.getObservacao());
        dto.setLancadaEm(nota.getLancadaEm());

        dto.setAvaliacaoId(nota.getAvaliacao().getId());
        dto.setTituloAvaliacao(nota.getAvaliacao().getTitulo());
        dto.setBimestre(nota.getAvaliacao().getBimestre());
        dto.setNotaMaxima(nota.getAvaliacao().getNotaMaxima());

        return dto;
    }

    public List<NotaResponseDTO> toDTOList(List<Nota> lista) {
        return lista.stream().map(this::toDTO).collect(Collectors.toList());
    }
}