package com.fateczl.sistemaDeGestaoEscolar.academico.matriz;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import io.swagger.v3.oas.annotations.parameters.RequestBody;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("api/v1/matriz-curricular")
@RequiredArgsConstructor
public class MatrizCurricularController {

    private final MatrizCurricularService service;
    private final MatrizCurricularMapper mapper;

    @GetMapping
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<List<MatrizCurricularResponseDTO>> listar(
            @RequestParam Long turmaId,
            @RequestParam int ano) {
        return ResponseEntity.ok(mapper.toDTOList(
                service.findByTurmaAndAno(turmaId, ano)));
    }

    @GetMapping("/{id}")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<MatrizCurricularResponseDTO> buscarPorId(
            @PathVariable Long id) {
        return ResponseEntity.ok(mapper.toDTO(service.findById(id)));
    }

    @GetMapping("/professor/{professorId}")
    @PreAuthorize("hasAnyRole('PROFESSOR', 'COORDENADOR', 'DIRETOR', 'ADMIN')")
    public ResponseEntity<List<MatrizCurricularResponseDTO>> listarPorProfessor(
            @PathVariable Long professorId,
            @RequestParam int ano) {
        return ResponseEntity.ok(mapper.toDTOList(
                service.findByProfessorAndAno(professorId, ano)));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'DIRETOR', 'COORDENADOR')")
    public ResponseEntity<MatrizCurricularResponseDTO> atualizar(
            @PathVariable Long id,
            @Valid @RequestBody MatrizCurricularRequestDTO dto) {
        return ResponseEntity.ok(mapper.toDTO(service.update(id, dto)));
    }

    @PatchMapping("/{id}/encerrar")
    @PreAuthorize("hasAnyRole('ADMIN', 'DIRETOR')")
    public ResponseEntity<Void> encerrar(@PathVariable Long id) {
        service.encerrar(id);
        return ResponseEntity.noContent().build();
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> deletar(@PathVariable Long id) {
        service.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}
