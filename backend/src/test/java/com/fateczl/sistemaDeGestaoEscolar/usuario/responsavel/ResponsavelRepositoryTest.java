package com.fateczl.sistemaDeGestaoEscolar.usuario.responsavel;

import static org.junit.jupiter.api.Assertions.*;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.jdbc.AutoConfigureTestDatabase;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.boot.test.autoconfigure.orm.jpa.TestEntityManager;
import org.springframework.test.context.ActiveProfiles;

@DataJpaTest
@ActiveProfiles("test")
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.NONE)
public class ResponsavelRepositoryTest {

    @Autowired
    private ResponsavelRepository responsavelRepository;

    @Autowired
    private TestEntityManager entityManager;

    @Test
    public void deveRetornarTrue_QuandoCpfJaExistir() {
        Responsavel resp = Responsavel.builder()
                .nome("Responsavel Teste")
                .email("resp@email.com")
                .cpf("12345678901")
                .senha("123456")
                .build();
        entityManager.persist(resp);
        entityManager.flush();

        boolean existe = responsavelRepository.existsByCpf("12345678901");

        assertTrue(existe);
    }

    @Test
    public void deveDetectarConflitoDeCpf_EmOutroId() {
        Responsavel r1 = Responsavel.builder().nome("R1").email("r1@e.com").cpf("11111111111").senha("123456").build();
        Responsavel r2 = Responsavel.builder().nome("R2").email("r2@e.com").cpf("22222222222").senha("123456").build();
        entityManager.persist(r1);
        Responsavel salvo2 = entityManager.persist(r2);
        entityManager.flush();

        boolean conflito = responsavelRepository.findByCpfAndIdNot("11111111111", salvo2.getId()).isPresent();

        assertTrue(conflito);
    }

    @Test
    public void deveRetornarFalse_QuandoCpfNaoExistir() {
        boolean existe = responsavelRepository.existsByCpf("00000000000");
        assertFalse(existe);
    }
}