package com.fateczl.sistemaDeGestaoEscolar.turma;

import static org.junit.jupiter.api.Assertions.*;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.boot.test.autoconfigure.orm.jpa.TestEntityManager;

@DataJpaTest(properties = {
        "spring.sql.init.mode=never",
        "spring.jpa.hibernate.ddl-auto=create-drop"
})
public class TurmaRepositoryTest {

    @Autowired
    private TurmaRepository turmaRepository;

    @Autowired
    private TestEntityManager entityManager;

    @Test
    public void deveRetornarTrue_QuandoTurmaJaExistir() {
        // Arrange
        Turma turma = new Turma();
        turma.setAno(2024);
        turma.setSerie("1A");
        turma.setTurno("Manhã");
        entityManager.persist(turma);
        entityManager.flush();

        // Act
        boolean existe = turmaRepository.existsByAnoAndSerieAndTurno(2024, "1A", "Manhã");

        // Assert
        assertTrue(existe);
    }

    @Test
    public void deveRetornarTurma_QuandoBuscarPorDadosExcetoIdAtual() {
        // Arrange
        Turma turma = new Turma();
        turma.setAno(2024);
        turma.setSerie("2B");
        turma.setTurno("Tarde");
        Turma salva = entityManager.persist(turma);
        entityManager.flush();

        // Act: Busca se existe outra turma com esses dados, ignorando um ID fictício
        // (ex: 99L)
        var resultado = turmaRepository.findByAnoAndSerieAndTurnoAndIdNot(2024, "2B", "Tarde", 99L);

        // Assert
        assertTrue(resultado.isPresent());
        assertEquals(salva.getId(), resultado.get().getId());
    }
}