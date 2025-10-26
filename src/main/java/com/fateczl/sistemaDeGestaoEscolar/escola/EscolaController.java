package com.fateczl.sistemaDeGestaoEscolar.escola;

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
@RequestMapping("/api/v1/escola")
public class EscolaController {

	@Autowired
	private EscolaService escolaService;
	
	@Autowired
	private EscolaMapper escolaMapper;
	
	@GetMapping
	public ResponseEntity<List<EscolaResponseDTO>> listarTodasEscolas(){
		List<Escola> listaEntity = escolaService.findAll();
		List<EscolaResponseDTO> listaDTO = escolaMapper.toResponseDTOList(listaEntity);
		return ResponseEntity.ok(listaDTO);
	}
	
	@GetMapping("/{id}")
	public ResponseEntity<EscolaResponseDTO> buscarEscolaPorId(@PathVariable Long id){
		Escola escola = escolaService.findById(id);
		return ResponseEntity.ok(escolaMapper.toResponseDTO(escola));
	}
	
	@GetMapping("searchByName")
	public List<Escola> buscarEscolaPorNome(@RequestParam(required=false) String nome){
		return escolaService.findByName(nome);
	}
	
	@PostMapping
	public ResponseEntity<EscolaResponseDTO> criarEscola(@Valid @RequestBody EscolaRequestDTO dto){
		Escola novaEscola = escolaMapper.toEntity(dto);
		Escola escolaSalva = escolaService.create(novaEscola);
		EscolaResponseDTO responseDTO = escolaMapper.toResponseDTO(escolaSalva);
		return ResponseEntity.status(201).body(responseDTO);
	}
	
	@PutMapping("/{id}")
	public ResponseEntity<EscolaResponseDTO> atualizarEscola(@PathVariable Long id, @Valid @RequestBody EscolaRequestDTO dto){
		Escola dadosAtualizacao = escolaMapper.toEntity(dto);
		Escola escola = escolaService.update(id,dadosAtualizacao);
		return ResponseEntity.ok(escolaMapper.toResponseDTO(escola));
	}
	
	@DeleteMapping("/{id}")
	public ResponseEntity<Void> deletarEscola(@PathVariable Long id){
		escolaService.deleteById(id);
		return ResponseEntity.noContent().build();
	}
	

}
