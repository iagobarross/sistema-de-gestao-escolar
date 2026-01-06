package com.fateczl.sistemaDeGestaoEscolar.usuario.professor;

import java.util.List;

public interface ProfessorService {

    List<Professor> findAll();

    Professor findById(Long id);

    Professor create(Professor professorMapeado, Long escolaId);

    Professor update(Long id, Professor dadosAtualizacao, Long escolaId);

    void deleteById(Long id);
}