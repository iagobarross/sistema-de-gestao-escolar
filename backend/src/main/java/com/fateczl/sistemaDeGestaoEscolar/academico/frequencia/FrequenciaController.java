package com.fateczl.sistemaDeGestaoEscolar.academico.frequencia;
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
@RequestMapping("/api/v1/frequencia")
@RequiredArgsConstructor
public class FrequenciaController {

    private final FrequenciaService service;
    private final FrequenciaMapper mapper;

    @PostMapping("/chamada")
    @PreAuthorize("hasRole('PROFESSOR')")
    public ResponseEntity<List<FrequenciaResponseDTO>> lancarChamada(
            @Valid @RequestBody LancarChamadaRequestDTO dto) {
        return ResponseEntity.status(201)
                .body(mapper.toDTOList(service.lancarChamada(dto)));
    }

    @GetMapping("/aula/{aulaId}")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<List<FrequenciaResponseDTO>> listarPorAula(
            @PathVariable Long aulaId) {
        return ResponseEntity.ok(mapper.toDTOList(service.findByAula(aulaId)));
    }

    @PatchMapping("/{id}")
    @PreAuthorize("hasAnyRole('PROFESSOR','SECRETARIA','COORDENADOR')")
    public ResponseEntity<FrequenciaResponseDTO> corrigir(
            @PathVariable Long id,
            @RequestParam boolean presente,
            @RequestParam(required = false) String justificativa) {
        return ResponseEntity.ok(mapper.toDTO(
                service.corrigirPresenca(id, presente, justificativa)));
    }

    @GetMapping("/percentual")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<Double> percentualPresenca(
            @RequestParam Long matrizId,
            @RequestParam Long alunoId) {
        return ResponseEntity.ok(
                service.calcularPercentualPresenca(matrizId, alunoId));
    }
}