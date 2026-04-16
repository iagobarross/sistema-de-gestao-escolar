package com.fateczl.sistemaDeGestaoEscolar.academico.matriz;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import com.fateczl.sistemaDeGestaoEscolar.config.exception.BusinessException;

@ExtendWith(MockitoExtension.class)
public class MatrizCurricularServiceTest {

    @Mock
    private MatrizCurricularRepository matrizRepository;

    @InjectMocks
    private MatrizCurricularServiceImpl service;

    @Test
    public void deveLancarErro_QuandoDisciplinaJaVinculadaNaTurmaEAno() {
        // Arrange
        MatrizCurricularRequestDTO dto = new MatrizCurricularRequestDTO();
        dto.setTurmaId(1L);
        dto.setDisciplinaId(2L);
        dto.setAno(2026);

        when(matrizRepository.existsByTurmaIdAndDisciplinaIdAndAno(1L, 2L, 2026))
                .thenReturn(true);

        // Act & Assert
        BusinessException exception = assertThrows(BusinessException.class, () -> {
            service.create(dto);
        });

        assertEquals("Essa disciplina já está vinculada a essa turma nesse ano.", exception.getMessage());
        verify(matrizRepository, never()).save(any());
    }
}