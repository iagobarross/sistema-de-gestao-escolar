package com.fateczl.sistemaDeGestaoEscolar.comunicado;

import java.util.List;

public interface ComunicadoService {
    List<Comunicado> findByResponsavel(Long responsavelId);
    Comunicado marcarComoLido(Long comunicadoId);
    long contarNaoLidos(Long responsavelId);
}