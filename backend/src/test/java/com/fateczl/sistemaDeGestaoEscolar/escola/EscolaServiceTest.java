package com.fateczl.sistemaDeGestaoEscolar.escola;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import com.fateczl.sistemaDeGestaoEscolar.config.exception.BusinessException;

import java.util.Optional;

// @ExtendWith: Inicializa o Mockito sem precisar subir o Spring inteiro (rápido e leve)
@ExtendWith(MockitoExtension.class)
public class EscolaServiceTest {

    @Mock
    private EscolaRepository escolaRepository;

    @InjectMocks
    private EscolaServiceImpl escolaService;

    /**
     * Teste referente ao CT02 da Matriz:
     * Tentar cadastrar escola com CNPJ já existente.
     */
    @Test
    public void deveLancarErro_QuandoCadastrarCnpjDuplicado() {

      String cnpjDuplicado = "12.345.678/0001-99";

        Escola escolaParaSalvar = new Escola();
        escolaParaSalvar.setCnpj(cnpjDuplicado);
        escolaParaSalvar.setNome("Escola Teste");

        when(escolaRepository.existsByCnpj(cnpjDuplicado)).thenReturn(true);

        // 2. AÇÃO (When) & 3. VALIDAÇÃO (Then)
        // O teste passa se o código lançar a BusinessException
        BusinessException excecaoLancada = assertThrows(BusinessException.class, () -> escolaService.create(escolaParaSalvar));

        // Valida se a mensagem do erro é exatamente a que definimos no código
        assertEquals("CNPJ da escola já cadastrado.", excecaoLancada.getMessage());

        // Validação Crítica de Segurança: Garante que o sistema NÃO tentou salvar no banco mesmo dando erro
        verify(escolaRepository, never()).save(any(Escola.class));
    }

    /**
     * Teste referente ao CT01 da Matriz:
     * Cadastrar escola com dados válidos (Caminho Feliz).
     */
    @Test
    public void deveSalvarEscola_QuandoDadosValidos() {
        // 1. CENÁRIO
        String cnpjNovo = "99.888.777/0001-00";
        Escola escola = new Escola();
        escola.setCnpj(cnpjNovo);

        // Ensinamos o Mock: "Esse CNPJ não existe, pode seguir"
        when(escolaRepository.existsByCnpj(cnpjNovo)).thenReturn(false);
        // Ensinamos o Mock: "Quando mandarem salvar, retorne o próprio objeto"
        when(escolaRepository.save(escola)).thenReturn(escola);

        // 2. AÇÃO
        Escola escolaSalva = escolaService.create(escola);

        // 3. VALIDAÇÃO
        assertNotNull(escolaSalva); // Garante que não retornou nulo
        verify(escolaRepository, times(1)).save(escola); // Garante que o save foi chamado 1 vez
    }
    /**
     * CT03 - Valida se o sistema bloqueia Códigos duplicados
     */
    @Test
    public void deveLancarErro_QuandoCadastrarCodigoDuplicado() {
        // 1. Arrange (Cenário)
        String codigoExistente = "CIE-999";

        Escola novaEscola = new Escola();
        novaEscola.setCodigo(codigoExistente);
        novaEscola.setCnpj("88.888.888/0001-88"); // CNPJ válido/diferente

        // Ensinamos o Mock: CNPJ não existe (passa na 1ª validação), mas Código existe (falha na 2ª)
        when(escolaRepository.existsByCnpj(anyString())).thenReturn(false);
        when(escolaRepository.existsByCodigo(codigoExistente)).thenReturn(true);

        // 2. Act & 3. Assert (Execução e Validação)
        BusinessException erro = assertThrows(BusinessException.class, () -> {
            escolaService.create(novaEscola);
        });

        assertEquals("Código da escola já cadastrado.", erro.getMessage());

        // Garante que a aplicação parou antes de chegar no save
        verify(escolaRepository, never()).save(any(Escola.class));
    }
    /**
     * Teste: Tentar atualizar uma escola usando um CNPJ que já pertence a OUTRA escola.
     */
    @Test
    public void deveLancarErro_QuandoAtualizarComCnpjDeOutraEscola() {
        Long idMinhaEscola = 1L;
        String cnpjDeOutraEscola = "11.111.111/0001-11";

        Escola dadosParaAtualizar = new Escola();
        dadosParaAtualizar.setId(idMinhaEscola);
        dadosParaAtualizar.setCnpj(cnpjDeOutraEscola);

        when(escolaRepository.findById(idMinhaEscola)).thenReturn(Optional.of(new Escola()));

        when(escolaRepository.existsByCnpjAndIdNot(cnpjDeOutraEscola, idMinhaEscola)).thenReturn(true);

        BusinessException erro = assertThrows(BusinessException.class, () -> {
            escolaService.update(idMinhaEscola, dadosParaAtualizar);
        });

        assertEquals("Já existe outra escola com este CNPJ.", erro.getMessage());
        verify(escolaRepository, never()).save(any());
    }
}
