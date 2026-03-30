package com.fateczl.sistemaDeGestaoEscolar.config;

import com.fateczl.sistemaDeGestaoEscolar.config.security.JwtService;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Configuration;
import org.springframework.messaging.Message;
import org.springframework.messaging.MessageChannel;
import org.springframework.messaging.simp.config.ChannelRegistration;
import org.springframework.messaging.simp.config.MessageBrokerRegistry;
import org.springframework.messaging.simp.stomp.StompCommand;
import org.springframework.messaging.simp.stomp.StompHeaderAccessor;
import org.springframework.messaging.support.ChannelInterceptor;
import org.springframework.messaging.support.MessageHeaderAccessor;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.web.socket.config.annotation.EnableWebSocketMessageBroker;
import org.springframework.web.socket.config.annotation.StompEndpointRegistry;
import org.springframework.web.socket.config.annotation.WebSocketMessageBrokerConfigurer;

@Configuration
@EnableWebSocketMessageBroker
@RequiredArgsConstructor // Importante: Permite injetar o JwtService e o UserDetailsService automaticamente
public class WebSocketConfig implements WebSocketMessageBrokerConfigurer {

    // Injetamos os serviços que você já usa no seu sistema de login
    private final JwtService jwtService;
    private final UserDetailsService userDetailsService;

    @Override
    public void registerStompEndpoints(StompEndpointRegistry registry) {
        registry.addEndpoint("/ws-chat")
                .setAllowedOriginPatterns("*")
                .withSockJS();
    }

    @Override
    public void configureMessageBroker(MessageBrokerRegistry registry) {
        registry.setApplicationDestinationPrefixes("/app");
        registry.enableSimpleBroker("/topic", "/queue");
    }

    // A MÁGICA ACONTECE AQUI: Este método intercepta as mensagens que chegam
    @Override
    public void configureClientInboundChannel(ChannelRegistration registration) {
        registration.interceptors(new ChannelInterceptor() {
            @Override
            public Message<?> preSend(Message<?> message, MessageChannel channel) {
                StompHeaderAccessor accessor = MessageHeaderAccessor.getAccessor(message, StompHeaderAccessor.class);

                // Verifica se a mensagem é um pedido de CONEXÃO inicial
                if (StompCommand.CONNECT.equals(accessor.getCommand())) {

                    // Extrai o cabeçalho "Authorization" (que o Flutter vai enviar)
                    String authHeader = accessor.getFirstNativeHeader("Authorization");

                    // Verifica se o token existe e começa com "Bearer "
                    if (authHeader != null && authHeader.startsWith("Bearer ")) {
                        String jwt = authHeader.substring(7); // Pega só o token
                        String userEmail = jwtService.extractUsername(jwt); // Descobre o email

                        if (userEmail != null) {
                            // Busca os detalhes do usuário no banco
                            UserDetails userDetails = userDetailsService.loadUserByUsername(userEmail);

                            // Se o token for válido...
                            if (jwtService.isTokenValid(jwt, userDetails)) {
                                // ... cria a autenticação
                                UsernamePasswordAuthenticationToken authentication = new UsernamePasswordAuthenticationToken(
                                        userDetails, null, userDetails.getAuthorities()
                                );

                                // E o mais importante: vincula o usuário à sessão do WebSocket!
                                // É isso que faz o "Principal" do ChatController não ser mais nulo.
                                accessor.setUser(authentication);
                            }
                        }
                    }
                }
                return message;
            }
        });
    }
}