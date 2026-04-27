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

    @MessageMapping("/chat.enviarPublico")
    @SendTo("/topic/publico")
    public Map<String, Object> enviarMensagemPublica(@Payload MensagemRequestDTO mensagemDTO, Principal principal) {
        Usuario remetente = usuarioRepository.findByEmail(principal.getName())
                .orElseThrow(() -> new RuntimeException("Usuário não encontrado!"));

        Mensagem mensagem = Mensagem.builder()
                .conteudo(mensagemDTO.getConteudo())
                .remetente(remetente)
                .build();

        Mensagem mensagemSalva = mensagemRepository.save(mensagem);
        return converterParaMap(mensagemSalva);
    }

    @MessageMapping("/chat.enviarPrivado")
    public void enviarMensagemPrivada(@Payload MensagemPrivadaDTO mensagemDTO, Principal principal) {
        Usuario remetente = usuarioRepository.findByEmail(principal.getName())
                .orElseThrow(() -> new RuntimeException("Remetente não encontrado!"));

        Usuario destinatario = usuarioRepository.findById(mensagemDTO.getDestinatarioId())
                .orElseThrow(() -> new RuntimeException("Destinatário não encontrado!"));

        Mensagem mensagem = Mensagem.builder()
                .conteudo(mensagemDTO.getConteudo())
                .remetente(remetente)
                .destinatario(destinatario)
                .build();

        Mensagem mensagemSalva = mensagemRepository.save(mensagem);
        Map<String, Object> dtoSeguro = converterParaMap(mensagemSalva);

        messagingTemplate.convertAndSendToUser(
                destinatario.getEmail(),
                "/queue/privado",
                dtoSeguro
        );

        messagingTemplate.convertAndSendToUser(
                remetente.getEmail(),
                "/queue/privado",
                dtoSeguro
        );
    }

    private Map<String, Object> converterParaMap(Mensagem m) {
        Map<String, Object> dto = new HashMap<>();
        dto.put("id", m.getId());
        dto.put("conteudo", m.getConteudo());

        Map<String, Object> remetenteMap = new HashMap<>();
        if (m.getRemetente() != null) {
            remetenteMap.put("id", m.getRemetente().getId());
            remetenteMap.put("nome", m.getRemetente().getNome());
        }
        dto.put("remetente", remetenteMap);
        dto.put("dataEnvio", m.getDataEnvio() != null ? m.getDataEnvio().toString() : "");

        return dto;
    }
}