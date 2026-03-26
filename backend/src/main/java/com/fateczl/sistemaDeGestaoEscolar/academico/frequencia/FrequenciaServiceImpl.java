package com.fateczl.sistemaDeGestaoEscolar.academico.frequencia;

import java.util.List;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.fateczl.sistemaDeGestaoEscolar.academico.aula.AulaRepository;
import com.fateczl.sistemaDeGestaoEscolar.config.exception.BusinessException;
import com.fateczl.sistemaDeGestaoEscolar.config.exception.ResourceNotFoundException;
import com.fateczl.sistemaDeGestaoEscolar.usuario.aluno.AlunoRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class FrequenciaServiceImpl implements FrequenciaService {
    
    private final FrequenciaRepository frequenciaRepository;
    private final AulaRepository aulaRepository;
    private final AlunoRepository alunoRepository;

    public List<Frequencia> lancarChamada(LancarChamadaRequestDTO dto) {
        var aula = aulaRepository.findById(dto.getAulaId())
            .orElseThrow(() -> new ResourceNotFoundException("Aula não encontrada com o ID: " + dto.getAulaId()));

        if(!frequenciaRepository.findByAulaId(dto.getAulaId()).isEmpty())
            throw new BusinessException("Chamada já lançada para esta aula. Use a correção individual para ajustes");

        List<Frequencia> registros = dto.getPresencas().stream().map(item -> {
            var aluno = alunoRepository.findById(item.getAlunoId())
                    .orElseThrow(() -> new ResourceNotFoundException("Aluno não encontrado: " + item.getAlunoId()));
            Frequencia f = new Frequencia();
            f.setAula(aula);
            f.setAluno(aluno);
            f.setPresente(item.isPresente());
            if(!item.isPresente() && item.getJustificativa() != null)
                f.setJustificativa(item.getJustificativa());
            return f;          
        }).collect(Collectors.toList());

        return frequenciaRepository.saveAll(registros);
    }

    @Override
    @Transactional
    public Frequencia corrigirPresenca(Long frequenciaId, boolean presente, String justificativa) {
        Frequencia f = frequenciaRepository.findById(frequenciaId)
                .orElseThrow(() -> new ResourceNotFoundException("Frequência não encontrada com o ID: " + frequenciaId));
        f.setPresente(presente);
        f.setJustificativa(presente ? null : justificativa);
        return frequenciaRepository.save(f);
    }

    @Override
    public List<Frequencia> findByAula(Long aulaId) {
        return frequenciaRepository.findByAulaId(aulaId);
    }

    @Override
    public Double calcularPercentualPresenca(Long matrizId, Long alunoId) {
        Double pct = frequenciaRepository.calcularPercentualPresenca(matrizId, alunoId);
        return pct != null ? pct : 0.0;
    }  
}
