package com.fateczl.sistemaDeGestaoEscolar.academico.aula;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
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
import java.time.LocalDate;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
public class AulaControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private AulaService aulaService;

    @MockBean
    private AulaMapper aulaMapper;

    @Autowired
    private ObjectMapper objectMapper;

    @Test
    @WithMockUser(roles = "PROFESSOR")
    public void deveRetornarCreated_AoRegistrarAulaComoProfessor() throws Exception {
        AulaRequestDTO dto = new AulaRequestDTO();
        dto.setMatrizCurricularId(1L);
        dto.setData(LocalDate.now());
        dto.setConteudo("Lógica de Programação");

        when(aulaService.registrar(any())).thenReturn(new Aula());

        mockMvc.perform(post("/api/v1/aula")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(dto)))
                .andExpect(status().isCreated());
    }

    @Test
    @WithMockUser(roles = "ALUNO")
    public void deveRetornarForbidden_AoTentarRegistrarAulaComoAluno() throws Exception {
        mockMvc.perform(post("/api/v1/aula")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{}"))
                .andExpect(status().isForbidden());
    }
}