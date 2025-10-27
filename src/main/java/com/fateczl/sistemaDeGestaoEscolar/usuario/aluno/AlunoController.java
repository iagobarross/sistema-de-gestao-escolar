package com.fateczl.sistemaDeGestaoEscolar.usuario.aluno;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/v1/aluno")
public class AlunoController {

    @Autowired
    private AlunoService alunoService;

    @Autowired
    private AlunoMapper alunoMapper;

    @GetMapping("/{id}")
    public ResponseEntity<AlunoResponseDTO> buscarAlunoPorId(@PathVariable Long id){
        Aluno aluno = alunoService.findById(id);
        return ResponseEntity.ok(alunoMapper.toResponseDTO(aluno));
    }

    @GetMapping
    public ResponseEntity<List<AlunoResponseDTO>> listarTodosAlunos(){
        List<Aluno> listaEntity = alunoService.findAll();
        List<AlunoResponseDTO> listaDTO = alunoMapper.toResponseDTOList(listaEntity);
        return ResponseEntity.ok(listaDTO);
    }
    
    @PostMapping
    public ResponseEntity<AlunoResponseDTO> criarAluno(@Valid @RequestBody AlunoRequestDTO dto){
        Aluno novoAluno = alunoMapper.toEntity(dto);
        Aluno alunoSalvo = alunoService.create(novoAluno);
        AlunoResponseDTO responseDTO = alunoMapper.toResponseDTO(alunoSalvo);
        return ResponseEntity.status(201).body(responseDTO);
    }

    @PutMapping("/{id}")
    public ResponseEntity<AlunoResponseDTO> atualizarAluno(@PathVariable Long id,@Valid @RequestBody AlunoRequestDTO dto){
        Aluno dadosAtualizacao = alunoMapper.toEntity(dto);
        Aluno aluno = alunoService.update(id, dadosAtualizacao);
        return ResponseEntity.ok(alunoMapper.toResponseDTO(aluno));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deletarAluno(@PathVariable Long id){
        alunoService.deleteById(id);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/searchByName")
    public List<Aluno> buscarAlunoPorNome(@RequestParam(required=false) String nome){
        return alunoService.findByName(nome);
    }


}
