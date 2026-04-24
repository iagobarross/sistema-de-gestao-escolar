package com.fateczl.sistemaDeGestaoEscolar.chat;

import com.fateczl.sistemaDeGestaoEscolar.usuario.Usuario;
import com.fateczl.sistemaDeGestaoEscolar.usuario.UsuarioRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.messaging.handler.annotation.SendTo;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;

import java.security.Principal;
import java.util.HashMap;
import java.util.Map;

@Controller
public class ChatController {

    @Autowired
    private MensagemRepository mensagemRepository;

    @Autowired
    private UsuarioRepository usuarioRepository;

    @Autowired
    private SimpMessagingTemplate messagingTemplate;

    // 1. MURAL PÚBLICO
    @MessageMapping("/chat.enviarPublico")
    @SendTo("/topic/publico")
    public Map<String, Object> enviarMensagemPublica(@Payload MensagemRequestDTO mensagemDTO, Principal principal) {
        Usuario remetente = usuarioRepository.findByEmail(principal.getName())
                .orElseThrow(() -> new RuntimeException("Usuário não encontrado!"));

        Mensagem mensagem = Mensagem.builder()
                .conteudo(mensagemDTO.getConteudo())
                .remetente(remetente)
                // Destinatário nulo = Mensagem pública
                .build();

        // 1. Guarda a mensagem no banco de dados
        Mensagem mensagemSalva = mensagemRepository.save(mensagem);

        // 2. Converte a mensagem para um Map seguro e devolve (para não dar erro de Lazy Loading)
        return converterParaMap(mensagemSalva);
    }

    // 2. MENSAGEM PRIVADA
    @MessageMapping("/chat.enviarPrivado")
    public void enviarMensagemPrivada(@Payload MensagemPrivadaDTO mensagemDTO, Principal principal) {
        // Quem está enviando?
        Usuario remetente = usuarioRepository.findByEmail(principal.getName())
                .orElseThrow(() -> new RuntimeException("Remetente não encontrado!"));

        // Para quem é?
        Usuario destinatario = usuarioRepository.findById(mensagemDTO.getDestinatarioId())
                .orElseThrow(() -> new RuntimeException("Destinatário não encontrado!"));

        Mensagem mensagem = Mensagem.builder()
                .conteudo(mensagemDTO.getConteudo())
                .remetente(remetente)
                .destinatario(destinatario)
                .build();

        Mensagem mensagemSalva = mensagemRepository.save(mensagem);

        // Converte a mensagem para um Map limpo e sem dependências do Hibernate
        Map<String, Object> dtoSeguro = converterParaMap(mensagemSalva);

        // Envia a mensagem para a fila PESSOAL do destinatário
        messagingTemplate.convertAndSendToUser(
                destinatario.getEmail(), // Usa o e-mail como identificador da sessão
                "/queue/privado",
                dtoSeguro
        );

        // Envia de volta para a fila do remetente (para aparecer na tela de quem enviou)
        messagingTemplate.convertAndSendToUser(
                remetente.getEmail(),
                "/queue/privado",
                dtoSeguro
        );
    }

    // =========================================================================
    // MÉTODO AUXILIAR: Transforma a Entidade num Map limpo para evitar erros de JSON
    // =========================================================================
    private Map<String, Object> converterParaMap(Mensagem m) {
        Map<String, Object> dto = new HashMap<>();
        dto.put("id", m.getId());
        dto.put("conteudo", m.getConteudo());

        // Mapeamos apenas o ID e o Nome do remetente para o Flutter ler
        Map<String, Object> remetenteMap = new HashMap<>();
        if (m.getRemetente() != null) {
            remetenteMap.put("id", m.getRemetente().getId());
            remetenteMap.put("nome", m.getRemetente().getNome());
        }
        dto.put("remetente", remetenteMap);

        // Formata a data de envio de forma segura
        dto.put("dataEnvio", m.getDataEnvio() != null ? m.getDataEnvio().toString() : "");

        return dto;
    }
}