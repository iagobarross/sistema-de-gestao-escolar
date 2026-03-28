package com.fateczl.sistemaDeGestaoEscolar.usuario.responsavel;

import static org.junit.jupiter.api.Assertions.*;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.boot.test.autoconfigure.orm.jpa.TestEntityManager;

@DataJpaTest(properties = {
        "spring.sql.init.mode=never",
        "spring.jpa.hibernate.ddl-auto=create-drop"
})
public class ResponsavelRepositoryTest {

    @Autowired
    private ResponsavelRepository responsavelRepository;

    @Autowired
    private TestEntityManager entityManager;

    @Test
    public void deveRetornarTrue_QuandoCpfJaExistir() {
        // Arrange
        Responsavel resp = Responsavel.builder()
                .nome("Responsavel Teste")
                .email("resp@email.com")
                .cpf("12345678901")
                .build();
        entityManager.persist(resp);
        entityManager.flush();

        // Act
        boolean existe = responsavelRepository.existsByCpf("12345678901");

        // Assert
        assertTrue(existe);
    }

    @Test
    public void deveDetectarConflitoDeCpf_EmOutroId() {
        // Arrange
        Responsavel r1 = Responsavel.builder().nome("R1").email("r1@e.com").cpf("111").build();
        Responsavel r2 = Responsavel.builder().nome("R2").email("r2@e.com").cpf("222").build();
        entityManager.persist(r1);
        Responsavel salvo2 = entityManager.persist(r2);
        entityManager.flush();

        // Act: Tenta ver se o CPF do R1 existe em um ID diferente do R2
        boolean conflito = responsavelRepository.findByCpfAndIdNot("111", salvo2.getId()).isPresent();

        // Assert
        assertTrue(conflito);
    }
}