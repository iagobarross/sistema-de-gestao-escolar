DROP PROCEDURE IF EXISTS sp_matricular_aluno
//

CREATE PROCEDURE sp_matricular_aluno(
    IN p_aluno_id BIGINT,
    IN p_turma_id BIGINT,
    OUT p_resultado VARCHAR(255)
)
BEGIN   
    DECLARE v_count INT;
    
    SELECT COUNT(*) INTO v_count 
    FROM turma_aluno 
    WHERE aluno_id = p_aluno_id;

    IF v_count > 0 THEN
        SET p_resultado = 'ERRO: O aluno já está matriculado em uma turma. Não é permitido múltiplas matrículas.';
    ELSE
        INSERT INTO turma_aluno (turma_id, aluno_id) VALUES (p_turma_id, p_aluno_id);
        SET p_resultado = 'SUCESSO: Matrícula realizada com sucesso.';
    END IF;
END 
//