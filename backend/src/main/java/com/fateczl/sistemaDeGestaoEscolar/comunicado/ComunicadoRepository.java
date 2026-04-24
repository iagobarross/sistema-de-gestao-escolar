package com.fateczl.sistemaDeGestaoEscolar.comunicado;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ComunicadoRepository extends JpaRepository<Comunicado, Long> {

    List<Comunicado> findByResponsavelIdOrderByCriadoEmDesc(Long responsavelId);

    long countByResponsavelIdAndLidoFalse(Long responsavelId);
}