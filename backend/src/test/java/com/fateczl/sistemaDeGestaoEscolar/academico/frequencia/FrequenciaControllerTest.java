package com.fateczl.sistemaDeGestaoEscolar.academico.frequencia;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

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
import java.util.ArrayList;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
public class FrequenciaControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private FrequenciaService frequenciaService;

    @Autowired
    private ObjectMapper objectMapper;

    @Test
    @WithMockUser(roles = "PROFESSOR")
    public void devePermitirProfessor_LancarChamada() throws Exception {
        LancarChamadaRequestDTO dto = new LancarChamadaRequestDTO();
        dto.setAulaId(1L);
        dto.setPresencas(new ArrayList<>()); // Lista vazia para simplificar o teste de rota

        mockMvc.perform(post("/api/v1/frequencia/chamada")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(dto)))
                .andExpect(status().isCreated());
    }

    @Test
    @WithMockUser(roles = "ALUNO")
    public void deveNegarAluno_LancarChamada() throws Exception {
        mockMvc.perform(post("/api/v1/frequencia/chamada")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{}"))
                .andExpect(status().isForbidden());
    }

    @Test
    @WithMockUser(roles = "SECRETARIA")
    public void devePermitirSecretaria_CorrigirPresenca() throws Exception {
        mockMvc.perform(patch("/api/v1/frequencia/1")
                .param("presente", "true"))
                .andExpect(status().isOk());
    }
}