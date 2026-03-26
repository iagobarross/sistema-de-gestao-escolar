package com.fateczl.sistemaDeGestaoEscolar.academico.matriz;

import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.fateczl.sistemaDeGestaoEscolar.academico.StatusMatriz;
import com.fateczl.sistemaDeGestaoEscolar.config.exception.BusinessException;
import com.fateczl.sistemaDeGestaoEscolar.config.exception.ResourceNotFoundException;
import com.fateczl.sistemaDeGestaoEscolar.disciplina.DisciplinaRepository;
import com.fateczl.sistemaDeGestaoEscolar.turma.TurmaRepository;
import com.fateczl.sistemaDeGestaoEscolar.usuario.funcionario.FuncionarioRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class MatrizCurricularServiceImpl implements MatrizCurricularService {
    
    private final MatrizCurricularRepository matrizRepository;
    private final TurmaRepository turmaRepository;
    private final DisciplinaRepository disciplinaRepository;
    private final FuncionarioRepository funcionarioRepository;

    @Override
    public MatrizCurricular findById(Long id) {
        return matrizRepository
                .findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Matriz curricular não encontrada com ID: " + id));
    }

    @Override
    public List<MatrizCurricular> findByTurmaAndAno(Long turmaId, int ano) {
        return matrizRepository
                .findByTurmaIdAndAnoOrderByDisciplinaNomeAsc(turmaId, ano);
    }

    @Override
    public List<MatrizCurricular> findByProfessorAndAno(Long professorId, int ano) {
        return matrizRepository
                .findAtivasByProfessorAndAno(professorId, ano);
    }

    @Override
    @Transactional
    public MatrizCurricular create(MatrizCurricularRequestDTO dto) {
        if(matrizRepository.existsByTurmaIdAndDisciplinaIdAndAno(
            dto.getTurmaId(),dto.getDisciplinaId(), dto.getAno()))
            throw new BusinessException("Essa disciplina já está vinculada a essa turma nesse ano.");

        MatrizCurricular m = new MatrizCurricular();
        m.setTurma(turmaRepository.findById(dto.getTurmaId())
            .orElseThrow(() -> new ResourceNotFoundException("Turma não encontrada")));
        m.setDisciplina(disciplinaRepository.findById(dto.getDisciplinaId())
            .orElseThrow(() -> new ResourceNotFoundException("Disciplina não encontrada")));
        m.setProfessor(funcionarioRepository.findById(dto.getProfessorId())
        .orElseThrow(() -> new ResourceNotFoundException("Professor não encontrado")));
        m.setAno(dto.getAno());
        m.setCargaHorariaTotal(dto.getCargaHorariaTotal());
        m.setStatus(StatusMatriz.ATIVA);

        return matrizRepository.save(m);
    }   

    @Override
    @Transactional
    public MatrizCurricular update(Long id, MatrizCurricularRequestDTO dto) {
        MatrizCurricular m = findById(id);
        m.setProfessor(funcionarioRepository.findById(dto.getProfessorId())
            .orElseThrow(() -> new ResourceNotFoundException("Professor não encontrado.")));
        m.setCargaHorariaTotal(dto.getCargaHorariaTotal());
        return matrizRepository.save(m);    
    }

    @Override
    public void encerrar(Long id) {
        MatrizCurricular m = findById(id);
        m.setStatus(StatusMatriz.ENCERRADA);
        matrizRepository.save(m);
        
    }

    @Override
    public void deleteById(Long id) {
        if(!matrizRepository.existsById(id))
            throw new ResourceNotFoundException("Matriz não encontrada com o ID: " + id);
        matrizRepository.deleteById(id);
    }
    
}
