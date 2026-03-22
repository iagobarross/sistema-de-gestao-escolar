package com.fateczl.sistemaDeGestaoEscolar.usuario.funcionario;

import com.fateczl.sistemaDeGestaoEscolar.usuario.professor.Professor;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface FuncionarioRepository extends JpaRepository<Funcionario, Long> {

    boolean existsByEmail(String email);

    Optional<Professor> findByEmailAndIdNot(String email, Long id);


}