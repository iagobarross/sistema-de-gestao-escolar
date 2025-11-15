package com.fateczl.sistemaDeGestaoEscolar.turma;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public interface TurmaService {

    public List<Turma> findAll();

    public Turma findById(Long id);

    public Turma create(Turma turma);

    public Turma update(Long id, Turma dadosAtualizacao);

    public void deleteById(Long id);

    @Transactional
    public void adicionarAluno(Long turmaId, Long alunoId);

    @Transactional
    public void removerAluno(Long turmaId, Long alunoId);
}