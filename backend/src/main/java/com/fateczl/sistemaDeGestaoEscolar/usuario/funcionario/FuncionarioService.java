package com.fateczl.sistemaDeGestaoEscolar.usuario.funcionario;

import java.util.List;

public interface FuncionarioService {
    List<Funcionario> findAll();
    Funcionario findById(Long id);
    Funcionario create(Funcionario funcionarioMapeado, Long escolaId);
    Funcionario update(Long id, Funcionario dadosAtualizacao, Long escolaId);
    void deleteById(Long id);
}