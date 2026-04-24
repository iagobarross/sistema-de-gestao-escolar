package com.fateczl.sistemaDeGestaoEscolar.notificacao;

import org.springframework.stereotype.Component;
import java.util.List;
import java.util.stream.Collectors;

@Component
public class NotificacaoMapper {

    public NotificacaoResponseDTO toDTO(Notificacao n) {
        NotificacaoResponseDTO dto = new NotificacaoResponseDTO();
        dto.setId(n.getId());
        dto.setConteudoIA(n.getConteudoIA());
        dto.setResumo(n.getResumo());
        dto.setTipo(n.getTipo());
        dto.setStatus(n.getStatus());
        dto.setCriadaEm(n.getCriadaEm());
        dto.setEncaminhadaEm(n.getEncaminhadaEm());

        if (n.getAluno() != null) {
            dto.setAlunoId(n.getAluno().getId());
            dto.setNomeAluno(n.getAluno().getNome());
            dto.setMatriculaAluno(n.getAluno().getMatricula());
            
            if (n.getAluno().getTurmas() != null && !n.getAluno().getTurmas().isEmpty()) {
                var turma = n.getAluno().getTurmas().get(0);
                dto.setNomeTurma(turma.getSerie() + " — " + turma.getTurno());
            }
        }

        return dto;
    }

    public List<NotificacaoResponseDTO> toDTOList(List<Notificacao> lista) {
        return lista.stream().map(this::toDTO).collect(Collectors.toList());
    }
}