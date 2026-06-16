package com.fateczl.sistemaDeGestaoEscolar.academico.frequencia;

import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.when;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
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
import java.util.List;

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

        // Criando pelo menos um item para passar na validação @NotEmpty
        LancarChamadaRequestDTO.PresencaItemDTO presenca = new LancarChamadaRequestDTO.PresencaItemDTO();
        presenca.setAlunoId(1L);
        presenca.setPresente(true);

        // Preenchemos a lista com o item fictício
        dto.setPresencas(List.of(presenca));

        mockMvc.perform(post("/api/v1/frequencia/chamada")
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(dto)))
                .andExpect(status().isCreated()); // 201 Created esperado!
    }

    @Test
    @WithMockUser(roles = "ALUNO")
    public void deveNegarAluno_LancarChamada() throws Exception {
        // 1. Criamos um DTO válido para conseguir passar pela anotação @Valid
        LancarChamadaRequestDTO dtoValido = new LancarChamadaRequestDTO();
        dtoValido.setAulaId(1L);

        LancarChamadaRequestDTO.PresencaItemDTO presenca = new LancarChamadaRequestDTO.PresencaItemDTO();
        presenca.setAlunoId(1L);
        presenca.setPresente(true);

        // Preenchemos a lista para passar no @NotEmpty
        dtoValido.setPresencas(List.of(presenca));

        // 2. Disparamos a requisição com o JSON preenchido
        mockMvc.perform(post("/api/v1/frequencia/chamada")
                        .with(csrf()) // Mantemos o CSRF para requisições POST
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(dtoValido)))
                .andExpect(status().isForbidden()); // Agora sim, a segurança vai barrar com 403!
    }

    @Test
    @WithMockUser(roles = "SECRETARIA")
    public void devePermitirSecretaria_CorrigirPresenca() throws Exception {
        // 1. Arrange: Criamos uma Frequencia falsa para o mock retornar
        Frequencia frequenciaMock = new Frequencia();
        frequenciaMock.setId(1L);
        frequenciaMock.setPresente(true);
        frequenciaMock.setJustificativa("Atestado médico");

        // 2. Ensinamos o Mockito a retornar essa frequencia quando o método corrigir for chamado
        // Os parâmetros são (Long, boolean, String), então usamos os matchers correspondentes:
        when(frequenciaService.corrigirPresenca(anyLong(), anyBoolean(), any()))
                .thenReturn(frequenciaMock);

        // 3. Act & Assert: Fazemos a requisição HTTP (ajuste o JSON e a URL conforme sua implementação)
        // Exemplo de como deve estar sua chamada:
        mockMvc.perform(patch("/api/v1/frequencia/1/corrigir")
                        .with(csrf())
                        .param("presente", "true") // ou enviando via body, dependendo de como você fez
                        .param("justificativa", "Atestado médico"))
                .andExpect(status().isOk());
        // O isOk() vai funcionar agora porque o Mapper não vai mais quebrar!
    }
}