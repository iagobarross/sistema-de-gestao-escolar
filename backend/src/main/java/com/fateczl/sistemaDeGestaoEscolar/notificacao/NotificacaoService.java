package com.fateczl.sistemaDeGestaoEscolar.notificacao;

import java.util.List;

public interface NotificacaoService {
    
    int analisarEGerarNotificacoes(Long escolaId);

    List<Notificacao> findByCoordenador(Long coordenadorId);

    long contarPendentes(Long coordenadorId);

    Notificacao marcarComoLida(Long notificacaoId);

    Notificacao encaminharAoResponsavel(Long notificacaoId);
    
}
