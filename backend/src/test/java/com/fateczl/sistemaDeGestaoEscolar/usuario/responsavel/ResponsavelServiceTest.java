package com.fateczl.sistemaDeGestaoEscolar.usuario.responsavel;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.security.crypto.password.PasswordEncoder;
import com.fateczl.sistemaDeGestaoEscolar.config.exception.BusinessException;

@ExtendWith(MockitoExtension.class)
public class ResponsavelServiceTest {

    @Mock
    private ResponsavelRepository responsavelRepository;

    @Mock
    private PasswordEncoder passwordEncoder;

    @InjectMocks
    private ResponsavelServiceImpl responsavelService;

    @Test
    public void deveLancarErro_QuandoCpfJaCadastrado() {
        // Arrange
        Responsavel novo = new Responsavel();
        novo.setCpf("12345678901");
        when(responsavelRepository.existsByCpf("12345678901")).thenReturn(true);

        // Act & Assert
        BusinessException erro = assertThrows(BusinessException.class, () -> responsavelService.create(novo));
        assertEquals("CPF já cadastrado.", erro.getMessage());
    }

    @Test
    public void deveLancarErro_AoDeletarResponsavelComAlunos() {
        // Arrange
        Long id = 1L;
        when(responsavelRepository.existsById(id)).thenReturn(true);
        doThrow(DataIntegrityViolationException.class).when(responsavelRepository).deleteById(id);

        // Act & Assert
        BusinessException erro = assertThrows(BusinessException.class, () -> responsavelService.deleteById(id));
        assertTrue(erro.getMessage().contains("possui alunos associados"));
    }
}