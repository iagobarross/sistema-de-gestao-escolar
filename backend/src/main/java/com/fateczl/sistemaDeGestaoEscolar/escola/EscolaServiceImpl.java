package com.fateczl.sistemaDeGestaoEscolar.escola;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;

import com.fateczl.sistemaDeGestaoEscolar.config.exception.BusinessException;
import com.fateczl.sistemaDeGestaoEscolar.config.exception.ResourceNotFoundException;

@Service
public class EscolaServiceImpl implements EscolaService{
@Autowired
	private EscolaRepository escolaRepository;
	
    @Override
	public List<Escola> findAll(){
		return escolaRepository.findAll(Sort.by("nome").ascending());
	}
	
    @Override
	public Escola findById(Long id) {
		return escolaRepository.findById(id)
				.orElseThrow(() -> new ResourceNotFoundException("Escola não encontrada com o ID: " + id));
	}
	
    @Override
	public List<Escola> findByName(String nome) {
		return escolaRepository.findByNomeStartsWith(nome);
	}
	
    @Override
	public Escola create(Escola escola) {
		if(escolaRepository.existsByCnpj(escola.getCnpj()))
			throw new BusinessException("CNPJ da escola já cadastrado.");

		if(escolaRepository.existsByCodigo(escola.getCodigo()))
			throw new BusinessException("Código da escola já cadastrado.");

		return escolaRepository.save(escola);
	}

	@Override
	public Escola update(Long id, Escola escolaAtualizada) {
		Escola escolaExistente = escolaRepository.findById(id)
				.orElseThrow(() -> new ResourceNotFoundException("Escola não encontrada com ID: " + id));

		if (escolaRepository.existsByCnpjAndIdNot(escolaAtualizada.getCnpj(), id)) {
			throw new BusinessException("Já existe outra escola com este CNPJ.");
		}

		if (escolaRepository.existsByCodigoAndIdNot(escolaAtualizada.getCodigo(), id)) {
			throw new BusinessException("Já existe outra escola com este Código.");
		}

		escolaExistente.setNome(escolaAtualizada.getNome());
		escolaExistente.setCnpj(escolaAtualizada.getCnpj());
		escolaExistente.setCodigo(escolaAtualizada.getCodigo());
		escolaExistente.setEndereco(escolaAtualizada.getEndereco()); // Se houver endereço

		return escolaRepository.save(escolaExistente);
	}

    @Override
	public void deleteById(Long id) {
		try{
			escolaRepository.deleteById(id);
		} catch (DataIntegrityViolationException e) {
			throw new BusinessException("Não é possível deletar a escola. Verifique se ela possui turmas ou alunos associados.");
		}
	}
	
}