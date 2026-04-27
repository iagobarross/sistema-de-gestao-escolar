package com.fateczl.sistemaDeGestaoEscolar.academico.aula;

import static org.junit.jupiter.api.Assertions.*;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.boot.test.autoconfigure.orm.jpa.TestEntityManager;
import org.springframework.test.context.ActiveProfiles;

import com.fateczl.sistemaDeGestaoEscolar.academico.matriz.MatrizCurricular;
import java.time.LocalDate;

@DataJpaTest
@ActiveProfiles("test")
public class AulaRepositoryTest {

    @Autowired
    private AulaRepository aulaRepository;

    @Autowired
    private TestEntityManager entityManager;

    @Test
    public void deveRetornarUltimoNumeroAula_ComoZero_QuandoNaoHouverAulas() {
        // Arrange: Criamos uma matriz apenas para o teste
        MatrizCurricular matriz = new MatrizCurricular();
        entityManager.persist(matriz);
        entityManager.flush();

        // Act
        int ultimoNumero = aulaRepository.findUltimoNumeroAula(matriz.getId());

        // Assert
        assertEquals(0, ultimoNumero);
    }

    @Test
    public void deveRetornarUltimoNumeroCorreto_QuandoHouverAulas() {
        // Arrange
        MatrizCurricular matriz = new MatrizCurricular();
        entityManager.persist(matriz);

        Aula aula1 = new Aula();
        aula1.setMatrizCurricular(matriz);
        aula1.setData(LocalDate.now());
        aula1.setNumeroAula(1);
        entityManager.persist(aula1);

        Aula aula2 = new Aula();
        aula2.setMatrizCurricular(matriz);
        aula2.setData(LocalDate.now().plusDays(1));
        aula2.setNumeroAula(2);
        entityManager.persist(aula2);
        
        entityManager.flush();

        // Act
        int ultimoNumero = aulaRepository.findUltimoNumeroAula(matriz.getId());

        // Assert
        assertEquals(2, ultimoNumero);
    }
}