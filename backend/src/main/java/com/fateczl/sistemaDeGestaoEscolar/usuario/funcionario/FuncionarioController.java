package com.fateczl.sistemaDeGestaoEscolar.usuario.funcionario;

import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/funcionario")
public class FuncionarioController {

    @Autowired
    private FuncionarioService funcionarioService;

    @Autowired
    private FuncionarioMapper funcionarioMapper;

    @GetMapping
    public ResponseEntity<List<FuncionarioResponseDTO>> listarTodos() {
        List<Funcionario> funcionarios = funcionarioService.findAll();
        return ResponseEntity.ok(funcionarioMapper.toResponseDTOList(funcionarios));
    }

    @GetMapping("/{id}")
    public ResponseEntity<FuncionarioResponseDTO> buscarPorId(@PathVariable Long id) {
        Funcionario funcionario = funcionarioService.findById(id);
        return ResponseEntity.ok(funcionarioMapper.toResponseDTO(funcionario));
    }

    @PostMapping
    public ResponseEntity<FuncionarioResponseDTO> criar(@Valid @RequestBody FuncionarioRequestDTO dto) {
        Funcionario novoFuncionario = funcionarioMapper.toEntity(dto);
        Funcionario salvo = funcionarioService.create(novoFuncionario, dto.getEscolaId());
        return ResponseEntity.status(201).body(funcionarioMapper.toResponseDTO(salvo));
    }

    @PutMapping("/{id}")
    public ResponseEntity<FuncionarioResponseDTO> atualizar(@PathVariable Long id,
                                                          @Valid @RequestBody FuncionarioRequestDTO dto) {
        Funcionario dados = funcionarioMapper.toEntity(dto);
        Funcionario atualizado = funcionarioService.update(id, dados, dto.getEscolaId());
        return ResponseEntity.ok(funcionarioMapper.toResponseDTO(atualizado));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deletar(@PathVariable Long id) {
        funcionarioService.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}

