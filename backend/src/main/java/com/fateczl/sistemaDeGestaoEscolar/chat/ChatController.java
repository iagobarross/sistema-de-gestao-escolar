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

@Controller
public class ChatController {

    @Autowired
    private MensagemRepository mensagemRepository;

    @Autowired
    private UsuarioRepository usuarioRepository;

    @Autowired
    private SimpMessagingTemplate messagingTemplate;

    // 1. MURAL PÚBLICO (Já tínhamos feito)
    @MessageMapping("/chat.enviarPublico")
    @SendTo("/topic/publico")
    public Mensagem enviarMensagemPublica(@Payload MensagemRequestDTO mensagemDTO, Principal principal) {
        Usuario remetente = usuarioRepository.findByEmail(principal.getName())
                .orElseThrow(() -> new RuntimeException("Usuário não encontrado!"));

        Mensagem mensagem = Mensagem.builder()
                .conteudo(mensagemDTO.getConteudo())
                .remetente(remetente)
                // Destinatário nulo = Mensagem pública
                .build();

        return mensagemRepository.save(mensagem);
    }

    // 2. MENSAGEM PRIVADA (NOVO)
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

        // Envia a mensagem para a fila PESSOAL do destinatário
        // O Flutter do destinatário deve escutar em: /user/queue/privado
        messagingTemplate.convertAndSendToUser(
                destinatario.getEmail(), // Usa o e-mail como identificador da sessão
                "/queue/privado",
                mensagemSalva
        );

        // Opcional: Enviar de volta para o remetente também ver a mensagem no ecrã dele
        messagingTemplate.convertAndSendToUser(
                remetente.getEmail(),
                "/queue/privado",
                mensagemSalva
        );
    }
}