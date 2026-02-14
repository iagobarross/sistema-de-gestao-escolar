package com.fateczl.sistemaDeGestaoEscolar.escola;

import static org.junit.jupiter.api.Assertions.*;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.boot.test.autoconfigure.orm.jpa.TestEntityManager;

@DataJpaTest(properties = {
        "spring.sql.init.mode=never",
        "spring.jpa.hibernate.ddl-auto=create-drop"
})
public class EscolaRepositoryTest {

    @Autowired
    private EscolaRepository escolaRepository;

    // Ferramenta nativa do Spring para inserir dados direto no banco durante os testes
    @Autowired
    private TestEntityManager entityManager;

    /**
     * Cenário 1: Provar que a consulta de CNPJ simples funciona
     */
    @Test
    public void deveRetornarTrue_QuandoCnpjJaExistir() {
        // 1. Arrange: Criamos e salvamos uma escola real no banco em memória
        Escola escola = new Escola();
        escola.setCodigo("CIE-001");
        escola.setNome("Escola Teste Banco");
        escola.setCnpj("11.111.111/0001-11");
        entityManager.persist(escola); // Insere no banco
        entityManager.flush();         // Força a gravação imediata

        // 2. Act: Usamos o método do nosso repository que queremos testar
        boolean existe = escolaRepository.existsByCnpj("11.111.111/0001-11");

        // 3. Assert: Esperamos que o banco responda que SIM (true)
        assertTrue(existe);
    }

    /**
     * Cenário 2: Provar que a consulta complexa do UPDATE funciona
     * "Existe este CNPJ, mas o ID é diferente do meu?"
     */
    @Test
    public void deveRetornarTrue_QuandoCnpjExistirEmOutraEscola() {
        // 1. Arrange: Inserimos DUAS escolas no banco
        Escola escolaA = new Escola();
        escolaA.setCodigo("CIE-A");
        escolaA.setNome("Escola A");
        escolaA.setCnpj("99.999.999/0001-99");
        Escola escolaASalva = entityManager.persist(escolaA); // O banco vai dar o ID 1 para ela

        Escola escolaB = new Escola();
        escolaB.setCodigo("CIE-B");
        escolaB.setNome("Escola B");
        escolaB.setCnpj("88.888.888/0001-88");
        Escola escolaBSalva = entityManager.persist(escolaB); // O banco vai dar o ID 2 para ela

        entityManager.flush();

        // 2. Act: Fingimos que somos a "Escola B" tentando atualizar o CNPJ usando o CNPJ da "Escola A"
        // "Existe o CNPJ 99... em algum ID que NÃO SEJA o ID da Escola B?"
        boolean conflitoDeCnpj = escolaRepository.existsByCnpjAndIdNot(
                "99.999.999/0001-99",
                escolaBSalva.getId()
        );

        // 3. Assert: O banco tem que responder que SIM, há conflito (true)
        assertTrue(conflitoDeCnpj);
    }

    /**
     * Cenário 3: Falso Positivo (Garantir que a consulta não mente)
     */
    @Test
    public void deveRetornarFalse_QuandoCnpjNaoExistir() {
        // 1. Arrange (Banco vazio)

        // 2. Act
        boolean existe = escolaRepository.existsByCnpj("00.000.000/0000-00");

        // 3. Assert
        assertFalse(existe);
    }
}