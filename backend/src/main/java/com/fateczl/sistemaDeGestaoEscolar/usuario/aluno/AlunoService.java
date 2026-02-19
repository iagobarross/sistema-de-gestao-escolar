package com.fateczl.sistemaDeGestaoEscolar.usuario.aluno;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;


public interface AlunoService {

    public Page<Aluno> findAll(Pageable pageable, String nome, String matricula, Long escolaId);

    public Aluno findById(Long id);

    public Aluno create(Aluno alunoMapeado, Long escolaId, Long responsavelId);

    public Aluno update(Long id, Aluno dadosAtualizacao, Long escolaId, Long responsavelId);

    public void deleteById(Long id);
}