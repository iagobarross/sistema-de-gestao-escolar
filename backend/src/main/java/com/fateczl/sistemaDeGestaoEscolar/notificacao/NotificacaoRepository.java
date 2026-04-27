package com.fateczl.sistemaDeGestaoEscolar.notificacao;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.util.List;
import com.fateczl.sistemaDeGestaoEscolar.usuario.funcionario.Funcionario;


@Repository
public interface NotificacaoRepository extends JpaRepository<Notificacao, Long> {
    
    List<Notificacao> findByCoordenadorIdOrderByCriadaEmDesc(Long coordenadorId);

    boolean existsByAlunoIdAndAnoReferenciaAndMesReferencia(Long alunoId, int ano, int mes);

    long countByCoordenadorIdAndStatus(Long coordenadorId, StatusNotificacao status);


    @Query("""
            SELECT n FROM Notificacao n
            WHERE n.coordenador.escola.id = :escolaId
            ORDER BY n.criadaEm DESC
            """)
    List<Notificacao> findByEscolaId(@Param("escolaId") Long escolaId);
}
