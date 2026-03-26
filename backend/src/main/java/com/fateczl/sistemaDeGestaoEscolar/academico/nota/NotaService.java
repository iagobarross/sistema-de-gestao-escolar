package com.fateczl.sistemaDeGestaoEscolar.academico.nota;

import java.util.List;

public interface NotaService {
    List<Nota> lancarNotas(LancarNotasRequestDTO dto);
    Nota corrigirNota(Long notaId, double novoValor, String observacao);
    List<Nota> findByAvaliacao(Long avaliacaoId);
    List<BoletimDisciplinaDTO> gerarBoletim(Long alunoId, int ano);
}
