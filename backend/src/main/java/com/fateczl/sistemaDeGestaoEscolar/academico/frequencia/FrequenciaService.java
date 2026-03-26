package com.fateczl.sistemaDeGestaoEscolar.academico.frequencia;

import java.util.List;

public interface FrequenciaService {
    List<Frequencia> lancarChamada(LancarChamadaRequestDTO dto);
    Frequencia corrigirPresenca(Long frequenciaId, boolean presente, String justificativa);
    List<Frequencia> findByAula(Long aulaId);
    Double calcularPercentualPresenca(Long matrizId, Long alunoId);
}

