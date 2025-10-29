// Pacote: com.fateczl.sistemaDeGestaoEscolar.aluno
package com.fateczl.sistemaDeGestaoEscolar.aluno;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

@Repository
@Transactional
public interface AlunoRepository extends JpaRepository<Aluno, Long> {

    // Validações de negócio que o Service usará
    boolean existsByEmail(String email);

    boolean existsByMatricula(String matricula);

    // Usado para o update, para evitar conflito com o próprio ID
    Optional<Aluno> findByEmailAndIdNot(String email, Long id);

    Optional<Aluno> findByMatriculaAndIdNot(String matricula, Long id);
}