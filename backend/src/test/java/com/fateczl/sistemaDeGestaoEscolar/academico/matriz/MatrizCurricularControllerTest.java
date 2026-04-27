package com.fateczl.sistemaDeGestaoEscolar.academico.matriz;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

import com.fasterxml.jackson.databind.ObjectMapper;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
public class MatrizCurricularControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private MatrizCurricularService service;

    @MockBean
    private MatrizCurricularMapper mapper;

    @Autowired
    private ObjectMapper objectMapper;

    @Test
    @WithMockUser(roles = "ADMIN")
    public void deveRetornarNoContent_AoDeletarComoAdmin() throws Exception {
        mockMvc.perform(delete("/api/v1/matriz-curricular/1"))
                .andExpect(status().isNoContent());
    }

    @Test
    @WithMockUser(roles = "PROFESSOR")
    public void deveRetornarForbidden_AoTentarDeletarComoProfessor() throws Exception {
        mockMvc.perform(delete("/api/v1/matriz-curricular/1"))
                .andExpect(status().isForbidden());
    }

    @Test
    @WithMockUser(roles = "DIRETOR")
    public void deveRetornarNoContent_AoEncerrarMatrizComoDiretor() throws Exception {
        mockMvc.perform(patch("/api/v1/matriz-curricular/1/encerrar"))
                .andExpect(status().isNoContent());
    }
}