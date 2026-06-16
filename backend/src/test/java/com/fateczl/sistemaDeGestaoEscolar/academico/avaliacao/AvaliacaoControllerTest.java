package com.fateczl.sistemaDeGestaoEscolar.academico.avaliacao;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
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
        // 1. Precisamos montar um DTO válido para passar pelo @Valid e testar apenas a segurança
        AvaliacaoRequestDTO dtoValido = new AvaliacaoRequestDTO();
        dtoValido.setMatrizCurricularId(1L);
        dtoValido.setTitulo("P1 - Backend");
        dtoValido.setTipo(TipoAvaliacao.PROVA);
        dtoValido.setDataAplicacao(LocalDate.now().plusDays(1));
        dtoValido.setBimestre(1); // Bimestre >= 1 para não dar erro @Min

        // 2. Disparar a requisição
        mockMvc.perform(post("/api/v1/avaliacao")
                        .with(csrf()) // IMPORTANTE: Mantenha o csrf() para POSTs no Spring Security
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(dtoValido))) // Envia o JSON preenchido
                .andExpect(status().isForbidden()); // Agora sim, esperamos o 403!
    }
}