package com.fateczl.sistemaDeGestaoEscolar.matricula;

import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.Mockito.when;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

import com.fateczl.sistemaDeGestaoEscolar.turma.TurmaService;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
public class MatriculaControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private TurmaService turmaService;

    private Long alunoId;
    private Long turmaId;

    @BeforeEach
    void setUp() {
        // Em vez de usar o DTO que enviava um JSON, vamos usar os IDs para a URL
        alunoId = 1L;
        turmaId = 10L;
    }

    /**
     * Testa se um ADMIN consegue realizar a matrícula.
     */
    @Test
    @WithMockUser(roles = "ADMIN")
    public void deveRealizarMatricula_QuandoUsuarioForAdmin() throws Exception {
        // Simulando o retorno da procedure do banco que está no seu TurmaController
        when(turmaService.matricularAlunoViaProcedure(anyLong(), anyLong()))
                .thenReturn("Matrícula realizada com sucesso");

        // A URL mudou e não enviamos mais .content() com JSON
        mockMvc.perform(post("/api/v1/turma/" + turmaId + "/matricular/" + alunoId)
                        .with(csrf())) // Adicionado csrf() para evitar erro 403
                .andExpect(status().isOk());
    }

    /**
     * Testa se a segurança bloqueia usuários sem a Role correta (ex: USER comum).
     */
    @Test
    @WithMockUser(roles = "USER")
    public void deveRetornarForbidden_QuandoUsuarioNaoForAdmin() throws Exception {
        mockMvc.perform(post("/api/v1/turma/" + turmaId + "/matricular/" + alunoId)
                        .with(csrf()))
                .andExpect(status().isForbidden());
    }

    /**
     * Testa se usuários não autenticados são bloqueados.
     */
    @Test
    public void deveRetornarUnauthorized_QuandoNaoAutenticado() throws Exception {
        mockMvc.perform(post("/api/v1/turma/" + turmaId + "/matricular/" + alunoId)
                        .with(csrf()))
                .andExpect(status().isUnauthorized());
    }
}