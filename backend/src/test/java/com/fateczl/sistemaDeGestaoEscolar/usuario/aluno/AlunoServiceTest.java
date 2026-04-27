package com.fateczl.sistemaDeGestaoEscolar.usuario.aluno;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

import java.util.Optional;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.crypto.password.PasswordEncoder;
import com.fateczl.sistemaDeGestaoEscolar.config.exception.BusinessException;
import com.fateczl.sistemaDeGestaoEscolar.escola.Escola;
import com.fateczl.sistemaDeGestaoEscolar.escola.EscolaRepository;
import com.fateczl.sistemaDeGestaoEscolar.usuario.responsavel.Responsavel;
import com.fateczl.sistemaDeGestaoEscolar.usuario.responsavel.ResponsavelRepository;

@ExtendWith(MockitoExtension.class)
public class AlunoServiceTest {

    @Mock
    private AlunoRepository alunoRepository;
    @Mock
    private EscolaRepository escolaRepository;
    @Mock
    private ResponsavelRepository responsavelRepository;
    @Mock
    private PasswordEncoder passwordEncoder;

    @InjectMocks
    private AlunoServiceImpl alunoService;

    @Test
    public void deveLancarErro_QuandoMatriculaJaExiste() {
        // Arrange
        String matriculaExistente = "2024001";
        Aluno novoAluno = new Aluno();
        novoAluno.setMatricula(matriculaExistente);

        when(alunoRepository.existsByMatricula(matriculaExistente)).thenReturn(true);

        // Act & Assert
        BusinessException erro = assertThrows(BusinessException.class, () -> alunoService.create(novoAluno, 1L, 1L));
        assertEquals("Matrícula já cadastrada.", erro.getMessage());
        verify(alunoRepository, never()).save(any());
    }

    @Test
    public void deveCriptografarSenha_AoCriarNovoAluno() {
        // Arrange
        Aluno aluno = new Aluno();
        aluno.setSenha("senha123");

        when(escolaRepository.findById(1L)).thenReturn(Optional.of(new Escola()));
        when(responsavelRepository.findById(1L)).thenReturn(Optional.of(new Responsavel()));
        when(passwordEncoder.encode("senha123")).thenReturn("senhaCripto");
        when(alunoRepository.save(any())).thenAnswer(i -> i.getArguments()[0]);

        // Act
        Aluno salvo = alunoService.create(aluno, 1L, 1L);

        // Assert
        assertEquals("senhaCripto", salvo.getSenha());
        verify(passwordEncoder).encode("senha123");
    }
}