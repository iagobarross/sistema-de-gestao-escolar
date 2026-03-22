package com.fateczl.sistemaDeGestaoEscolar.usuario.funcionario;

import com.fateczl.sistemaDeGestaoEscolar.config.exception.BusinessException;
import com.fateczl.sistemaDeGestaoEscolar.config.exception.ResourceNotFoundException;
import com.fateczl.sistemaDeGestaoEscolar.escola.Escola;
import com.fateczl.sistemaDeGestaoEscolar.escola.EscolaRepository;
import com.fateczl.sistemaDeGestaoEscolar.usuario.Role;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class FuncionarioServiceImpl implements FuncionarioService {

    @Autowired
    private FuncionarioRepository funcionarioRepository;

    @Autowired
    private EscolaRepository escolaRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Override
    public List<Funcionario> findAll() {
        return funcionarioRepository.findAll();
    }

    @Override
    public Funcionario findById(Long id) {
        return funcionarioRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Funcionário não encontrado com o ID: " + id));
    }

    @Override
    public Funcionario create(Funcionario funcionario, Long escolaId) {
        // 1. Validação de Regra de Negócio
        if (funcionarioRepository.existsByEmail(funcionario.getEmail())) {
            throw new BusinessException("Email já está em uso.");
        }
        if (funcionario.getSenha() == null || funcionario.getSenha().length() < 6) {
            throw new BusinessException("A senha é obrigatória e deve ter no mínimo 6 caracteres.");
        }

        // 2. Mapear a Role do Spring Security baseada no Cargo escolhido
        funcionario.setRole(Role.valueOf(funcionario.getCargo().name()));

        // 3. Vincular Escola (Se não for ADMIN)
        if (funcionario.getCargo() != Funcionario.Cargo.ADMIN && escolaId != null) {
            Escola escola = escolaRepository.findById(escolaId)
                    .orElseThrow(() -> new ResourceNotFoundException("Escola não encontrada."));
            funcionario.setEscola(escola);
        } else {
            funcionario.setEscola(null); // Garante que ADMIN não tem escola vinculada
        }

        // 4. Criptografar Senha
        funcionario.setSenha(passwordEncoder.encode(funcionario.getSenha()));

        return funcionarioRepository.save(funcionario);
    }

    @Override
    public Funcionario update(Long id, Funcionario dadosAtualizacao, Long escolaId) {
        Funcionario funcionarioDB = this.findById(id);

        // Verifica se o novo email já pertence a outro funcionário
        funcionarioRepository.findByEmailAndIdNot(dadosAtualizacao.getEmail(), id)
                .ifPresent(f -> {
                    throw new BusinessException("Este email já pertence a outro usuário.");
                });

        funcionarioDB.setNome(dadosAtualizacao.getNome());
        funcionarioDB.setEmail(dadosAtualizacao.getEmail());
        funcionarioDB.setCargo(dadosAtualizacao.getCargo());
        funcionarioDB.setRole(Role.valueOf(dadosAtualizacao.getCargo().name()));

        if (dadosAtualizacao.getCargo() != Funcionario.Cargo.ADMIN && escolaId != null) {
            Escola escola = escolaRepository.findById(escolaId)
                    .orElseThrow(() -> new ResourceNotFoundException("Escola não encontrada."));
            funcionarioDB.setEscola(escola);
        } else {
            funcionarioDB.setEscola(null);
        }

        // Atualiza a senha apenas se foi enviada uma nova
        if (dadosAtualizacao.getSenha() != null && !dadosAtualizacao.getSenha().trim().isEmpty()) {
            funcionarioDB.setSenha(passwordEncoder.encode(dadosAtualizacao.getSenha()));
        }

        return funcionarioRepository.save(funcionarioDB);
    }

    @Override
    public void deleteById(Long id) {
        if (!funcionarioRepository.existsById(id)) {
            throw new ResourceNotFoundException("Funcionário não encontrado.");
        }
        funcionarioRepository.deleteById(id);
    }
}