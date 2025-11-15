package com.fateczl.sistemaDeGestaoEscolar.usuario.aluno;

import java.util.List;

public interface AlunoService {

    public List<Aluno> findAll();

    public Aluno findById(Long id);

    public Aluno create(Aluno alunoMapeado, Long escolaId, Long responsavelId);

    public Aluno update(Long id, Aluno dadosAtualizacao, Long escolaId, Long responsavelId);

    public void deleteById(Long id);
}