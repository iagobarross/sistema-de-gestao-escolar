package com.fateczl.sistemaDeGestaoEscolar.disciplina;

import static org.junit.jupiter.api.Assertions.*;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.boot.test.autoconfigure.orm.jpa.TestEntityManager;
import org.springframework.test.context.ActiveProfiles;

@DataJpaTest
@ActiveProfiles("test") // Garante que usará o H2 se você criou o application-test.properties
public class DisciplinaRepositoryTest {

    @Autowired
    private DisciplinaRepository disciplinaRepository;

    @Autowired
    private TestEntityManager entityManager;

    @Test
    public void deveRetornarTrue_QuandoCodigoJaExistir() {
        // Arrange
        Disciplina disciplina = new Disciplina();
        disciplina.setCodigo("MAT01");
        disciplina.setNome("Matemática");
        disciplina.setDescricao("Cálculo I");
        disciplina.setNotaMinima(6.0);
        disciplina.setCargaHoraria(80);
        
        entityManager.persist(disciplina);
        entityManager.flush();

        // Act
        boolean existe = disciplinaRepository.existsByCodigo("MAT01");

        // Assert
        assertTrue(existe);
    }

    @Test
    public void deveRetornarFalse_QuandoCodigoNaoExistir() {
        // Act
        boolean existe = disciplinaRepository.existsByCodigo("XPTO-99");

        // Assert
        assertFalse(existe);
    }
}