package com.fateczl.sistemaDeGestaoEscolar.academico.aula;

import com.fateczl.sistemaDeGestaoEscolar.academico.frequencia.FrequenciaRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.stream.Collectors;

@Component
@RequiredArgsConstructor
public class AulaMapper {

    private final FrequenciaRepository frequenciaRepository;

    public AulaResponseDTO toDTO(Aula aula) {
        AulaResponseDTO dto = new AulaResponseDTO();
        dto.setId(aula.getId());
        dto.setMatrizCurricularId(aula.getMatrizCurricular().getId());
        dto.setData(aula.getData());
        dto.setConteudo(aula.getConteudo());
        dto.setNumeroAula(aula.getNumeroAula());

        dto.setNomeDisciplina(
                aula.getMatrizCurricular().getDisciplina().getNome());
        dto.setNomeTurma(
                aula.getMatrizCurricular().getTurma().getSerie()
                + " — "
                + aula.getMatrizCurricular().getTurma().getTurno());

        dto.setChamadaLancada(
                !frequenciaRepository.findByAulaId(aula.getId()).isEmpty());

        return dto;
    }

    public List<AulaResponseDTO> toDTOList(List<Aula> lista) {
        return lista.stream().map(this::toDTO).collect(Collectors.toList());
    }
}