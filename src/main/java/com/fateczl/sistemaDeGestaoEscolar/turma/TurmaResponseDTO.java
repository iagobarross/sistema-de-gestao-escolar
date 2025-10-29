// Pacote: com.fateczl.sistemaDeGestaoEscolar.turma
package com.fateczl.sistemaDeGestaoEscolar.turma;

import lombok.Data; // IMPORTANTE!

@Data // Esta anotação gera os métodos setId, setAno, setSerie, setTurno...
public class TurmaResponseDTO {

    private Long id; // Corresponde ao getId() e precisa do setId(Long)
    private int ano;
    private String serie;
    private String turno;
}