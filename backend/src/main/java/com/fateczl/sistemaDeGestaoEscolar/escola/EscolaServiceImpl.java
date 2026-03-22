package com.fateczl.sistemaDeGestaoEscolar.escola;

import java.util.List;

import com.fateczl.sistemaDeGestaoEscolar.usuario.Role;
import com.fateczl.sistemaDeGestaoEscolar.usuario.funcionario.Funcionario;
import com.fateczl.sistemaDeGestaoEscolar.usuario.funcionario.FuncionarioRepository;
import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.data.domain.Sort;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import com.fateczl.sistemaDeGestaoEscolar.config.exception.BusinessException;
import com.fateczl.sistemaDeGestaoEscolar.config.exception.ResourceNotFoundException;

@Service
public class EscolaServiceImpl implements EscolaService{

	@Autowired
	private EscolaRepository escolaRepository;

	@Autowired
	private EscolaMapper escolaMapper; // NOVO: Certifique-se que o Mapper da escola está injetado aqui

	// ---> NOVAS INJEÇÕES NECESSÁRIAS PARA CRIAR O DIRETOR <---
	@Autowired
	private FuncionarioRepository funcionarioRepository;

	@Autowired
	private PasswordEncoder passwordEncoder;
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

	@Override
	@Transactional
	public EscolaResponseDTO createEscolaComDiretor(EscolaComDiretorRequestDTO dto) {
		// 1. Validar e salvar Escola
		if(escolaRepository.existsByCnpj(dto.getEscola().getCnpj()))
			throw new BusinessException("CNPJ da escola já cadastrado.");
		if(escolaRepository.existsByCodigo(dto.getEscola().getCodigo()))
			throw new BusinessException("Código da escola já cadastrado.");

		Escola escola = escolaMapper.toEntity(dto.getEscola());
		Escola escolaSalva = escolaRepository.save(escola);

		// 2. Validar e salvar Diretor
		if(funcionarioRepository.existsByEmail(dto.getDiretor().getEmail()))
			throw new BusinessException("Email do diretor já cadastrado.");

		Funcionario diretor = new Funcionario();
		diretor.setNome(dto.getDiretor().getNome());
		diretor.setEmail(dto.getDiretor().getEmail());
		diretor.setSenha(passwordEncoder.encode(dto.getDiretor().getSenha()));
		diretor.setRole(Role.DIRETOR);
		diretor.setCargo(Funcionario.Cargo.DIRETOR);
		diretor.setEscola(escolaSalva); // Vincula à escola recém-criada

		funcionarioRepository.save(diretor);

		return escolaMapper.toResponseDTO(escolaSalva);
	}
}

