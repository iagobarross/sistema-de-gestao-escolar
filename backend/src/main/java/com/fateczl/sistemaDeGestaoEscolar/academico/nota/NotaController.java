package com.fateczl.sistemaDeGestaoEscolar.academico.nota;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/v1/nota")
@RequiredArgsConstructor
public class NotaController {

    private final NotaService service;
    private final NotaMapper mapper;

    @PostMapping("/lancar")
    @PreAuthorize("hasRole('PROFESSOR')")
    public ResponseEntity<List<NotaResponseDTO>> lancarNotas(
            @Valid @RequestBody LancarNotasRequestDTO dto) {
        return ResponseEntity.status(201)
                .body(mapper.toDTOList(service.lancarNotas(dto)));
    }

    @PatchMapping("/{id}")
    @PreAuthorize("hasAnyRole('PROFESSOR','COORDENADOR')")
    public ResponseEntity<NotaResponseDTO> corrigir(
            @PathVariable Long id,
            @RequestParam double valor,
            @RequestParam(required = false) String observacao) {
        return ResponseEntity.ok(mapper.toDTO(
                service.corrigirNota(id, valor, observacao)));
    }

    @GetMapping("/avaliacao/{avaliacaoId}")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<List<NotaResponseDTO>> listarPorAvaliacao(
            @PathVariable Long avaliacaoId) {
        return ResponseEntity.ok(mapper.toDTOList(service.findByAvaliacao(avaliacaoId)));
    }

    @GetMapping("/boletim/{alunoId}")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<List<BoletimDisciplinaDTO>> boletim(
            @PathVariable Long alunoId,
            @RequestParam int ano) {
        return ResponseEntity.ok(service.gerarBoletim(alunoId, ano));
    }
}
