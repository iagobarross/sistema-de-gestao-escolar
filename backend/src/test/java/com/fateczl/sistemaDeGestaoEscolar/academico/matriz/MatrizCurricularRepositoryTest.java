package com.fateczl.sistemaDeGestaoEscolar.academico.matriz;

import static org.junit.jupiter.api.Assertions.*;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.boot.test.autoconfigure.orm.jpa.TestEntityManager;
import org.springframework.test.context.ActiveProfiles;

import com.fateczl.sistemaDeGestaoEscolar.academico.StatusMatriz;
import com.fateczl.sistemaDeGestaoEscolar.usuario.funcionario.Funcionario;
import java.util.List;

@DataJpaTest
@ActiveProfiles("test")
public class MatrizCurricularRepositoryTest {

    @Autowired
    private MatrizCurricularRepository repository;

    @Autowired
    private TestEntityManager entityManager;

    @Test
    public void deveRetornarApenasMatrizesAtivasDoProfessor() {
        // Arrange
        Funcionario professor = new Funcionario();
        professor.setNome("Marcio");
        entityManager.persist(professor);

        MatrizCurricular ativa = new MatrizCurricular();
        ativa.setProfessor(professor);
        ativa.setAno(2026);
        ativa.setStatus(StatusMatriz.ATIVA);
        ativa.setCargaHorariaTotal(80);
        // Note: Em um cenário real, você precisaria persistir Turma e Disciplina aqui
        // também
        entityManager.persist(ativa);

        MatrizCurricular encerrada = new MatrizCurricular();
        encerrada.setProfessor(professor);
        encerrada.setAno(2026);
        encerrada.setStatus(StatusMatriz.ENCERRADA);
        encerrada.setCargaHorariaTotal(80);
        entityManager.persist(encerrada);

        entityManager.flush();

        // Act
        List<MatrizCurricular> result = repository.findAtivasByProfessorAndAno(professor.getId(), 2026);

        // Assert
        assertEquals(1, result.size());
        assertEquals(StatusMatriz.ATIVA, result.get(0).getStatus());
    }
}