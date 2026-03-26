package com.fateczl.sistemaDeGestaoEscolar.academico.aula;

import java.time.LocalDate;
import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.fateczl.sistemaDeGestaoEscolar.academico.matriz.MatrizCurricularRepository;
import com.fateczl.sistemaDeGestaoEscolar.config.exception.BusinessException;
import com.fateczl.sistemaDeGestaoEscolar.config.exception.ResourceNotFoundException;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class AulaServiceImpl implements AulaService {

    private final AulaRepository aulaRepository;
    private final MatrizCurricularRepository matrizRepository;

    @Override
    public Aula findById(Long id) {
        return aulaRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Aula não encontrada com o ID: " + id));
    }

    @Override
    public List<Aula> findByMatriz(Long matrizId) {
        return aulaRepository
                .findByMatrizCurricularIdOrderByDataAscNumeroAulaAsc(matrizId);
    }

    @Override
    public List<Aula> findAulasHojeDoProfessor(Long professorId) {
        return aulaRepository.findAulasHoje(professorId, LocalDate.now());
    }

    @Override
    @Transactional
    public Aula registrar(AulaRequestDTO dto) {
        var matriz = matrizRepository.findById(dto.getMatrizCurricularId())
            .orElseThrow(() -> new ResourceNotFoundException("Matriz curricular não encontrada"));

        
        if(aulaRepository.findByMatrizCurricularIdAndData(dto.getMatrizCurricularId(), dto.getData()).isPresent())
            throw new BusinessException("Já existe uma aula registrada nessa data para essa turma/disciplina.");

        int proximoNumero = aulaRepository
                .findUltimoNumeroAula(dto.getMatrizCurricularId()) + 1;

        Aula aula = new Aula();
        aula.setMatrizCurricular(matriz);
        aula.setData(dto.getData());
        aula.setConteudo(dto.getConteudo());
        aula.setNumeroAula(proximoNumero);

        return aulaRepository.save(aula);
    }

    @Override
    @Transactional
    public Aula atualizar(Long id, AulaRequestDTO dto) {
        Aula aula = findById(id);
        aula.setConteudo(dto.getConteudo());
        return aulaRepository.save(aula);
    }

    @Override
    public void deletar(Long id) {
        if (!aulaRepository.existsById(id))
            throw new ResourceNotFoundException("Aula não encontrada");
        aulaRepository.deleteById(id);
    }

}
