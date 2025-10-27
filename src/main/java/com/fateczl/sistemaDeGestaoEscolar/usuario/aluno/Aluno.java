package com.fateczl.sistemaDeGestaoEscolar.usuario.aluno;

import java.time.LocalDate;

import com.fateczl.sistemaDeGestaoEscolar.usuario.Usuario;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import lombok.AccessLevel;
import lombok.AllArgsConstructor;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.experimental.SuperBuilder;

//pesquisar o superbuilder
@Entity
@Table(name="aluno")
@Getter
@Setter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor
@SuperBuilder
@EqualsAndHashCode(callSuper = true)
public class Aluno extends Usuario {
    
    private String matricula;
    private LocalDate dataNascimento;
    private Long responsavelId;
    
}
