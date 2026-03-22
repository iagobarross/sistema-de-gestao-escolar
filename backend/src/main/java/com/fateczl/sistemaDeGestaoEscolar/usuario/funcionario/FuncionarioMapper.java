package com.fateczl.sistemaDeGestaoEscolar.usuario.funcionario;

import org.springframework.stereotype.Component;
import java.util.List;
import java.util.stream.Collectors;

@Component
public class FuncionarioMapper {

    public FuncionarioResponseDTO toResponseDTO(Funcionario funcionario) {
        FuncionarioResponseDTO dto = new FuncionarioResponseDTO();

        dto.setId(funcionario.getId());
        dto.setNome(funcionario.getNome());
        dto.setEmail(funcionario.getEmail());
        dto.setCargo(funcionario.getCargo().name());
        dto.setDataCriacao(funcionario.getDataCriacao());

        // Mapeia a escola apenas se o funcionário pertencer a uma (ADMIN não tem escola)
        if (funcionario.getEscola() != null) {
            dto.setEscolaId(funcionario.getEscola().getId());
            dto.setNomeEscola(funcionario.getEscola().getNome());
        }

        return dto;
    }

    public List<FuncionarioResponseDTO> toResponseDTOList(List<Funcionario> funcionarios) {
        return funcionarios.stream().map(this::toResponseDTO).collect(Collectors.toList());
    }

    public Funcionario toEntity(FuncionarioRequestDTO dto) {
        Funcionario funcionario = new Funcionario();
        funcionario.setNome(dto.getNome());
        funcionario.setEmail(dto.getEmail());
        funcionario.setSenha(dto.getSenha());
        funcionario.setCargo(dto.getCargo());

        // O mapeamento de Escola e a Role do Spring Security são feitos no Service,
        // pois dependem de regras de negócio e buscas no banco.

        return funcionario;
    }
}