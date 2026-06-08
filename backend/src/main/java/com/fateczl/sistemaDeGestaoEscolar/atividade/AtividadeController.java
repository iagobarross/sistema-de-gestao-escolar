package com.fateczl.sistemaDeGestaoEscolar.atividade;

import java.util.List;
import java.util.stream.Collectors;

import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.fateczl.sistemaDeGestaoEscolar.config.CurrentUser;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/v1/atividade")
@RequiredArgsConstructor
public class AtividadeController {

    private final AtividadeService service;
    private final CurrentUser currentUser;

    @PostMapping
    @PreAuthorize("hasRole('PROFESSOR')")
    public ResponseEntity<AtividadeResponseDTO> criar(@Valid @RequestBody AtividadeRequestDTO dto) {
        return ResponseEntity.status(201).body(toDTO(service.criar(dto)));
    }

    @GetMapping("/professor/minhas")
    @PreAuthorize("hasRole('PROFESSOR')")
    public ResponseEntity<List<AtividadeResponseDTO>> minhasAtividades() {
        Long id = currentUser.get().getId();
        return ResponseEntity.ok(service.findByProfessor(id).stream()
            .map(this::toDTO).collect(Collectors.toList()));
    }

    @GetMapping("/{atividadeId}/entregas")
    @PreAuthorize("hasAnyRole('PROFESSOR','COORDENADOR','DIRETOR','ADMIN')")
    public ResponseEntity<List<AtividadeEntregaResponseDTO>> entregas(@PathVariable Long atividadeId) {
        return ResponseEntity.ok(service.findEntregasByAtividade(atividadeId).stream()
            .map(this::toEntregaDTO).collect(Collectors.toList()));
    }

    @GetMapping("/{atividadeId}/status-alunos")
    @PreAuthorize("hasAnyRole('PROFESSOR', 'COORDENADOR', 'DIRETOR', 'ADMIN')")
    public ResponseEntity<List<AtividadeAlunoStatusDTO>> statusAlunos(@PathVariable Long atividadeId) {
        return ResponseEntity.ok(service.getStatusAlunos(atividadeId));
    }

    @GetMapping("/entrega/{entregaId}/arquivo")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<AtividadeArquivoDTO> baixarArquivo(@PathVariable Long entregaId){
        AtividadeEntrega entrega = service.findEntregaById(entregaId);
        if (entrega.getArquivoBase64() == null || entrega.getArquivoBase64().isBlank()){
            return ResponseEntity.notFound().build();
        }
        AtividadeArquivoDTO dto = new AtividadeArquivoDTO();
        dto.setArquivoBase64(entrega.getArquivoBase64());
        dto.setArquivoNome(entrega.getArquivoNome());
        dto.setArquivoTipo(entrega.getArquivoTipo());
        return ResponseEntity.ok(dto);
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasAnyRole('PROFESSOR','COORDENADOR','ADMIN')")
    public ResponseEntity<Void> deletar(@PathVariable Long id) {
        service.deletar(id);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/turma/{turmaId}")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<List<AtividadeResponseDTO>> porTurma(@PathVariable Long turmaId) {
        return ResponseEntity.ok(service.findByTurma(turmaId).stream()
            .map(this::toDTO).collect(Collectors.toList()));
    }

    @PostMapping("/entregar")
    @PreAuthorize("hasRole('ALUNO')")
    public ResponseEntity<AtividadeEntregaResponseDTO> entregar(
            @Valid @RequestBody AtividadeEntregaRequestDTO dto) {
        Long alunoId = currentUser.get().getId();
        return ResponseEntity.status(201).body(toEntregaDTO(service.entregar(alunoId, dto)));
    }

    @GetMapping("/minhas-entregas")
    @PreAuthorize("hasRole('ALUNO')")
    public ResponseEntity<List<AtividadeEntregaResponseDTO>> minhasEntregas() {
        Long alunoId = currentUser.get().getId();
        return ResponseEntity.ok(service.findEntregasByAluno(alunoId).stream()
            .map(this::toEntregaDTO).collect(Collectors.toList()));
    }

    private AtividadeResponseDTO toDTO(Atividade a) {
        AtividadeResponseDTO dto = new AtividadeResponseDTO();
        dto.setId(a.getId());
        dto.setMatrizCurricularId(a.getMatrizCurricular().getId());
        dto.setNomeDisciplina(a.getMatrizCurricular().getDisciplina().getNome());
        dto.setNomeTurma(a.getMatrizCurricular().getTurma().getSerie()
            + " — " + a.getMatrizCurricular().getTurma().getTurno());
        dto.setNomeProfessor(a.getMatrizCurricular().getProfessor().getNome());
        dto.setTitulo(a.getTitulo());
        dto.setDescricao(a.getDescricao());
        dto.setDataEntrega(a.getDataEntrega());
        dto.setCriadaEm(a.getCriadaEm());
        dto.setTotalAlunos(a.getMatrizCurricular().getTurma().getAlunos().size());
        return dto;
    }

    private AtividadeEntregaResponseDTO toEntregaDTO(AtividadeEntrega e) {
        AtividadeEntregaResponseDTO dto = new AtividadeEntregaResponseDTO();
        dto.setId(e.getId());
        dto.setAtividadeId(e.getAtividade().getId());
        dto.setTituloAtividade(e.getAtividade().getTitulo());
        dto.setAlunoId(e.getAluno().getId());
        dto.setNomeAluno(e.getAluno().getNome());
        dto.setMatriculaAluno(e.getAluno().getMatricula());
        dto.setConteudo(e.getConteudo());
        dto.setEntregueEm(e.getEntregueEm());
        dto.setStatus(e.getStatus());
        return dto;
    }

}
