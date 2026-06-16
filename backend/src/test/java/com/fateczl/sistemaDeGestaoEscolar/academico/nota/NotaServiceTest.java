package com.fateczl.sistemaDeGestaoEscolar.academico.nota;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

import java.util.List;
import java.util.Optional;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import com.fateczl.sistemaDeGestaoEscolar.academico.avaliacao.Avaliacao;
import com.fateczl.sistemaDeGestaoEscolar.academico.avaliacao.AvaliacaoRepository;
import com.fateczl.sistemaDeGestaoEscolar.config.exception.BusinessException;

// NOVOS IMPORTS NECESSÁRIOS:
import com.fateczl.sistemaDeGestaoEscolar.usuario.aluno.Aluno;
import com.fateczl.sistemaDeGestaoEscolar.usuario.aluno.AlunoRepository;
import com.fateczl.sistemaDeGestaoEscolar.academico.aula.AulaRepository;
import com.fateczl.sistemaDeGestaoEscolar.academico.frequencia.FrequenciaRepository;
import com.fateczl.sistemaDeGestaoEscolar.academico.matriz.MatrizCurricularRepository;

@ExtendWith(MockitoExtension.class)
public class NotaServiceTest {

    @Mock
    private NotaRepository notaRepository;

    @Mock
    private AvaliacaoRepository avaliacaoRepository;

    // Adicionando os Mocks restantes para o construtor não quebrar
    @Mock
    private AlunoRepository alunoRepository;

    @Mock
    private MatrizCurricularRepository matrizRepository;

    @Mock
    private FrequenciaRepository frequenciaRepository;

    @Mock
    private AulaRepository aulaRepository;

    @InjectMocks
    private NotaServiceImpl notaService;

    @Test
    public void deveLancarErro_QuandoValorDaNotaForMaiorQueNotaMaximaDaAvaliacao() {
        // Arrange
        LancarNotasRequestDTO dto = new LancarNotasRequestDTO();
        dto.setAvaliacaoId(1L);

        LancarNotasRequestDTO.NotaItemDTO item = new LancarNotasRequestDTO.NotaItemDTO();
        item.setAlunoId(1L);
        item.setValor(11.0); // Nota maior que o máximo
        dto.setNotas(List.of(item));

        Avaliacao av = new Avaliacao();
        av.setId(1L);
        av.setNotaMaxima(10.0);

        // Simulando que a avaliação existe
        when(avaliacaoRepository.findById(1L)).thenReturn(Optional.of(av));

        // Simulando que o Aluno também existe (para não dar erro ResourceNotFoundException antes da hora)
        when(alunoRepository.findById(1L)).thenReturn(Optional.of(new Aluno()));

        // Nota: O notaRepository.findByAvaliacaoIdAndAlunoId já vai retornar Optional.empty() por padrão graças ao Mockito

        // Act & Assert
        BusinessException exception = assertThrows(BusinessException.class, () -> {
            notaService.lancarNotas(dto);
        });

        assertTrue(exception.getMessage().contains("não pode ser maior que a nota máxima"));
        verify(notaRepository, never()).saveAll(any());
    }
}