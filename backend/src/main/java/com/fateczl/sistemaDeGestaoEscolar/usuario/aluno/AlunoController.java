// Pacote: com.fateczl.sistemaDeGestaoEscolar.aluno
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
import org.springframework.web.bind.annotation.RestController;
import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/v1/aluno")
public class AlunoController {

    @Autowired
    private AlunoService alunoService;

    @Autowired
    private AlunoMapper alunoMapper;

    @GetMapping
    public ResponseEntity<List<AlunoResponseDTO>> listarTodosAlunos() {
        List<Aluno> listaEntity = alunoService.findAll();
        List<AlunoResponseDTO> listaDTO = alunoMapper.toResponseDTOList(listaEntity);
        return ResponseEntity.ok(listaDTO);
    }

    @GetMapping("/{id}")
    public ResponseEntity<AlunoResponseDTO> buscarAlunoPorId(@PathVariable Long id) {
        Aluno aluno = alunoService.findById(id);
        return ResponseEntity.ok(alunoMapper.toResponseDTO(aluno));
    }

    @PostMapping
    public ResponseEntity<AlunoResponseDTO> criarAluno(@Valid @RequestBody AlunoRequestDTO dto) {
        // Mapper converte o DTO para uma entidade "crua" (sem relacionamentos)
        Aluno novoAluno = alunoMapper.toEntity(dto);

        // Service recebe a entidade "crua" + os IDs para fazer a lógica de associação
        Aluno alunoSalvo = alunoService.create(novoAluno, dto.getEscolaId(), dto.getResponsavelId());

        // Mapeia a entidade salva (agora completa) para a resposta
        AlunoResponseDTO responseDTO = alunoMapper.toResponseDTO(alunoSalvo);
        return ResponseEntity.status(201).body(responseDTO);
    }

    @PutMapping("/{id}")
    public ResponseEntity<AlunoResponseDTO> atualizarAluno(@PathVariable Long id,
            @Valid @RequestBody AlunoRequestDTO dto) {
        Aluno dadosAtualizacao = alunoMapper.toEntity(dto);

        Aluno alunoAtualizado = alunoService.update(id, dadosAtualizacao, dto.getEscolaId(), dto.getResponsavelId());

        return ResponseEntity.ok(alunoMapper.toResponseDTO(alunoAtualizado));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deletarAluno(@PathVariable Long id) {
        alunoService.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}