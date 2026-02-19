package com.fateczl.sistemaDeGestaoEscolar.usuario.aluno;

import org.springframework.data.jpa.domain.Specification;
import com.fateczl.sistemaDeGestaoEscolar.escola.Escola;
import jakarta.persistence.criteria.Join;

public class AlunoSpecification {

    public static Specification<Aluno> comFiltros(String nome, String matricula, Long escolaId) {
        return (root, query, builder) -> {
            var predicates = builder.conjunction();

            if (nome != null && !nome.isEmpty()) {
                predicates = builder.and(predicates,
                        builder.like(builder.lower(root.get("nome")), "%" + nome.toLowerCase() + "%"));
            }

            if (matricula != null && !matricula.isEmpty()) {
                predicates = builder.and(predicates,
                        builder.like(root.get("matricula"), "%" + matricula + "%"));
            }

            if (escolaId != null) {
                predicates = builder.and(predicates,
                        builder.equal(root.get("escola").get("id"), escolaId));
            }

            return predicates;
        };
    }
}