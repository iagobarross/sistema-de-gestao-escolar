package com.fateczl.sistemaDeGestaoEscolar.usuario.funcionario;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface FuncionarioRepository extends JpaRepository<Funcionario, Long> {

    Optional<Funcionario> findByEmail(String email);
    
    boolean existsByEmail(String email);

    Optional<Funcionario> findByEmailAndIdNot(String email, Long id);


}