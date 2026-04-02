package com.fateczl.sistemaDeGestaoEscolar.academico.aula;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.fateczl.sistemaDeGestaoEscolar.config.CurrentUser;
import com.fateczl.sistemaDeGestaoEscolar.usuario.Usuario;

import io.swagger.v3.oas.annotations.parameters.RequestBody;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;

@RestController
@RequestMapping("/api/v1/aula")
@RequiredArgsConstructor
public class AulaController {

    private final AulaService service;
    private final AulaMapper mapper;
    private final CurrentUser currentUser;

    @GetMapping("/hoje")
    @PreAuthorize("hasRole('PROFESSOR')")
    public ResponseEntity<List<AulaResponseDTO>> aulasHoje() {
        Usuario u = currentUser.get();
        return ResponseEntity.ok(mapper.toDTOList(
                service.findAulasHojeDoProfessor(u.getId())));
    }

    @GetMapping("/matriz/{matrizId}")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<List<AulaResponseDTO>> listarPorMatriz(
            @PathVariable Long matrizId) {
        return ResponseEntity.ok(mapper.toDTOList(service.findByMatriz(matrizId)));
    }

    @PostMapping
    @PreAuthorize("hasRole('PROFESSOR')")
    public ResponseEntity<AulaResponseDTO> registrar(
            @Valid @RequestBody AulaRequestDTO dto) {
        return ResponseEntity.status(201).body(mapper.toDTO(service.registrar(dto)));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('PROFESSOR')")
    public ResponseEntity<AulaResponseDTO> atualizar(
            @PathVariable Long id,
            @Valid @RequestBody AulaRequestDTO dto) {
        return ResponseEntity.ok(mapper.toDTO(service.atualizar(id, dto)));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasAnyRole('PROFESSOR','COORDENADOR','ADMIN')")
    public ResponseEntity<Void> deletar(@PathVariable Long id) {
        service.deletar(id);
        return ResponseEntity.noContent().build();
    }

}
