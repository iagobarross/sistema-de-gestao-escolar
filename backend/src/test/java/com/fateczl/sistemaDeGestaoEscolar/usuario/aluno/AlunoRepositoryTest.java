package com.fateczl.sistemaDeGestaoEscolar.usuario.aluno;

import static org.junit.jupiter.api.Assertions.*;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.boot.test.autoconfigure.orm.jpa.TestEntityManager;
import com.fateczl.sistemaDeGestaoEscolar.escola.Escola;
import com.fateczl.sistemaDeGestaoEscolar.usuario.responsavel.Responsavel;
import java.time.LocalDate;

@DataJpaTest(properties = {
        "spring.sql.init.mode=never",
        "spring.jpa.hibernate.ddl-auto=create-drop"
})
public class AlunoRepositoryTest {

    @Autowired
    private AlunoRepository alunoRepository;

    @Autowired
    private TestEntityManager entityManager;

    @Test
    public void deveRetornarTrue_QuandoEmailJaExistir() {
        // Arrange
        Escola escola = criarEscolaExemplo();
        Responsavel resp = criarResponsavelExemplo();

        Aluno aluno = Aluno.builder()
                .nome("Aluno Teste")
                .email("teste@email.com")
                .matricula("MAT123")
                .escola(escola)
                .responsavel(resp)
                .build();

        entityManager.persist(aluno);
        entityManager.flush();

        // Act
        boolean existe = alunoRepository.existsByEmail("teste@email.com");

        // Assert
        assertTrue(existe);
    }

    private Escola criarEscolaExemplo() {
        Escola e = new Escola();
        e.setNome("Escola Teste");
        e.setCnpj("11.111.111/0001-11");
        e.setCodigo("COD01");
        return entityManager.persist(e);
    }

    private Responsavel criarResponsavelExemplo() {
        Responsavel r = new Responsavel();
        r.setNome("Responsavel Teste");
        r.setEmail("resp@email.com");
        r.setCpf("123.456.789-00");
        return entityManager.persist(r);
    }
}