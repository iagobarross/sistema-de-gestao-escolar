package com.fateczl.sistemaDeGestaoEscolar.academico.nota;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.util.List;
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
public class NotaControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private NotaService notaService;

    @Autowired
    private ObjectMapper objectMapper;

    @Test
    @WithMockUser(roles = "PROFESSOR")
    public void deveRetornarCreated_AoLancarNotasComoProfessor() throws Exception {
        LancarNotasRequestDTO dto = new LancarNotasRequestDTO();
        dto.setAvaliacaoId(1L);

        LancarNotasRequestDTO.NotaItemDTO item = new LancarNotasRequestDTO.NotaItemDTO();
        item.setAlunoId(1L);
        item.setValor(8.5);
        dto.setNotas(List.of(item));

        when(notaService.lancarNotas(any())).thenReturn(List.of(new Nota()));

        mockMvc.perform(post("/api/v1/nota/lancar")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(dto)))
                .andExpect(status().isCreated());
    }

    @Test
    @WithMockUser(roles = "ALUNO")
    public void deveRetornarForbidden_AoTentarLancarNotasComoAluno() throws Exception {
        mockMvc.perform(post("/api/v1/nota/lancar")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{}"))
                .andExpect(status().isForbidden());
    }
}