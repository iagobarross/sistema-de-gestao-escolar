package com.fateczl.sistemaDeGestaoEscolar.usuario.aluno;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.time.LocalDate;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fateczl.sistemaDeGestaoEscolar.config.security.JwtService;

@WebMvcTest(AlunoController.class)
@AutoConfigureMockMvc(addFilters = false)
public class AlunoControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockitoBean
    private AlunoService alunoService;

    @MockitoBean
    private AlunoMapper alunoMapper;

    @MockitoBean
    private JwtService jwtService;

    @Test
    public void deveRetornar400_QuandoDataNascimentoNoFuturo() throws Exception {
        // Arrange
        AlunoRequestDTO dto = new AlunoRequestDTO();
        dto.setNome("Joao Silva");
        dto.setEmail("joao@email.com");
        dto.setEscolaId(1L);
        dto.setResponsavelId(1L);
        dto.setMatricula("123");
        dto.setDataNascimento(LocalDate.now().plusDays(1)); // Erro: deve ser no passado

        // Act & Assert
        mockMvc.perform(post("/api/v1/aluno")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(dto)))
                .andExpect(status().isBadRequest());
    }
}
