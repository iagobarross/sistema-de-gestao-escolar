package com.fateczl.sistemaDeGestaoEscolar.academico.aula;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import com.fateczl.sistemaDeGestaoEscolar.academico.matriz.MatrizCurricular;
import com.fateczl.sistemaDeGestaoEscolar.academico.matriz.MatrizCurricularRepository;
import com.fateczl.sistemaDeGestaoEscolar.config.exception.BusinessException;
import java.time.LocalDate;
import java.util.Optional;

@ExtendWith(MockitoExtension.class)
public class AulaServiceTest {

    @Mock
    private AulaRepository aulaRepository;

    @Mock
    private MatrizCurricularRepository matrizRepository;

    @InjectMocks
    private AulaServiceImpl aulaService;

    @Test
    public void deveLancarErro_QuandoJaExistirAulaNaMesmaData() {
        // Arrange
        AulaRequestDTO dto = new AulaRequestDTO();
        dto.setMatrizCurricularId(1L);
        dto.setData(LocalDate.now());
        dto.setConteudo("Teste");

        when(matrizRepository.findById(1L)).thenReturn(Optional.of(new MatrizCurricular()));
        when(aulaRepository.findByMatrizCurricularIdAndData(1L, dto.getData()))
                .thenReturn(Optional.of(new Aula()));

        // Act & Assert
        BusinessException exception = assertThrows(BusinessException.class, () -> {
            aulaService.registrar(dto);
        });

        assertEquals("Já existe uma aula registrada nessa data para essa turma/disciplina.", exception.getMessage());
    }
}