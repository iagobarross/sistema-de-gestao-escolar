package com.fateczl.sistemaDeGestaoEscolar.usuario.responsavel;

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

@WebMvcTest(ResponsavelController.class)
@AutoConfigureMockMvc(addFilters = false)
public class ResponsavelControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockitoBean
    private ResponsavelService responsavelService;

    @MockitoBean
    private ResponsavelMapper responsavelMapper;

    @MockitoBean
    private JwtService jwtService;

    @Test
    public void deveRetornar400_QuandoCpfInvalido() throws Exception {
        // Arrange: CPF com menos de 11 dígitos
        ResponsavelRequestDTO dto = new ResponsavelRequestDTO();
        dto.setNome("Mauro");
        dto.setEmail("mauro@email.com");
        dto.setCpf("123");

        // Act & Assert
        mockMvc.perform(post("/api/v1/responsavel")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(dto)))
                .andExpect(status().isBadRequest());
    }
}