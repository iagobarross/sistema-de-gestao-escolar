package com.fateczl.sistemaDeGestaoEscolar.usuario.professor;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;
import java.util.Optional;

@Repository
@Transactional
public interface ProfessorRepository extends JpaRepository<Professor, Long> {

    boolean existsByEmail(String email);

    Optional<Professor> findByEmailAndIdNot(String email, Long id);
}