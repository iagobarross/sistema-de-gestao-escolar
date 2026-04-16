package com.fateczl.sistemaDeGestaoEscolar.academico.avaliacao;

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
import com.fateczl.sistemaDeGestaoEscolar.academico.TipoAvaliacao;
import java.time.LocalDate;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
public class AvaliacaoControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private AvaliacaoService avaliacaoService;

    @MockBean
    private AvaliacaoMapper avaliacaoMapper;

    @Autowired
    private ObjectMapper objectMapper;

    @Test
    @WithMockUser(roles = "PROFESSOR")
    public void deveRetornarCreated_AoCriarAvaliacaoComoProfessor() throws Exception {
        AvaliacaoRequestDTO dto = new AvaliacaoRequestDTO();
        dto.setMatrizCurricularId(1L);
        dto.setTitulo("P1 - Backend");
        dto.setTipo(TipoAvaliacao.PROVA);
        dto.setDataAplicacao(LocalDate.now().plusDays(1));
        dto.setBimestre(1);

        when(avaliacaoService.create(any())).thenReturn(new Avaliacao());

        mockMvc.perform(post("/api/v1/avaliacao")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(dto)))
                .andExpect(status().isCreated());
    }

    @Test
    @WithMockUser(roles = "ALUNO")
    public void deveRetornarForbidden_AoTentarCriarAvaliacaoComoAluno() throws Exception {
        mockMvc.perform(post("/api/v1/avaliacao")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{}"))
                .andExpect(status().isForbidden());
    }
}