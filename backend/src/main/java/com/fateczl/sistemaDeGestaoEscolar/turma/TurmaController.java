// Pacote: com.fateczl.sistemaDeGestaoEscolar.turma
package com.fateczl.sistemaDeGestaoEscolar.turma;

import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.fateczl.sistemaDeGestaoEscolar.usuario.aluno.AlunoResponseDTO;

import java.util.List;

@RestController
@RequestMapping("/api/v1/turma")
public class TurmaController {

    @Autowired
    private TurmaService turmaService;

    @Autowired
    private TurmaMapper turmaMapper;

    // --- CRUD Básico ---

    @GetMapping
    public ResponseEntity<List<TurmaResponseDTO>> listarTodasTurmas() {
        List<Turma> listaEntity = turmaService.findAll();
        List<TurmaResponseDTO> listaDTO = turmaMapper.toResponseDTOList(listaEntity);
        return ResponseEntity.ok(listaDTO);
    }

    @GetMapping("/{id}")
    public ResponseEntity<TurmaResponseDTO> buscarTurmaPorId(@PathVariable Long id) {
        Turma turma = turmaService.findById(id);
        return ResponseEntity.ok(turmaMapper.toResponseDTO(turma));
    }

    @PostMapping
    public ResponseEntity<TurmaResponseDTO> criarTurma(@Valid @RequestBody TurmaRequestDTO dto) {
        Turma novaTurma = turmaMapper.toEntity(dto);
        Turma turmaSalva = turmaService.create(novaTurma);
        TurmaResponseDTO responseDTO = turmaMapper.toResponseDTO(turmaSalva);
        return ResponseEntity.status(201).body(responseDTO);
    }

    @PutMapping("/{id}")
    public ResponseEntity<TurmaResponseDTO> atualizarTurma(@PathVariable Long id,
            @Valid @RequestBody TurmaRequestDTO dto) {
        Turma dadosAtualizacao = turmaMapper.toEntity(dto);
        Turma turma = turmaService.update(id, dadosAtualizacao);
        return ResponseEntity.ok(turmaMapper.toResponseDTO(turma));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deletarTurma(@PathVariable Long id) {
        turmaService.deleteById(id);
        return ResponseEntity.noContent().build();
    }

    // --- Endpoints de Associação (Aluno <-> Turma) ---
    
    @GetMapping("/{turmaId}/alunos")
    public ResponseEntity<List<AlunoResponseDTO>> getAlunosDaTurma(@PathVariable Long turmaId) {
        // AGORA: Apenas chama o serviço, que faz todo o trabalho transacional
        List<AlunoResponseDTO> alunosDTO = turmaService.findAlunosByTurmaId(turmaId);
        return ResponseEntity.ok(alunosDTO);
    }

    @PostMapping("/{turmaId}/alunos/{alunoId}")
    public ResponseEntity<Void> adicionarAlunoNaTurma(@PathVariable Long turmaId, @PathVariable Long alunoId) {
        turmaService.adicionarAluno(turmaId, alunoId);
        return ResponseEntity.ok().build();
    }

    @DeleteMapping("/{turmaId}/alunos/{alunoId}")
    public ResponseEntity<Void> removerAlunoDaTurma(@PathVariable Long turmaId, @PathVariable Long alunoId) {
        turmaService.removerAluno(turmaId, alunoId);
        return ResponseEntity.noContent().build();
    }
}