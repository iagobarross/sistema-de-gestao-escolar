package com.fateczl.sistemaDeGestaoEscolar.academico.frequencia;

import static org.junit.jupiter.api.Assertions.*;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.boot.test.autoconfigure.orm.jpa.TestEntityManager;
import org.springframework.test.context.ActiveProfiles;

import com.fateczl.sistemaDeGestaoEscolar.academico.aula.Aula;
import com.fateczl.sistemaDeGestaoEscolar.academico.matriz.MatrizCurricular;
import com.fateczl.sistemaDeGestaoEscolar.usuario.aluno.Aluno;

@DataJpaTest
@ActiveProfiles("test")
public class FrequenciaRepositoryTest {

    @Autowired
    private FrequenciaRepository frequenciaRepository;

    @Autowired
    private TestEntityManager entityManager;

    @Test
    public void deveCalcularPercentualPresencaCorretamente() {
        // Arrange
        MatrizCurricular matriz = new MatrizCurricular();
        entityManager.persist(matriz);

        Aluno aluno = new Aluno();
        aluno.setNome("João Silva");
        entityManager.persist(aluno);

        // Aula 1: Presente
        Aula aula1 = new Aula();
        aula1.setMatrizCurricular(matriz);
        entityManager.persist(aula1);

        Frequencia f1 = new Frequencia();
        f1.setAula(aula1);
        f1.setAluno(aluno);
        f1.setPresente(true);
        entityManager.persist(f1);

        // Aula 2: Ausente
        Aula aula2 = new Aula();
        aula2.setMatrizCurricular(matriz);
        entityManager.persist(aula2);

        Frequencia f2 = new Frequencia();
        f2.setAula(aula2);
        f2.setAluno(aluno);
        f2.setPresente(false);
        entityManager.persist(f2);

        entityManager.flush();

        // Act
        Double percentual = frequenciaRepository.calcularPercentualPresenca(matriz.getId(), aluno.getId());

        // Assert (1 presente de 2 aulas = 0.5 ou 50%)
        assertEquals(0.5, percentual, 0.01);
    }
}