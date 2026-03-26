package com.fateczl.sistemaDeGestaoEscolar.config;

import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Component;

import com.fateczl.sistemaDeGestaoEscolar.usuario.Usuario;
import com.fateczl.sistemaDeGestaoEscolar.usuario.UsuarioRepository;

import lombok.RequiredArgsConstructor;

@Component
@RequiredArgsConstructor
public class CurrentUser {

    private final UsuarioRepository usuarioRepository;

    public Usuario get() {
        String email = SecurityContextHolder.getContext()
                .getAuthentication().getName();
        return usuarioRepository.findByEmail(email)
                .orElseThrow(() -> new UsernameNotFoundException(
                        "Usuário autenticado não encontrado: " + email));
    }
}
