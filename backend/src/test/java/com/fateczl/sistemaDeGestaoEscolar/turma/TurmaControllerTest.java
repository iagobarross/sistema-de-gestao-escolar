package com.fateczl.sistemaDeGestaoEscolar.turma;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fateczl.sistemaDeGestaoEscolar.config.security.JwtService;

@WebMvcTest(TurmaController.class)
@AutoConfigureMockMvc(addFilters = false)
public class TurmaControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockitoBean
    private TurmaService turmaService;

    @MockitoBean
    private TurmaMapper turmaMapper;

    @MockitoBean
    private JwtService jwtService;

    @Test
    public void deveRetornar201_QuandoCriarTurmaValida() throws Exception {
        // Arrange
        TurmaRequestDTO dto = new TurmaRequestDTO();
        dto.setAno(2024);
        dto.setSerie("1º Ano");
        dto.setTurno("Manhã");

        Turma turma = new Turma();
        when(turmaMapper.toEntity(any())).thenReturn(turma);
        when(turmaService.create(any())).thenReturn(turma);
        when(turmaMapper.toResponseDTO(any())).thenReturn(new TurmaResponseDTO());

        // Act & Assert
        mockMvc.perform(post("/api/v1/turma")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(dto)))
                .andExpect(status().isCreated());
    }

    @Test
    public void deveRetornar400_QuandoAnoForNegativo() throws Exception {
        // Arrange
        TurmaRequestDTO dtoInvalido = new TurmaRequestDTO();
        dtoInvalido.setAno(-1); // Ativa @Positive
        dtoInvalido.setSerie("1A");
        dtoInvalido.setTurno("Tarde");

        // Act & Assert
        mockMvc.perform(post("/api/v1/turma")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(dtoInvalido)))
                .andExpect(status().isBadRequest());
    }
}
