package com.fateczl.sistemaDeGestaoEscolar.config.exception;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import jakarta.servlet.http.HttpServletRequest;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@RestControllerAdvice
public class GlobalExceptionHandler {

    // 1. Tratamento para erros de @Valid (ex: CNPJ inválido, Nome em branco)
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<RespostaErro> handleValidationErrors(MethodArgumentNotValidException ex, HttpServletRequest request) {
        List<ErroValidacao> errosDeValidacao = new ArrayList<>();

        for (FieldError fieldError : ex.getBindingResult().getFieldErrors()) {
            errosDeValidacao.add(new ErroValidacao(fieldError.getField(), fieldError.getDefaultMessage()));
        }

        RespostaErro resposta = new RespostaErro();
        resposta.setTimestamp(LocalDateTime.now());
        resposta.setStatus(HttpStatus.BAD_REQUEST.value()); // HTTP 400
        resposta.setErro("Erro na validação dos dados.");
        resposta.setCaminho(request.getRequestURI());
        resposta.setValidacoes(errosDeValidacao);

        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(resposta);
    }

    // 2. Tratamento para as suas regras de negócio (ex: "CNPJ já cadastrado")
    @ExceptionHandler(BusinessException.class)
    public ResponseEntity<RespostaErro> handleBusinessRules(BusinessException ex, HttpServletRequest request) {
        RespostaErro resposta = new RespostaErro();
        resposta.setTimestamp(LocalDateTime.now());
        resposta.setStatus(HttpStatus.UNPROCESSABLE_ENTITY.value()); // HTTP 422
        resposta.setErro(ex.getMessage());
        resposta.setCaminho(request.getRequestURI());

        return ResponseEntity.status(HttpStatus.UNPROCESSABLE_ENTITY).body(resposta);
    }

    // 3. Tratamento para quando busca por um ID que não existe
    @ExceptionHandler(ResourceNotFoundException.class)
    public ResponseEntity<RespostaErro> handleNotFound(ResourceNotFoundException ex, HttpServletRequest request) {
        RespostaErro resposta = new RespostaErro();
        resposta.setTimestamp(LocalDateTime.now());
        resposta.setStatus(HttpStatus.NOT_FOUND.value()); // HTTP 404
        resposta.setErro(ex.getMessage());
        resposta.setCaminho(request.getRequestURI());

        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(resposta);
    }
}