package com.fateczl.sistemaDeGestaoEscolar.academico.avaliacao;

import com.fateczl.sistemaDeGestaoEscolar.academico.nota.NotaRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.stream.Collectors;

@Component
@RequiredArgsConstructor
public class AvaliacaoMapper {

    private final NotaRepository notaRepository;

    public AvaliacaoResponseDTO toDTO(Avaliacao av) {
        AvaliacaoResponseDTO dto = new AvaliacaoResponseDTO();
        dto.setId(av.getId());
        dto.setMatrizCurricularId(av.getMatrizCurricular().getId());
        dto.setTitulo(av.getTitulo());
        dto.setTipo(av.getTipo());
        dto.setDataAplicacao(av.getDataAplicacao());
        dto.setNotaMaxima(av.getNotaMaxima());
        dto.setBimestre(av.getBimestre());
        dto.setPeso(av.getPeso());

        dto.setNomeDisciplina(
                av.getMatrizCurricular().getDisciplina().getNome());
        dto.setNomeTurma(
                av.getMatrizCurricular().getTurma().getSerie()
                + " — "
                + av.getMatrizCurricular().getTurma().getTurno());

        dto.setTotalNotasLancadas(
                notaRepository.countByAvaliacaoId(av.getId()));
        dto.setTotalAlunos(
                av.getMatrizCurricular().getTurma().getAlunos().size());

        return dto;
    }

    public List<AvaliacaoResponseDTO> toDTOList(List<Avaliacao> lista) {
        return lista.stream().map(this::toDTO).collect(Collectors.toList());
    }
}