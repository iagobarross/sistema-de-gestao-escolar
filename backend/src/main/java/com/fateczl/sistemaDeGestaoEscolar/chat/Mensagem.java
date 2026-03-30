package com.fateczl.sistemaDeGestaoEscolar.chat;

import com.fateczl.sistemaDeGestaoEscolar.usuario.Usuario;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Entity
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "mensagens")
public class Mensagem {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String conteudo;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "remetente_id", nullable = false)
    private Usuario remetente;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "destinatario_id")
    private Usuario destinatario;

    private LocalDateTime dataEnvio;

    @PrePersist
    public void prePersist() {
        this.dataEnvio = LocalDateTime.now();
    }
}