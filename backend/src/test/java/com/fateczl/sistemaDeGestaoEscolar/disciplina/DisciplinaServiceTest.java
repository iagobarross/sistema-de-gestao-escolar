package com.fateczl.sistemaDeGestaoEscolar.disciplina;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import com.fateczl.sistemaDeGestaoEscolar.config.exception.BusinessException;

@ExtendWith(MockitoExtension.class)
public class DisciplinaServiceTest {

    @Mock
    private DisciplinaRepository disciplinaRepository;

    @InjectMocks
    private DisciplinaServiceImpl disciplinaService;

    private Disciplina disciplinaExemplo;

    @BeforeEach
    void setUp() {
        disciplinaExemplo = new Disciplina();
        disciplinaExemplo.setCodigo("JAVA01");
        disciplinaExemplo.setNome("Java Básico");
        disciplinaExemplo.setNotaMinima(7.0);
    }

    @Test
    public void deveCriarDisciplinaComSucesso() {
        // Arrange: Quando procurar pelo código, diz que não existe
        when(disciplinaRepository.existsByCodigo("JAVA01")).thenReturn(false);
        when(disciplinaRepository.save(any(Disciplina.class))).thenReturn(disciplinaExemplo);

        // Act
        Disciplina salva = disciplinaService.create(disciplinaExemplo);

        // Assert
        assertNotNull(salva);
        assertEquals("JAVA01", salva.getCodigo());
        verify(disciplinaRepository, times(1)).save(disciplinaExemplo);
    }

    @Test
    public void deveLancarErro_QuandoCodigoJaExistir() {
        // Arrange: Simula que o código já está no banco
        when(disciplinaRepository.existsByCodigo("JAVA01")).thenReturn(true);

        // Act & Assert: Verifica se a exceção customizada é lançada
        BusinessException exception = assertThrows(BusinessException.class, () -> {
            disciplinaService.create(disciplinaExemplo);
        });

        assertEquals("Disciplina já cadastrada.", exception.getMessage());
        verify(disciplinaRepository, never()).save(any());
    }
}