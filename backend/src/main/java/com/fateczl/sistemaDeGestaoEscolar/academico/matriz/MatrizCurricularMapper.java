package com.fateczl.sistemaDeGestaoEscolar.academico.matriz;

import com.fateczl.sistemaDeGestaoEscolar.academico.aula.AulaRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.stream.Collectors;

@Component
@RequiredArgsConstructor
public class MatrizCurricularMapper {

    private final AulaRepository aulaRepository;

    public MatrizCurricularResponseDTO toDTO(MatrizCurricular m) {
        MatrizCurricularResponseDTO dto = new MatrizCurricularResponseDTO();
        dto.setId(m.getId());
        dto.setAno(m.getAno());
        dto.setCargaHorariaTotal(m.getCargaHorariaTotal());
        dto.setStatus(m.getStatus());

        dto.setTurmaId(m.getTurma().getId());
        dto.setNomeTurma(m.getTurma().getSerie() + " — " + m.getTurma().getTurno());

        dto.setDisciplinaId(m.getDisciplina().getId());
        dto.setNomeDisciplina(m.getDisciplina().getNome());

       dto.setProfessorId(m.getProfessor().getId());
       dto.setNomeProfessor(m.getProfessor().getNome());

        dto.setAulasRealizadas(
                aulaRepository.countByMatrizCurricularId(m.getId()));

        return dto;
    }

    public List<MatrizCurricularResponseDTO> toDTOList(List<MatrizCurricular> lista) {
        return lista.stream().map(this::toDTO).collect(Collectors.toList());
    }
}