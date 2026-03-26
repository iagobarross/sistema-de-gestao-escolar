package com.fateczl.sistemaDeGestaoEscolar.academico.avaliacao;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.fateczl.sistemaDeGestaoEscolar.config.CurrentUser;
import com.fateczl.sistemaDeGestaoEscolar.usuario.Usuario;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/v1/avaliacao")
@RequiredArgsConstructor
public class AvaliacaoController {

    private final AvaliacaoService service;
    private final AvaliacaoMapper mapper;
    private final CurrentUser currentUser;

    @GetMapping("/matriz/{matrizId}")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<List<AvaliacaoResponseDTO>> listarPorMatriz(
            @PathVariable Long matrizId) {
        return ResponseEntity.ok(mapper.toDTOList(service.findByMatriz(matrizId)));
    }

    @GetMapping("/proximas")
    @PreAuthorize("hasRole('PROFESSOR')")
    public ResponseEntity<List<AvaliacaoResponseDTO>> proximasDosProfessor() {
        Usuario u = currentUser.get();
        return ResponseEntity.ok(mapper.toDTOList(
                service.findProximasDosProfessor(u.getId())));
    }

    @PostMapping
    @PreAuthorize("hasRole('PROFESSOR')")
    public ResponseEntity<AvaliacaoResponseDTO> criar(
            @Valid @RequestBody AvaliacaoRequestDTO dto) {
        return ResponseEntity.status(201).body(mapper.toDTO(service.create(dto)));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('PROFESSOR')")
    public ResponseEntity<AvaliacaoResponseDTO> atualizar(
            @PathVariable Long id,
            @Valid @RequestBody AvaliacaoRequestDTO dto) {
        return ResponseEntity.ok(mapper.toDTO(service.update(id, dto)));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasAnyRole('PROFESSOR','COORDENADOR','ADMIN')")
    public ResponseEntity<Void> deletar(@PathVariable Long id) {
        service.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}