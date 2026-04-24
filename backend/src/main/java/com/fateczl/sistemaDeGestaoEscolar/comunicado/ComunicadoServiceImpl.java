package com.fateczl.sistemaDeGestaoEscolar.comunicado;

import com.fateczl.sistemaDeGestaoEscolar.config.exception.ResourceNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class ComunicadoServiceImpl implements ComunicadoService {

    private final ComunicadoRepository comunicadoRepository;

    @Override
    public List<Comunicado> findByResponsavel(Long responsavelId) {
        return comunicadoRepository.findByResponsavelIdOrderByCriadoEmDesc(responsavelId);
    }

    @Override
    @Transactional
    public Comunicado marcarComoLido(Long comunicadoId) {
        Comunicado c = comunicadoRepository.findById(comunicadoId)
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Comunicado não encontrado com o ID: " + comunicadoId));
        if (!c.isLido()) {
            c.setLido(true);
            c.setLidoEm(LocalDateTime.now());
            comunicadoRepository.save(c);
        }
        return c;
    }

    @Override
    public long contarNaoLidos(Long responsavelId) {
        return comunicadoRepository.countByResponsavelIdAndLidoFalse(responsavelId);
    }
}