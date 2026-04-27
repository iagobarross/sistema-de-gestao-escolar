package com.fateczl.sistemaDeGestaoEscolar.usuario.aluno;

import static org.junit.jupiter.api.Assertions.*;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.jdbc.AutoConfigureTestDatabase;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.boot.test.autoconfigure.orm.jpa.TestEntityManager;
import org.springframework.test.context.ActiveProfiles;

import com.fateczl.sistemaDeGestaoEscolar.escola.Escola;
import com.fateczl.sistemaDeGestaoEscolar.usuario.responsavel.Responsavel;

@DataJpaTest
@ActiveProfiles("test")
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.NONE)
public class AlunoRepositoryTest {

    @Autowired
    private AlunoRepository alunoRepository;

    @Autowired
    private TestEntityManager entityManager;

    @Test
    public void deveRetornarTrue_QuandoEmailJaExistir() {
        Escola escola = criarEscolaExemplo();
        Responsavel resp = criarResponsavelExemplo();

        Aluno aluno = Aluno.builder()
                .nome("Aluno Teste")
                .email("teste@email.com")
                .matricula("MAT123")
                .escola(escola)
                .responsavel(resp)
                .senha("123456")
                .build();

        entityManager.persist(aluno);
        entityManager.flush();

        boolean existe = alunoRepository.existsByEmail("teste@email.com");

        assertTrue(existe);
    }

    @Test
    public void deveRetornarTrue_QuandoMatriculaJaExistir() {
        Escola escola = criarEscolaExemplo();
        Responsavel resp = criarResponsavelExemplo();

        Aluno aluno = Aluno.builder()
                .nome("Aluno 2")
                .email("outro@email.com")
                .matricula("RA9999")
                .escola(escola)
                .responsavel(resp)
                .senha("123456")
                .build();

        entityManager.persist(aluno);
        entityManager.flush();

        boolean existe = alunoRepository.existsByMatricula("RA9999");

        assertTrue(existe);
    }

    @Test
    public void deveRetornarFalse_QuandoEmailNaoExistir() {
        boolean existe = alunoRepository.existsByEmail("naoexiste@email.com");
        assertFalse(existe);
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
        r.setCpf("12345678901");
        r.setSenha("senha123");
        return entityManager.persist(r);
    }
}