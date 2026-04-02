package com.fateczl.sistemaDeGestaoEscolar.turma;

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
public class TurmaRepositoryTest {

    @Autowired
    private TurmaRepository turmaRepository;

    @Autowired
    private TestEntityManager entityManager;

    @Test
    public void deveRetornarTrue_QuandoTurmaJaExistir() {
        Turma turma = new Turma();
        turma.setAno(2024);
        turma.setSerie("1A");
        turma.setTurno("Manhã");
        entityManager.persist(turma);
        entityManager.flush();

        boolean existe = turmaRepository.existsByAnoAndSerieAndTurno(2024, "1A", "Manhã");

        assertTrue(existe);
    }

    @Test
    public void deveRetornarTurma_QuandoBuscarPorDadosExcetoIdAtual() {
        Turma turma = new Turma();
        turma.setAno(2024);
        turma.setSerie("2B");
        turma.setTurno("Tarde");
        Turma salva = entityManager.persist(turma);
        entityManager.flush();

        var resultado = turmaRepository.findByAnoAndSerieAndTurnoAndIdNot(2024, "2B", "Tarde", 99L);

        assertTrue(resultado.isPresent());
        assertEquals(salva.getId(), resultado.get().getId());
    }
}