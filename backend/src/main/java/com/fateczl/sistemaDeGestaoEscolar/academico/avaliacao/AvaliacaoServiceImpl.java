package com.fateczl.sistemaDeGestaoEscolar.academico.avaliacao;

import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.fateczl.sistemaDeGestaoEscolar.academico.matriz.MatrizCurricularRepository;
import com.fateczl.sistemaDeGestaoEscolar.config.exception.ResourceNotFoundException;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class AvaliacaoServiceImpl implements AvaliacaoService {
    
    private final AvaliacaoRepository avaliacaoRepository;
    private final MatrizCurricularRepository matrizRepository;
    
    @Override
    public Avaliacao findById(Long id) {
        return avaliacaoRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Avaliação não encontrada com o ID: " + id));
    }

    @Override
    public List<Avaliacao> findByMatriz(Long matrizId) {
        return avaliacaoRepository
                .findByMatrizCurricularIdOrderByDataAplicacaoAsc(matrizId);
    }

    @Override
    public List<Avaliacao> findByMatrizAndBimestre(Long matrizId, int bimestre) {
        return avaliacaoRepository
                .findByMatrizCurricularIdAndBimestreOrderByDataAplicacaoAsc(matrizId, bimestre);
    }

    @Override
    public List<Avaliacao> findProximasDosProfessor(Long professorId) {
        return avaliacaoRepository
                .findByMatrizCurricularProfessorIdAndDataAplicacaoAfterOrderByDataAplicacaoAsc(professorId, java.time.LocalDate.now().minusDays(1));
    }

    @Override
    @Transactional
    public Avaliacao create(AvaliacaoRequestDTO dto) {
        var matriz = matrizRepository.findById(dto.getMatrizCurricularId())
                .orElseThrow(() -> new ResourceNotFoundException("Matriz curricular não encontrada"));
        
        Avaliacao av = new Avaliacao();
        av.setMatrizCurricular(matriz);
        av.setTitulo(dto.getTitulo());
        av.setTipo(dto.getTipo());
        av.setDataAplicacao(dto.getDataAplicacao());
        av.setNotaMaxima(dto.getNotaMaxima());
        av.setBimestre(dto.getBimestre());
        av.setPeso(dto.getPeso());
        return avaliacaoRepository.save(av);
    }

    @Override
    @Transactional
    public Avaliacao update(Long id, AvaliacaoRequestDTO dto) {
        Avaliacao av = findById(id);
        av.setTitulo(dto.getTitulo());
        av.setTipo(dto.getTipo());
        av.setDataAplicacao(dto.getDataAplicacao());
        av.setNotaMaxima(dto.getNotaMaxima());
        av.setBimestre(dto.getBimestre());
        av.setPeso(dto.getPeso());
        return avaliacaoRepository.save(av);
    }

    @Override
    public void deleteById(Long id) {
        if(!avaliacaoRepository.existsById(id))
            throw new ResourceNotFoundException("Avaliação não encontrada");
        avaliacaoRepository.deleteById(id);
    }
    
}
