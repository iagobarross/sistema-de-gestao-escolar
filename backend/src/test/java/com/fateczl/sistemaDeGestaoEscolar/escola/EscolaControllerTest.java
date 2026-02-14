package com.fateczl.sistemaDeGestaoEscolar.escola;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.fateczl.sistemaDeGestaoEscolar.config.security.JwtService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.bean.override.mockito.MockitoBean; // O NOVO IMPORT!
import org.springframework.test.web.servlet.MockMvc;

import com.fasterxml.jackson.databind.ObjectMapper;

@WebMvcTest(EscolaController.class)
@AutoConfigureMockMvc(addFilters = false) // Desabilita o Spring Security temporariamente para focar na rota
public class EscolaControllerTest {

    @Autowired
    private MockMvc mockMvc; // A ferramenta que simula as requisições HTTP

    @Autowired
    private ObjectMapper objectMapper; // Para converter objetos Java em JSON

    @MockitoBean
    private EscolaService escolaService;

    @MockitoBean
    private EscolaMapper escolaMapper;

    @MockitoBean
    private JwtService jwtService;

    // ... e, se o seu filtro de JWT também precisar do UserDetailsService, adicione ele também:
    @MockitoBean
    private org.springframework.security.core.userdetails.UserDetailsService userDetailsService;

    @Test
    public void deveRetornarStatus201_QuandoCriarEscolaComDadosValidos() throws Exception {
        // 1. Arrange (Preparação)
        EscolaRequestDTO dtoValido = new EscolaRequestDTO();
        dtoValido.setCodigo("CIE-123");
        dtoValido.setNome("Escola Modelo");
        dtoValido.setCnpj("03.303.036/0001-32"); // CNPJ Válido (mesmo fictício, use um que passe no validador se usar @CNPJ)
        dtoValido.setEndereco("Rua 1");

        Escola escolaConvertida = new Escola(); // Mock da conversão
        Escola escolaSalva = new Escola(); // Mock do banco
        escolaSalva.setId(1L);

        EscolaResponseDTO responseDTO = new EscolaResponseDTO();
        responseDTO.setId(1L);

        // Ensinando os mocks a responderem quando o Controller chamar
        when(escolaMapper.toEntity(any(EscolaRequestDTO.class))).thenReturn(escolaConvertida);
        when(escolaService.create(any(Escola.class))).thenReturn(escolaSalva);
        when(escolaMapper.toResponseDTO(any(Escola.class))).thenReturn(responseDTO);

        // 2. Act & 3. Assert (Execução e Validação juntas com o MockMvc)
        mockMvc.perform(post("/api/v1/escola") // Chama a sua rota
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(dtoValido))) // Envia o JSON
                .andExpect(status().isCreated()); // Espera o HTTP 201 (O mais importante!)
    }

    @Test
    public void deveRetornarStatus400_QuandoCriarEscolaComNomeEmBranco() throws Exception {
        // 1. Arrange
        EscolaRequestDTO dtoInvalido = new EscolaRequestDTO();
        dtoInvalido.setCodigo("CIE-123");
        dtoInvalido.setNome(""); // NOME EM BRANCO (deve acionar o @NotBlank)
        dtoInvalido.setCnpj("12.345.678/0001-99");
        dtoInvalido.setEndereco("Rua 1");

        // 2. Act & 3. Assert
        mockMvc.perform(post("/api/v1/escola")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(dtoInvalido)))
                .andExpect(status().isBadRequest()); // Espera o HTTP 400 Bad Request
        // .andExpect(jsonPath("$.nome").exists()); // Opcional: Validar a mensagem de erro específica, se você tiver um GlobalExceptionHandler
    }
}