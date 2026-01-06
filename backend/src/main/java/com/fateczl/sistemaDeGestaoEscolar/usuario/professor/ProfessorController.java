package com.fateczl.sistemaDeGestaoEscolar.usuario.professor;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/v1/professor")
public class ProfessorController {

    @Autowired
    private ProfessorService professorService;

    @Autowired
    private ProfessorMapper professorMapper;

    @GetMapping
    public ResponseEntity<List<ProfessorResponseDTO>> listarTodos() {
        List<Professor> professores = professorService.findAll();
        return ResponseEntity.ok(professorMapper.toResponseDTOList(professores));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ProfessorResponseDTO> buscarPorId(@PathVariable Long id) {
        Professor professor = professorService.findById(id);
        return ResponseEntity.ok(professorMapper.toResponseDTO(professor));
    }

    @PostMapping
    public ResponseEntity<ProfessorResponseDTO> criar(@Valid @RequestBody ProfessorRequestDTO dto) {
        Professor novoProfessor = professorMapper.toEntity(dto);
        Professor salvo = professorService.create(novoProfessor, dto.getEscolaId());
        return ResponseEntity.status(201).body(professorMapper.toResponseDTO(salvo));
    }

    @PutMapping("/{id}")
    public ResponseEntity<ProfessorResponseDTO> atualizar(@PathVariable Long id,
            @Valid @RequestBody ProfessorRequestDTO dto) {
        Professor dados = professorMapper.toEntity(dto);
        Professor atualizado = professorService.update(id, dados, dto.getEscolaId());
        return ResponseEntity.ok(professorMapper.toResponseDTO(atualizado));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deletar(@PathVariable Long id) {
        professorService.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}