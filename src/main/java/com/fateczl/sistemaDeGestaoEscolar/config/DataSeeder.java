package com.fateczl.sistemaDeGestaoEscolar.config;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Configuration;
import org.springframework.transaction.annotation.Transactional;

import com.fateczl.sistemaDeGestaoEscolar.disciplina.Disciplina;
import com.fateczl.sistemaDeGestaoEscolar.disciplina.DisciplinaRepository;
import com.fateczl.sistemaDeGestaoEscolar.escola.Escola;
import com.fateczl.sistemaDeGestaoEscolar.escola.EscolaRepository;

@Configuration
public class DataSeeder implements CommandLineRunner {

	@Autowired
	private EscolaRepository escolaRepository;
	
	@Autowired
	private DisciplinaRepository disciplinaRepository;
	
	@Override
	@Transactional
	public void run(String... args) throws Exception {
		if(escolaRepository.count() == 0)
			seedEscolas();
		
		if(disciplinaRepository.count() == 0)
			seedDisciplinas();
		
	}
	
	private void seedEscolas() {
        List<Escola> escolas = List.of(
            new Escola(null, "ESC001", "Colégio Viver", "11111111000101", "Rua das Flores, 123"),
            new Escola(null, "ESC002", "Escola Aprender Mais", "11111111000102", "Av. Principal, 456"),
            new Escola(null, "ESC003", "Centro Educacional Saber", "11111111000103", "Praça da Árvore, 789"),
            new Escola(null, "ESC004", "Escola Municipal Pingo de Gente", "11111111000104", "Rua do Meio, 101"),
            new Escola(null, "ESC005", "Colégio Bandeirantes", "11111111000105", "Av. das Nações, 202"),
            new Escola(null, "ESC006", "Instituto de Ensino Raio de Luz", "11111111000106", "Rua Sete, 303"),
            new Escola(null, "ESC007", "Escola Estadual Sol Nascente", "11111111000107", "Alameda dos Anjos, 404"),
            new Escola(null, "ESC008", "Colégio Objetivo", "11111111000108", "Rua Oito, 505"),
            new Escola(null, "ESC009", "Escola Nova Geração", "11111111000109", "Av. Brasil, 606"),
            new Escola(null, "ESC010", "Centro Integrado de Educação", "11111111000110", "Rua Dez, 707")
        );

        escolaRepository.saveAll(escolas);
    }
	
	private void seedDisciplinas() {
        List<Disciplina> disciplinas = List.of(
            new Disciplina(null, "Português", "Leitura e gramática", 5.0, 100),
            new Disciplina(null, "Matemática", "Álgebra e geometria", 5.0, 100),
            new Disciplina(null, "História", "História do Brasil e Geral", 5.0, 80),
            new Disciplina(null, "Geografia", "Geografia física e política", 5.0, 80),
            new Disciplina(null, "Ciências", "Biologia, física e química", 6.0, 100),
            new Disciplina(null, "Inglês", "Leitura e conversação", 5.0, 60),
            new Disciplina(null, "Educação Física", "Prática de esportes", 5.0, 40),
            new Disciplina(null, "Artes", "História da arte e prática", 5.0, 40),
            new Disciplina(null, "Filosofia", "Pensadores e correntes filosóficas", 6.0, 60),
            new Disciplina(null, "Sociologia", "Estudo da sociedade", 6.0, 60)
        );
        
        disciplinaRepository.saveAll(disciplinas);
    }
	
	

}
