package com.fateczl.sistemaDeGestaoEscolar.atividade;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

public interface AtividadeEntregaRepository extends JpaRepository<AtividadeEntrega, Long>{
    
    List<AtividadeEntrega> findByAtividadeId(Long atividadeId);
    Optional<AtividadeEntrega> findByAtividadeIdAndAlunoId(Long atividadeId, Long alunoId);
    List<AtividadeEntrega> findByAlunoId(Long alunoId);
    long countByAtividadeIdAndStatus(Long atividadeId, StatusEntrega status);
}
