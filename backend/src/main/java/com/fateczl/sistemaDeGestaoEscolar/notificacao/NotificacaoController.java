package com.fateczl.sistemaDeGestaoEscolar.notificacao;

import com.fateczl.sistemaDeGestaoEscolar.config.CurrentUser;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/notificacao")
@RequiredArgsConstructor
public class NotificacaoController {

    private final NotificacaoService service;
    private final NotificacaoMapper mapper;
    private final CurrentUser currentUser;

    /**
     * Lista todas as notificações do coordenador logado.
     */
    @GetMapping
    @PreAuthorize("hasRole('COORDENADOR')")
    public ResponseEntity<List<NotificacaoResponseDTO>> listar() {
        Long coordenadorId = currentUser.get().getId();
        return ResponseEntity.ok(mapper.toDTOList(service.findByCoordenador(coordenadorId)));
    }

    /**
     * Retorna o número de notificações pendentes — usado para o badge na UI.
     */
    @GetMapping("/pendentes/count")
    @PreAuthorize("hasRole('COORDENADOR')")
    public ResponseEntity<Map<String, Long>> contarPendentes() {
        Long coordenadorId = currentUser.get().getId();
        long total = service.contarPendentes(coordenadorId);
        return ResponseEntity.ok(Map.of("total", total));
    }

    /**
     * Dispara a análise de IA para a escola do coordenador logado.
     * Pode demorar alguns segundos dependendo do número de alunos.
     */
    @PostMapping("/analisar")
    @PreAuthorize("hasRole('COORDENADOR')")
    public ResponseEntity<Map<String, Object>> analisar() {
        // Obtém a escola do coordenador pelo seu perfil
        Long escolaId = currentUser.getFuncionario().getEscola().getId();
        int geradas = service.analisarEGerarNotificacoes(escolaId);
        return ResponseEntity.ok(Map.of(
                "notificacoesGeradas", geradas,
                "mensagem", geradas > 0
                        ? geradas + " nova(s) notificação(ões) gerada(s) pela IA."
                        : "Todos os alunos estão dentro dos parâmetros esperados."
        ));
    }

    /**
     * Marca uma notificação como lida (coordenador abriu e leu).
     */
    @PatchMapping("/{id}/ler")
    @PreAuthorize("hasRole('COORDENADOR')")
    public ResponseEntity<NotificacaoResponseDTO> marcarLida(@PathVariable Long id) {
        return ResponseEntity.ok(mapper.toDTO(service.marcarComoLida(id)));
    }

    /**
     * Encaminha a notificação ao responsável do aluno — cria o Comunicado.
     */
    @PostMapping("/{id}/encaminhar")
    @PreAuthorize("hasRole('COORDENADOR')")
    public ResponseEntity<NotificacaoResponseDTO> encaminhar(@PathVariable Long id) {
        return ResponseEntity.ok(mapper.toDTO(service.encaminharAoResponsavel(id)));
    }
}