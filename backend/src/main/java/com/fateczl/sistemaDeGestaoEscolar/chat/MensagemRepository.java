package com.fateczl.sistemaDeGestaoEscolar.chat;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface MensagemRepository extends JpaRepository<Mensagem, Long> {

    // Busca todas as mensagens enviadas para o Mural Público (onde o destinatário é nulo)
    // ou entre dois usuários específicos (Privado)
    @Query("SELECT m FROM Mensagem m WHERE " +
            "(m.remetente.id = :usuarioId1 AND m.destinatario.id = :usuarioId2) OR " +
            "(m.remetente.id = :usuarioId2 AND m.destinatario.id = :usuarioId1) " +
            "ORDER BY m.dataEnvio ASC")
    List<Mensagem> findMensagensPrivadas(Long usuarioId1, Long usuarioId2);

    // Busca as mensagens públicas (Mural da Escola)
    @Query("SELECT m FROM Mensagem m WHERE m.destinatario IS NULL ORDER BY m.dataEnvio ASC")
    List<Mensagem> findMensagensPublicas();
}