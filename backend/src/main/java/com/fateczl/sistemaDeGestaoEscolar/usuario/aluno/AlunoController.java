package com.fateczl.sistemaDeGestaoEscolar.usuario.aluno;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/v1/aluno")
public class AlunoController {

    @Autowired
    private AlunoService alunoService;

    @Autowired
    private AlunoMapper alunoMapper;

    @GetMapping
    @PreAuthorize("hasAnyRole('ADMIN','DIRETOR','SECRETARIA','COORDENADOR', 'PROFESSOR', 'RESPONSAVEL')")
    public ResponseEntity<Page<AlunoResponseDTO>> listarTodosAlunos(
            @PageableDefault(page = 0, size = 10, sort = "nome", direction = Sort.Direction.ASC) Pageable pageable,
            @RequestParam(required = false) String nome,
            @RequestParam(required = false) String matricula,
            @RequestParam(required = false) Long escolaId,
            @RequestParam(required = false) Long responsavelId
    ) {
        Page<Aluno> pageAlunos = alunoService.findAll(pageable, nome, matricula, escolaId, responsavelId);
        Page<AlunoResponseDTO> pageDTO = pageAlunos.map(alunoMapper::toResponseDTO);
        return ResponseEntity.ok(pageDTO);
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN','DIRETOR','SECRETARIA','COORDENADOR', 'PROFESSOR','ALUNO','RESPONSAVEL')")
    public ResponseEntity<AlunoResponseDTO> buscarAlunoPorId(@PathVariable Long id) {
        Aluno aluno = alunoService.findById(id);
        return ResponseEntity.ok(alunoMapper.toResponseDTO(aluno));
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('ADMIN','DIRETOR','SECRETARIA')")
    public ResponseEntity<AlunoResponseDTO> criarAluno(@Valid @RequestBody AlunoRequestDTO dto) {
        Aluno novoAluno = alunoMapper.toEntity(dto);
        Aluno alunoSalvo = alunoService.create(novoAluno, dto.getEscolaId(), dto.getResponsavelId());
        AlunoResponseDTO responseDTO = alunoMapper.toResponseDTO(alunoSalvo);
        return ResponseEntity.status(201).body(responseDTO);
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN','DIRETOR','SECRETARIA')")
    public ResponseEntity<AlunoResponseDTO> atualizarAluno(@PathVariable Long id,
            @Valid @RequestBody AlunoRequestDTO dto) {
        Aluno dadosAtualizacao = alunoMapper.toEntity(dto);

        Aluno alunoAtualizado = alunoService.update(id, dadosAtualizacao, dto.getEscolaId(), dto.getResponsavelId());

        return ResponseEntity.ok(alunoMapper.toResponseDTO(alunoAtualizado));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN','DIRETOR')")
    public ResponseEntity<Void> deletarAluno(@PathVariable Long id) {
        alunoService.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}