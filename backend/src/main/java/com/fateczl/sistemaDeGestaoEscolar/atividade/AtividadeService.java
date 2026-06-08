package com.fateczl.sistemaDeGestaoEscolar.atividade;

import java.util.List;

public interface AtividadeService {
    Atividade criar(AtividadeRequestDTO dto);
    List<Atividade> findByMatriz(Long matrizId);
    List<Atividade> findByTurma(Long turmaId);
    List<Atividade> findByProfessor(Long professorId);
    void deletar(Long id);
    AtividadeEntrega entregar(Long alunoId, AtividadeEntregaRequestDTO dto);
    AtividadeEntrega findEntregaById(Long entregaId);
    List<AtividadeEntrega> findEntregasByAtividade(Long atividadeId);
    List<AtividadeEntrega> findEntregasByAluno(Long alunoId);
    List<AtividadeAlunoStatusDTO> getStatusAlunos(Long atividadeId);
}