package com.fateczl.sistemaDeGestaoEscolar.academico.frequencia;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import com.fateczl.sistemaDeGestaoEscolar.academico.aula.Aula;
import com.fateczl.sistemaDeGestaoEscolar.academico.aula.AulaRepository;
import com.fateczl.sistemaDeGestaoEscolar.config.exception.BusinessException;
import java.util.Collections;
import java.util.Optional;
import java.util.List;

@ExtendWith(MockitoExtension.class)
public class FrequenciaServiceTest {

    @Mock
    private FrequenciaRepository frequenciaRepository;

    @Mock
    private AulaRepository aulaRepository;

    @InjectMocks
    private FrequenciaServiceImpl frequenciaService;

    @Test
    public void deveLancarExcecao_QuandoChamadaJaFoiLancada() {
        // Arrange
        Long aulaId = 1L;
        LancarChamadaRequestDTO dto = new LancarChamadaRequestDTO();
        dto.setAulaId(aulaId);

        when(aulaRepository.findById(aulaId)).thenReturn(Optional.of(new Aula()));
        // Simula que já existem registros de frequência para esta aula
        when(frequenciaRepository.findByAulaId(aulaId)).thenReturn(List.of(new Frequencia()));

        // Act & Assert
        assertThrows(BusinessException.class, () -> {
            frequenciaService.lancarChamada(dto);
        });

        verify(frequenciaRepository, never()).saveAll(any());
    }
}