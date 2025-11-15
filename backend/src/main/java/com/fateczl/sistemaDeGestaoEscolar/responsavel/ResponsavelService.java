// Pacote: com.fateczl.sistemaDeGestaoEscolar.responsavel
package com.fateczl.sistemaDeGestaoEscolar.responsavel;

import java.util.List;

public interface ResponsavelService {

    public List<Responsavel> findAll();

    public Responsavel findById(Long id);

    public Responsavel create(Responsavel responsavel);

    public Responsavel update(Long id, Responsavel dadosAtualizacao);

    public void deleteById(Long id) ;
}