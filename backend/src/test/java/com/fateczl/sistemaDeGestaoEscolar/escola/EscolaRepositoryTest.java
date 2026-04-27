package com.fateczl.sistemaDeGestaoEscolar.escola;

import static org.junit.jupiter.api.Assertions.*;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.boot.test.autoconfigure.jdbc.AutoConfigureTestDatabase;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.jdbc.AutoConfigureTestDatabase;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.boot.test.autoconfigure.orm.jpa.TestEntityManager;
import org.springframework.test.context.ActiveProfiles;

@DataJpaTest
@ActiveProfiles("test")
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.NONE)
public class EscolaRepositoryTest {

    @Autowired
    private EscolaRepository escolaRepository;

    @Autowired
    private TestEntityManager entityManager;

    @Test
    public void deveRetornarTrue_QuandoCnpjJaExistir() {
        Escola escola = new Escola();
        escola.setCodigo("CIE-001");
        escola.setNome("Escola Teste Banco");
        escola.setCnpj("11.111.111/0001-11");
        entityManager.persist(escola);
        entityManager.flush();

        boolean existe = escolaRepository.existsByCnpj("11.111.111/0001-11");

        assertTrue(existe);
    }

    @Test
    public void deveRetornarTrue_QuandoCnpjExistirEmOutraEscola() {
        Escola escolaA = new Escola();
        escolaA.setCodigo("CIE-A");
        escolaA.setNome("Escola A");
        escolaA.setCnpj("99.999.999/0001-99");
        entityManager.persist(escolaA);

        Escola escolaB = new Escola();
        escolaB.setCodigo("CIE-B");
        escolaB.setNome("Escola B");
        escolaB.setCnpj("88.888.888/0001-88");
        Escola escolaBSalva = entityManager.persist(escolaB);

        entityManager.flush();

        boolean conflitoDeCnpj = escolaRepository.existsByCnpjAndIdNot(
                "99.999.999/0001-99",
                escolaBSalva.getId());

        assertTrue(conflitoDeCnpj);
    }

    @Test
    public void deveRetornarFalse_QuandoCnpjNaoExistir() {
        boolean existe = escolaRepository.existsByCnpj("00.000.000/0000-00");
        assertFalse(existe);
    }
}