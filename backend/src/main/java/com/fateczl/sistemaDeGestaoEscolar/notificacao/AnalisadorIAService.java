package com.fateczl.sistemaDeGestaoEscolar.notificacao;

import java.util.List;

import com.fateczl.sistemaDeGestaoEscolar.academico.nota.BoletimDisciplinaDTO;
import com.fateczl.sistemaDeGestaoEscolar.usuario.aluno.Aluno;

public interface AnalisadorIAService {

    String gerarNotificacao(Aluno aluno, List<BoletimDisciplinaDTO> boletim, List<String> problemas, String nomeTurma);
}
