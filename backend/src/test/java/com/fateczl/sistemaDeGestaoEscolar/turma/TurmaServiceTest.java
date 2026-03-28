package com.fateczl.sistemaDeGestaoEscolar.turma;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

import java.util.ArrayList;
import java.util.Optional;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import com.fateczl.sistemaDeGestaoEscolar.config.exception.BusinessException;
import com.fateczl.sistemaDeGestaoEscolar.usuario.aluno.Aluno;
import com.fateczl.sistemaDeGestaoEscolar.usuario.aluno.AlunoRepository;

@ExtendWith(MockitoExtension.class)
public class TurmaServiceTest {

    @Mock
    private TurmaRepository turmaRepository;

    @Mock
    private AlunoRepository alunoRepository;

    @InjectMocks
    private TurmaServiceImpl turmaService;

    @Test
    public void deveLancarErro_QuandoCriarTurmaDuplicada() {
        // Arrange
        Turma turma = new Turma(null, 2024, "3C", "Noite", null);
        when(turmaRepository.existsByAnoAndSerieAndTurno(2024, "3C", "Noite")).thenReturn(true);

        // Act & Assert
        BusinessException erro = assertThrows(BusinessException.class, () -> turmaService.create(turma));
        assertEquals("Esta turma (Ano, Série, Turno) já está cadastrada.", erro.getMessage());
        verify(turmaRepository, never()).save(any());
    }

    @Test
    public void deveLancarErro_QuandoAdicionarAlunoJaMatriculado() {
        // Arrange
        Long turmaId = 1L;
        Long alunoId = 10L;

        Aluno aluno = new Aluno();
        aluno.setId(alunoId);

        Turma turma = new Turma();
        turma.setId(turmaId);
        turma.setAlunos(new ArrayList<>());
        turma.getAlunos().add(aluno); // Aluno já está na lista

        when(turmaRepository.findById(turmaId)).thenReturn(Optional.of(turma));
        when(alunoRepository.findById(alunoId)).thenReturn(Optional.of(aluno));

        // Act & Assert
        BusinessException erro = assertThrows(BusinessException.class,
                () -> turmaService.adicionarAluno(turmaId, alunoId));
        assertEquals("Aluno já está matriculado nesta turma.", erro.getMessage());
    }
}