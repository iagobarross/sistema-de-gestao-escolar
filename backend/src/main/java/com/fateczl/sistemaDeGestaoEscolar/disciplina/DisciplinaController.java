package com.fateczl.sistemaDeGestaoEscolar.disciplina;

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
import org.springframework.web.bind.annotation.RestController;


import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/v1/disciplina")
public class DisciplinaController {
    
    @Autowired
    private DisciplinaService disciplinaService;

    @Autowired
    private DisciplinaMapper disciplinaMapper;

    @GetMapping
    public ResponseEntity<List<DisciplinaResponseDTO>> listarTodasDisciplinas(){
        List<Disciplina> listaEntity = disciplinaService.findAll();
        List<DisciplinaResponseDTO> listaDTO = disciplinaMapper.toResponseDTOList(listaEntity);
        return ResponseEntity.ok(listaDTO);
    }

    @GetMapping("/{id}")
    public ResponseEntity<DisciplinaResponseDTO> buscarDisciplinaPorId(@PathVariable Long id){
        Disciplina disciplina = disciplinaService.findById(id);
        return ResponseEntity.ok(disciplinaMapper.toResponseDTO(disciplina));
    }

    @PostMapping
    public ResponseEntity<DisciplinaResponseDTO> criarDisciplina(@Valid @RequestBody DisciplinaRequestDTO dto){
        Disciplina novaDisciplina = disciplinaMapper.toEntity(dto);
        Disciplina disciplinaSalva = disciplinaService.create(novaDisciplina);
        DisciplinaResponseDTO responseDTO = disciplinaMapper.toResponseDTO(disciplinaSalva);
        return ResponseEntity.status(201).body(responseDTO);
    }

    @PutMapping("/{id}")
    public ResponseEntity<DisciplinaResponseDTO> atualizarEscola(@PathVariable Long id, @Valid @RequestBody DisciplinaRequestDTO dto){
        Disciplina dadosAtualizacao = disciplinaMapper.toEntity(dto);
        Disciplina disciplina = disciplinaService.update(id, dadosAtualizacao);
        return ResponseEntity.ok(disciplinaMapper.toResponseDTO(disciplina));
    }

    @DeleteMapping("/{id}")
	public ResponseEntity<Void> deletarDisciplina(@PathVariable Long id){
		disciplinaService.deleteById(id);
		return ResponseEntity.noContent().build();
	}
}
