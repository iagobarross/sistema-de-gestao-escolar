// Pacote: com.fateczl.sistemaDeGestaoEscolar.turma
package com.fateczl.sistemaDeGestaoEscolar.turma;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.fateczl.sistemaDeGestaoEscolar.usuario.aluno.AlunoResponseDTO;

import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/v1/turma")
public class TurmaController {

    @Autowired
    private TurmaService turmaService;

    @Autowired
    private TurmaMapper turmaMapper;

    // --- CRUD Básico ---

    @GetMapping
    @PreAuthorize("isAuthenticated()") // Exemplo de segurança: apenas usuários autenticados podem acessar
    public ResponseEntity<List<TurmaResponseDTO>> listarTodasTurmas() {
        List<Turma> listaEntity = turmaService.findAll();
        List<TurmaResponseDTO> listaDTO = turmaMapper.toResponseDTOList(listaEntity);
        return ResponseEntity.ok(listaDTO);
    }

    @GetMapping("/{id}")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<TurmaResponseDTO> buscarTurmaPorId(@PathVariable Long id) {
        Turma turma = turmaService.findById(id);
        return ResponseEntity.ok(turmaMapper.toResponseDTO(turma));
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('ADMIN','DIRETOR','SECRETARIA')")
    public ResponseEntity<TurmaResponseDTO> criarTurma(@Valid @RequestBody TurmaRequestDTO dto) {
        Turma novaTurma = turmaMapper.toEntity(dto);
        Turma turmaSalva = turmaService.create(novaTurma);
        TurmaResponseDTO responseDTO = turmaMapper.toResponseDTO(turmaSalva);
        return ResponseEntity.status(201).body(responseDTO);
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN','DIRETOR')")
    public ResponseEntity<TurmaResponseDTO> atualizarTurma(@PathVariable Long id,
            @Valid @RequestBody TurmaRequestDTO dto) {
        Turma dadosAtualizacao = turmaMapper.toEntity(dto);
        Turma turma = turmaService.update(id, dadosAtualizacao);
        return ResponseEntity.ok(turmaMapper.toResponseDTO(turma));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN','DIRETOR')")
    public ResponseEntity<Void> deletarTurma(@PathVariable Long id) {
        turmaService.deleteById(id);
        return ResponseEntity.noContent().build();
    }

    // --- Endpoints de Associação (Aluno <-> Turma) ---

    @GetMapping("/{turmaId}/alunos")
    @PreAuthorize("hasAnyRole('ADMIN','DIRETOR','SECRETARIA','COORDENADOR', 'PROFESSOR')")
    public ResponseEntity<List<AlunoResponseDTO>> getAlunosDaTurma(@PathVariable Long turmaId) {
        // AGORA: Apenas chama o serviço, que faz todo o trabalho transacional
        List<AlunoResponseDTO> alunosDTO = turmaService.findAlunosByTurmaId(turmaId);
        return ResponseEntity.ok(alunosDTO);
    }

    @PostMapping("/{turmaId}/alunos/{alunoId}")
    @PreAuthorize("hasAnyRole('ADMIN','DIRETOR','SECRETARIA')")
    public ResponseEntity<Void> adicionarAlunoNaTurma(@PathVariable Long turmaId, @PathVariable Long alunoId) {
        turmaService.adicionarAluno(turmaId, alunoId);
        return ResponseEntity.ok().build();
    }

    @DeleteMapping("/{turmaId}/alunos/{alunoId}")
    @PreAuthorize("hasAnyRole('ADMIN','DIRETOR','SECRETARIA')")
    public ResponseEntity<Void> removerAlunoDaTurma(@PathVariable Long turmaId, @PathVariable Long alunoId) {
        turmaService.removerAluno(turmaId, alunoId);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{turmaId}/matricular/{alunoId}")
    @PreAuthorize("hasAnyRole('ADMIN','DIRETOR','SECRETARIA')")
    public ResponseEntity<?> matricular(@PathVariable Long turmaId,@PathVariable Long alunoId) {
        String resultado = turmaService.matricularAlunoViaProcedure(alunoId, turmaId);

        if (resultado.startsWith("ERRO")) {
            return ResponseEntity.badRequest().body(resultado);
        }
        return ResponseEntity.ok(resultado);
    }

}