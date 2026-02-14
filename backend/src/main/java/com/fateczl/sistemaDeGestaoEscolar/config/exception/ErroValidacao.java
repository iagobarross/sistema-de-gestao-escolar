package com.fateczl.sistemaDeGestaoEscolar.config.exception;

// Usando o seu lombok já configurado no pom.xml
import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class ErroValidacao {
    private String campo;
    private String mensagem;
}