package com.fateczl.sistemaDeGestaoEscolar.usuario.responsavel;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/v1/responsavel")
public class ResponsavelController {

    @Autowired
    private ResponsavelService responsavelService;

    @Autowired
    private ResponsavelMapper responsavelMapper;

    @GetMapping
    public ResponseEntity<List<ResponsavelResponseDTO>> listarTodosResponsaveis() {
        List<Responsavel> listaEntity = responsavelService.findAll();
        List<ResponsavelResponseDTO> listaDTO = responsavelMapper.toResponseDTOList(listaEntity);
        return ResponseEntity.ok(listaDTO);
    }

    @GetMapping("/{id}")
    public ResponseEntity<ResponsavelResponseDTO> buscarResponsavelPorId(@PathVariable Long id) {
        Responsavel responsavel = responsavelService.findById(id);
        return ResponseEntity.ok(responsavelMapper.toResponseDTO(responsavel));
    }

    @PostMapping
    public ResponseEntity<ResponsavelResponseDTO> criarResponsavel(@Valid @RequestBody ResponsavelRequestDTO dto) {
        Responsavel novoResponsavel = responsavelMapper.toEntity(dto);
        Responsavel responsavelSalvo = responsavelService.create(novoResponsavel);
        ResponsavelResponseDTO responseDTO = responsavelMapper.toResponseDTO(responsavelSalvo);
        return ResponseEntity.status(201).body(responseDTO);
    }

    @PutMapping("/{id}")
    public ResponseEntity<ResponsavelResponseDTO> atualizarResponsavel(@PathVariable Long id,
            @Valid @RequestBody ResponsavelRequestDTO dto) {
        Responsavel dadosAtualizacao = responsavelMapper.toEntity(dto);
        Responsavel responsavel = responsavelService.update(id, dadosAtualizacao);
        return ResponseEntity.ok(responsavelMapper.toResponseDTO(responsavel));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deletarResponsavel(@PathVariable Long id) {
        responsavelService.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}