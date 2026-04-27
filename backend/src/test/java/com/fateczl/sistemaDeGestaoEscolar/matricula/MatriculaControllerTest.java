package com.fateczl.sistemaDeGestaoEscolar.matricula;

import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.Mockito.doNothing;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import org.junit.jupiter.api.BeforeEach;
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
import com.fateczl.sistemaDeGestaoEscolar.turma.TurmaService;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
public class MatriculaControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private TurmaService turmaService;

    @Autowired
    private ObjectMapper objectMapper;

    private MatriculaDTO matriculaDTO;

    @BeforeEach
    void setUp() {
        matriculaDTO = new MatriculaDTO();
        matriculaDTO.setAlunoId(1L);
        matriculaDTO.setTurmaId(10L);
    }

    /**
     * Testa se um ADMIN consegue realizar a matrícula.
     * Note: Este teste assume que você criará um método matricularAluno no
     * TurmaService.
     */
    @Test
    @WithMockUser(roles = "ADMIN")
    public void deveRealizarMatricula_QuandoUsuarioForAdmin() throws Exception {
        // Simulando que o serviço de matrícula não retorna erro
        // doNothing().when(turmaService).matricularAluno(anyLong(), anyLong());

        mockMvc.perform(post("/api/v1/turma/matricula")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(matriculaDTO)))
                .andExpect(status().isOk());
    }

    /**
     * Testa se a segurança bloqueia usuários sem a Role ADMIN.
     */
    @Test
    @WithMockUser(roles = "USER")
    public void deveRetornarForbidden_QuandoUsuarioNaoForAdmin() throws Exception {
        mockMvc.perform(post("/api/v1/turma/matricula")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(matriculaDTO)))
                .andExpect(status().isForbidden());
    }

    /**
     * Testa se usuários não autenticados são bloqueados.
     */
    @Test
    public void deveRetornarUnauthorized_QuandoNaoAutenticado() throws Exception {
        mockMvc.perform(post("/api/v1/turma/matricula")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(matriculaDTO)))
                .andExpect(status().isUnauthorized());
    }
}