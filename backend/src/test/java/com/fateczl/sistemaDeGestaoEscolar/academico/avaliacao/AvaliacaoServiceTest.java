package com.fateczl.sistemaDeGestaoEscolar.academico.avaliacao;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import com.fateczl.sistemaDeGestaoEscolar.academico.matriz.MatrizCurricular;
import com.fateczl.sistemaDeGestaoEscolar.academico.matriz.MatrizCurricularRepository;
import com.fateczl.sistemaDeGestaoEscolar.academico.TipoAvaliacao;
import java.util.Optional;

@ExtendWith(MockitoExtension.class)
public class AvaliacaoServiceTest {

    @Mock
    private AvaliacaoRepository avaliacaoRepository;

    @Mock
    private MatrizCurricularRepository matrizRepository;

    @InjectMocks
    private AvaliacaoServiceImpl avaliacaoService;

    @Test
    public void deveCriarAvaliacaoComSucesso() {
        // Arrange
        AvaliacaoRequestDTO dto = new AvaliacaoRequestDTO();
        dto.setMatrizCurricularId(1L);
        dto.setTitulo("Avaliação de Java");
        dto.setBimestre(1);
        dto.setNotaMaxima(10.0);
        dto.setTipo(TipoAvaliacao.PROVA);

        MatrizCurricular matriz = new MatrizCurricular();
        matriz.setId(1L);

        when(matrizRepository.findById(1L)).thenReturn(Optional.of(matriz));
        when(avaliacaoRepository.save(any(Avaliacao.class))).thenAnswer(i -> i.getArguments()[0]);

        // Act
        Avaliacao salva = avaliacaoService.create(dto);

        // Assert
        assertNotNull(salva);
        assertEquals("Avaliação de Java", salva.getTitulo());
        verify(avaliacaoRepository, times(1)).save(any());
    }
}