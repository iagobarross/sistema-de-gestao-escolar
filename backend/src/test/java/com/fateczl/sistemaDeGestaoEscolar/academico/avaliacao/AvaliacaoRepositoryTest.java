package com.fateczl.sistemaDeGestaoEscolar.academico.avaliacao;

import static org.junit.jupiter.api.Assertions.*;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.boot.test.autoconfigure.orm.jpa.TestEntityManager;
import org.springframework.test.context.ActiveProfiles;

import com.fateczl.sistemaDeGestaoEscolar.academico.matriz.MatrizCurricular;
import com.fateczl.sistemaDeGestaoEscolar.academico.TipoAvaliacao;
import java.time.LocalDate;
import java.util.List;

@DataJpaTest
@ActiveProfiles("test")
public class AvaliacaoRepositoryTest {

    @Autowired
    private AvaliacaoRepository avaliacaoRepository;

    @Autowired
    private TestEntityManager entityManager;

    @Test
    public void deveBuscarAvaliacoesPorMatrizEBimestre() {
        // Arrange
        MatrizCurricular matriz = new MatrizCurricular();
        entityManager.persist(matriz);

        Avaliacao av1 = new Avaliacao();
        av1.setMatrizCurricular(matriz);
        av1.setTitulo("Prova P1");
        av1.setBimestre(1);
        av1.setTipo(TipoAvaliacao.PROVA);
        av1.setDataAplicacao(LocalDate.now());
        entityManager.persist(av1);

        Avaliacao av2 = new Avaliacao();
        av2.setMatrizCurricular(matriz);
        av2.setTitulo("Trabalho T1");
        av2.setBimestre(2); // Outro bimestre
        av2.setTipo(TipoAvaliacao.TRABALHO);
        av2.setDataAplicacao(LocalDate.now().plusDays(10));
        entityManager.persist(av2);

        entityManager.flush();

        // Act
        List<Avaliacao> resultados = avaliacaoRepository
                .findByMatrizCurricularIdAndBimestreOrderByDataAplicacaoAsc(matriz.getId(), 1);

        // Assert
        assertEquals(1, resultados.size());
        assertEquals("Prova P1", resultados.get(0).getTitulo());
    }
}