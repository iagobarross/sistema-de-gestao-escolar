package com.fateczl.sistemaDeGestaoEscolar.usuario.funcionario;

import com.fateczl.sistemaDeGestaoEscolar.escola.Escola;
import com.fateczl.sistemaDeGestaoEscolar.usuario.Usuario;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.experimental.SuperBuilder;

@Entity
@Table(name = "funcionario")
@Getter
@Setter
@SuperBuilder
@NoArgsConstructor
@AllArgsConstructor
public class Funcionario extends Usuario {

    public enum Cargo {
        ADMIN,       // Acesso total (Prefeitura/TI)
        DIRETOR,     // Acesso à sua própria escola inteira
        COORDENADOR, // Acesso a relatórios e ocorrências disciplinares
        PROFESSOR,   // Acesso apenas às suas turmas/diários
        SECRETARIA   // Acesso a matrículas e documentos
    }

    // 1. Mapeamento do Cargo (Role)
    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 50)
    private Cargo cargo;

    // 2. Relacionamento com a Escola
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "escola_id", nullable = true)
    private Escola escola;

    // Você pode adicionar outros campos específicos aqui futuramente,
    // como matrícula da prefeitura, carga horária, etc.

}


