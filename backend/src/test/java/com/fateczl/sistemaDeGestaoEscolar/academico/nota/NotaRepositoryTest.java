package com.fateczl.sistemaDeGestaoEscolar.academico.nota;

import static org.junit.jupiter.api.Assertions.*;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.boot.test.autoconfigure.orm.jpa.TestEntityManager;
import org.springframework.test.context.ActiveProfiles;

import com.fateczl.sistemaDeGestaoEscolar.academico.avaliacao.Avaliacao;
import com.fateczl.sistemaDeGestaoEscolar.academico.matriz.MatrizCurricular;
import com.fateczl.sistemaDeGestaoEscolar.usuario.aluno.Aluno;

@DataJpaTest
@ActiveProfiles("test")
public class NotaRepositoryTest {

    @Autowired
    private NotaRepository notaRepository;

    @Autowired
    private TestEntityManager entityManager;

    @Test
    public void deveCalcularMediaBimestreCorretamente() {
        // Arrange
        MatrizCurricular matriz = new MatrizCurricular();
        // Preencher campos obrigatórios da matriz conforme sua entidade...
        entityManager.persist(matriz);

        Aluno aluno = new Aluno();
        aluno.setNome("João");
        entityManager.persist(aluno);

        // Avaliação 1 (Peso 2, Nota 10)
        Avaliacao av1 = new Avaliacao();
        av1.setMatrizCurricular(matriz);
        av1.setBimestre(1);
        av1.setPeso(2.0);
        entityManager.persist(av1);

        Nota n1 = new Nota();
        n1.setAvaliacao(av1);
        n1.setAluno(aluno);
        n1.setValor(10.0);
        entityManager.persist(n1);

        // Avaliação 2 (Peso 1, Nota 4)
        Avaliacao av2 = new Avaliacao();
        av2.setMatrizCurricular(matriz);
        av2.setBimestre(1);
        av2.setPeso(1.0);
        entityManager.persist(av2);

        Nota n2 = new Nota();
        n2.setAvaliacao(av2);
        n2.setAluno(aluno);
        n2.setValor(4.0);
        entityManager.persist(n2);

        entityManager.flush();

        // Act: (10*2 + 4*1) / (2+1) = 24 / 3 = 8.0
        Double media = notaRepository.calcularMediaBimestre(matriz.getId(), aluno.getId(), 1);

        // Assert
        assertEquals(8.0, media, 0.001);
    }
}