package com.fateczl.sistemaDeGestaoEscolar.escola;

import com.fateczl.sistemaDeGestaoEscolar.usuario.funcionario.FuncionarioRequestDTO;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class EscolaComDiretorRequestDTO {
    @Valid
    @NotNull(message = "Dados da escola são obrigatórios")
    private EscolaRequestDTO escola;

    @Valid
    @NotNull(message = "Dados do diretor são obrigatórios")
    private FuncionarioRequestDTO diretor; // Certifique-se de preencher este DTO na sua pasta de Funcionario
}