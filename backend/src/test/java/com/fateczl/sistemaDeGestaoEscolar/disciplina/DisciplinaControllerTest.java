package com.fateczl.sistemaDeGestaoEscolar.disciplina;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

import java.util.List;

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

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
public class DisciplinaControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private DisciplinaService disciplinaService;

    @MockBean
    private DisciplinaMapper disciplinaMapper;

    @Autowired
    private ObjectMapper objectMapper;

    private Disciplina disciplina;
    private DisciplinaResponseDTO responseDTO;

    @BeforeEach
    void setUp() {
        disciplina = new Disciplina();
        disciplina.setId(1L);
        disciplina.setNome("Algoritmos");
        disciplina.setCodigo("ALG01");

        responseDTO = new DisciplinaResponseDTO();
        responseDTO.setId(1L);
        responseDTO.setNome("Algoritmos");
        responseDTO.setCodigo("ALG01");
    }

    @Test
    @WithMockUser(roles = "ADMIN")
    public void deveCriarDisciplina_QuandoUsuarioForAdmin() throws Exception {
        DisciplinaRequestDTO requestDTO = new DisciplinaRequestDTO();
        requestDTO.setNome("Algoritmos");
        requestDTO.setCodigo("ALG01");
        requestDTO.setDescricao("Introdução à lógica");
        requestDTO.setNotaMinima(6.0);
        requestDTO.setCargaHoraria(40);

        when(disciplinaMapper.toEntity(any())).thenReturn(disciplina);
        when(disciplinaService.create(any())).thenReturn(disciplina);
        when(disciplinaMapper.toResponseDTO(any())).thenReturn(responseDTO);

        mockMvc.perform(post("/api/v1/disciplina")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(requestDTO)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.nome").value("Algoritmos"));
    }

    @Test
    @WithMockUser(roles = "USER")
    public void deveRetornarForbidden_QuandoUsuarioNaoForAdmin_AoTentarCriar() throws Exception {
        mockMvc.perform(post("/api/v1/disciplina")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{}"))
                .andExpect(status().isForbidden()); // Garante que a segurança bloqueou
    }

    @Test
    @WithMockUser
    public void deveListarDisciplinas_QuandoAutenticado() throws Exception {
        when(disciplinaService.findAll()).thenReturn(List.of(disciplina));
        when(disciplinaMapper.toResponseDTOList(any())).thenReturn(List.of(responseDTO));

        mockMvc.perform(get("/api/v1/disciplina"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].nome").value("Algoritmos"));
    }
}