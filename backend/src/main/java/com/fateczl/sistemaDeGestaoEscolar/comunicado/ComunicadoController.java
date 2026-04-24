package com.fateczl.sistemaDeGestaoEscolar.comunicado;

import com.fateczl.sistemaDeGestaoEscolar.config.CurrentUser;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/v1/comunicado")
@RequiredArgsConstructor
public class ComunicadoController {

    private final ComunicadoService service;
    private final CurrentUser currentUser;

    @GetMapping
    @PreAuthorize("hasRole('RESPONSAVEL')")
    public ResponseEntity<List<ComunicadoResponseDTO>> listar() {
        Long responsavelId = currentUser.get().getId();
        List<Comunicado> lista = service.findByResponsavel(responsavelId);
        List<ComunicadoResponseDTO> dtos = lista.stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
        return ResponseEntity.ok(dtos);
    }

    @GetMapping("/nao-lidos/count")
    @PreAuthorize("hasRole('RESPONSAVEL')")
    public ResponseEntity<Map<String, Long>> contarNaoLidos() {
        Long responsavelId = currentUser.get().getId();
        return ResponseEntity.ok(Map.of("total", service.contarNaoLidos(responsavelId)));
    }

    @PatchMapping("/{id}/ler")
    @PreAuthorize("hasRole('RESPONSAVEL')")
    public ResponseEntity<ComunicadoResponseDTO> marcarLido(@PathVariable Long id) {
        return ResponseEntity.ok(toDTO(service.marcarComoLido(id)));
    }

    private ComunicadoResponseDTO toDTO(Comunicado c) {
        ComunicadoResponseDTO dto = new ComunicadoResponseDTO();
        dto.setId(c.getId());
        dto.setTitulo(c.getTitulo());
        dto.setCorpo(c.getCorpo());
        dto.setLido(c.isLido());
        dto.setCriadoEm(c.getCriadoEm());
        dto.setLidoEm(c.getLidoEm());
        if (c.getAluno() != null) dto.setNomeAluno(c.getAluno().getNome());
        if (c.getAutor() != null) {
            dto.setNomeAutor(c.getAutor().getNome());
            if (c.getAutor().getEscola() != null)
                dto.setNomeEscola(c.getAutor().getEscola().getNome());
        }
        return dto;
    }
}