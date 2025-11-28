package com.fateczl.sistemaDeGestaoEscolar.config;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.transaction.annotation.Transactional;

import com.fateczl.sistemaDeGestaoEscolar.disciplina.Disciplina;
import com.fateczl.sistemaDeGestaoEscolar.disciplina.DisciplinaRepository;
import com.fateczl.sistemaDeGestaoEscolar.escola.Escola;
import com.fateczl.sistemaDeGestaoEscolar.escola.EscolaRepository;
import com.fateczl.sistemaDeGestaoEscolar.responsavel.Responsavel;
import com.fateczl.sistemaDeGestaoEscolar.responsavel.ResponsavelRepository;
import com.fateczl.sistemaDeGestaoEscolar.turma.Turma;
import com.fateczl.sistemaDeGestaoEscolar.turma.TurmaRepository;
import com.fateczl.sistemaDeGestaoEscolar.usuario.aluno.Aluno;
import com.fateczl.sistemaDeGestaoEscolar.usuario.aluno.AlunoRepository;

@Configuration
public class DataSeeder implements CommandLineRunner {

    @Autowired
    private EscolaRepository escolaRepository;
    @Autowired
    private DisciplinaRepository disciplinaRepository;
    @Autowired
    private ResponsavelRepository responsavelRepository;
    @Autowired
    private AlunoRepository alunoRepository;
    @Autowired
    private TurmaRepository turmaRepository;
    @Autowired
    private PasswordEncoder passwordEncoder;

    @Override
    @Transactional
    public void run(String... args) throws Exception {
        // Ordem de criação é importante por causa das chaves estrangeiras
        if (escolaRepository.count() == 0)
            seedEscolas();
        
        if (disciplinaRepository.count() == 0)
            seedDisciplinas();
        
        if (responsavelRepository.count() == 0)
            seedResponsaveis();
        
        // Alunos precisam que Escolas e Responsaveis já existam
        if (alunoRepository.count() == 0)
            seedAlunos();
        
        // Turmas precisam que Alunos já existam
        if (turmaRepository.count() == 0)
            seedTurmas();
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
            new Disciplina(null, "POR", "Português", "Leitura e gramática", 5.0, 100),
            new Disciplina(null, "MAT", "Matemática", "Álgebra e geometria", 5.0, 100),
            new Disciplina(null, "HIS", "História", "História do Brasil e Geral", 5.0, 80),
            new Disciplina(null, "GEO", "Geografia", "Geografia física e política", 5.0, 80),
            new Disciplina(null, "CIE", "Ciências", "Biologia, física e química", 6.0, 100),
            new Disciplina(null, "ING", "Inglês", "Leitura e conversação", 5.0, 60),
            new Disciplina(null, "EDF", "Educação Física", "Prática de esportes", 5.0, 40),
            new Disciplina(null, "ART", "Artes", "História da arte e prática", 5.0, 40),
            new Disciplina(null, "FIL", "Filosofia", "Pensadores e correntes filosóficas", 6.0, 60),
            new Disciplina(null, "SOC", "Sociologia", "Estudo da sociedade", 6.0, 60)
        );
        disciplinaRepository.saveAll(disciplinas);
    }

    private void seedResponsaveis() {
        List<Responsavel> responsaveis = List.of(
            new Responsavel(null, "Marcos Silva", "marcos.silva@email.com", passwordEncoder.encode("123456"), true, LocalDateTime.now(), "11122233344", "11988887777", null),
            new Responsavel(null, "Ana Costa", "ana.costa@email.com", passwordEncoder.encode("123456"), true, LocalDateTime.now(), "22233344455", "11955554444", null),
            new Responsavel(null, "Carlos Pereira", "carlos.pereira@email.com", passwordEncoder.encode("123456"), true, LocalDateTime.now(), "33344455566", "11944443333", null),
            new Responsavel(null, "Fernanda Lima", "fernanda.lima@email.com", passwordEncoder.encode("123456"), true, LocalDateTime.now(), "44455566677", "11977776666", null),
            new Responsavel(null, "Bruno Rocha", "bruno.rocha@email.com", passwordEncoder.encode("123456"), true, LocalDateTime.now(), "55566677788", "11966665555", null),
            new Responsavel(null, "Juliana Alves", "juliana.alves@email.com", passwordEncoder.encode("123456"), true, LocalDateTime.now(), "66677788899", "11955556666", null),
            new Responsavel(null, "Rafael Santos", "rafael.santos@email.com", passwordEncoder.encode("123456"), true, LocalDateTime.now(), "77788899900", "11944447777", null),
            new Responsavel(null, "Paula Mendes", "paula.mendes@email.com", passwordEncoder.encode("123456"), true, LocalDateTime.now(), "88899900011", "11933332222", null),
            new Responsavel(null, "Eduardo Gomes", "eduardo.gomes@email.com", passwordEncoder.encode("123456"), true, LocalDateTime.now(), "99900011122", "11922221111", null),
            new Responsavel(null, "Camila Nunes", "camila.nunes@email.com", passwordEncoder.encode("123456"), true, LocalDateTime.now(), "00011122233", "11911110000", null),
            
            new Responsavel(null, "Roberto Almeida", "roberto.almeida@email.com", passwordEncoder.encode("123456"), true, LocalDateTime.now(), "12312312312", "11912121212", null),
            new Responsavel(null, "Patricia Souza", "patricia.souza@email.com", passwordEncoder.encode("123456"), true, LocalDateTime.now(), "23423423423", "11923232323", null),
            new Responsavel(null, "Fernando Oliveira", "fernando.oliveira@email.com", passwordEncoder.encode("123456"), true, LocalDateTime.now(), "34534534534", "11934343434", null),
            new Responsavel(null, "Gabrielle Ferreira", "gabrielle.ferreira@email.com", passwordEncoder.encode("123456"), true, LocalDateTime.now(), "45645645645", "11945454545", null),
            new Responsavel(null, "Ricardo Martins", "ricardo.martins@email.com", passwordEncoder.encode("123456"), true, LocalDateTime.now(), "56756756756", "11956565656", null),
            new Responsavel(null, "Larissa Silva", "larissa.silva@email.com", passwordEncoder.encode("123456"), true, LocalDateTime.now(), "67867867867", "11967676767", null),
            new Responsavel(null, "Marcelo Costa", "marcelo.costa@email.com", passwordEncoder.encode("123456"), true, LocalDateTime.now(), "78978978978", "11978787878", null),
            new Responsavel(null, "Vanessa Santos", "vanessa.santos@email.com", passwordEncoder.encode("123456"), true, LocalDateTime.now(), "89089089089", "11989898989", null),
            new Responsavel(null, "Andre Rodrigues", "andre.rodrigues@email.com", passwordEncoder.encode("123456"), true, LocalDateTime.now(), "90190190190", "11909090909", null),
            new Responsavel(null, "Bianca Lima", "bianca.lima@email.com", passwordEncoder.encode("123456"), true, LocalDateTime.now(), "01201201201", "11901010101", null)
        );
        responsavelRepository.saveAll(responsaveis);
    }

    private void seedAlunos() {
        List<Escola> escolas = escolaRepository.findAll();
        List<Responsavel> responsaveis = responsavelRepository.findAll();

        List<Aluno> alunos = List.of(
            new Aluno(null, "Lucas Silva", "lucas.silva@aluno.com", passwordEncoder.encode("aluno123"), true, LocalDateTime.now(), "RA001", LocalDate.of(2010, 5, 15), escolas.get(0), responsaveis.get(0), null),
            new Aluno(null, "Maria Costa", "maria.costa@aluno.com", passwordEncoder.encode("aluno123"), true, LocalDateTime.now(), "RA002", LocalDate.of(2011, 8, 20), escolas.get(0), responsaveis.get(1), null),
            new Aluno(null, "Pedro Pereira", "pedro.pereira@aluno.com", passwordEncoder.encode("aluno123"), true, LocalDateTime.now(), "RA003", LocalDate.of(2010, 3, 10), escolas.get(1), responsaveis.get(2), null),
            new Aluno(null, "Ana Lima", "ana.lima@aluno.com", passwordEncoder.encode("aluno123"), true, LocalDateTime.now(), "RA004", LocalDate.of(2011, 4, 18), escolas.get(1), responsaveis.get(3), null),
            new Aluno(null, "Bruno Rocha Jr", "bruno.jr@aluno.com", passwordEncoder.encode("aluno123"), true, LocalDateTime.now(), "RA005", LocalDate.of(2010, 6, 12), escolas.get(2), responsaveis.get(4), null),
            new Aluno(null, "Juliana Alves", "juliana.alves@aluno.com", passwordEncoder.encode("aluno123"), true, LocalDateTime.now(), "RA006", LocalDate.of(2011, 7, 22), escolas.get(2), responsaveis.get(5), null),
            new Aluno(null, "Rafael Santos Jr", "rafael.jr@aluno.com", passwordEncoder.encode("aluno123"), true, LocalDateTime.now(), "RA007", LocalDate.of(2010, 2, 5), escolas.get(3), responsaveis.get(6), null),
            new Aluno(null, "Paula Mendes", "paula.mendes@aluno.com", passwordEncoder.encode("aluno123"), true, LocalDateTime.now(), "RA008", LocalDate.of(2011, 9, 30), escolas.get(3), responsaveis.get(7), null),
            new Aluno(null, "Eduardo Gomes", "eduardo.gomes@aluno.com", passwordEncoder.encode("aluno123"), true, LocalDateTime.now(), "RA009", LocalDate.of(2010, 12, 10), escolas.get(4), responsaveis.get(8), null),
            new Aluno(null, "Camila Nunes", "camila.nunes@aluno.com", passwordEncoder.encode("aluno123"), true, LocalDateTime.now(), "RA010", LocalDate.of(2011, 1, 15), escolas.get(4), responsaveis.get(9), null),
            
            new Aluno(null, "Roberto Almeida Jr", "roberto.jr@aluno.com", passwordEncoder.encode("aluno123"), true, LocalDateTime.now(), "RA011", LocalDate.of(2012, 2, 20), escolas.get(5), responsaveis.get(10), null),
            new Aluno(null, "Patricia Souza Jr", "patricia.jr@aluno.com", passwordEncoder.encode("aluno123"), true, LocalDateTime.now(), "RA012", LocalDate.of(2012, 3, 25), escolas.get(5), responsaveis.get(11), null),
            new Aluno(null, "Fernando Oliveira Jr", "fernando.jr@aluno.com", passwordEncoder.encode("aluno123"), true, LocalDateTime.now(), "RA013", LocalDate.of(2011, 11, 11), escolas.get(6), responsaveis.get(12), null),
            new Aluno(null, "Gabrielle Ferreira Jr", "gabrielle.jr@aluno.com", passwordEncoder.encode("aluno123"), true, LocalDateTime.now(), "RA014", LocalDate.of(2011, 10, 10), escolas.get(6), responsaveis.get(13), null),
            new Aluno(null, "Ricardo Martins Jr", "ricardo.jr@aluno.com", passwordEncoder.encode("aluno123"), true, LocalDateTime.now(), "RA015", LocalDate.of(2012, 5, 5), escolas.get(7), responsaveis.get(14), null),
            new Aluno(null, "Larissa Silva Jr", "larissa.jr@aluno.com", passwordEncoder.encode("aluno123"), true, LocalDateTime.now(), "RA016", LocalDate.of(2012, 6, 6), escolas.get(7), responsaveis.get(15), null),
            new Aluno(null, "Marcelo Costa Jr", "marcelo.jr@aluno.com", passwordEncoder.encode("aluno123"), true, LocalDateTime.now(), "RA017", LocalDate.of(2011, 12, 12), escolas.get(8), responsaveis.get(16), null),
            new Aluno(null, "Vanessa Santos Jr", "vanessa.jr@aluno.com", passwordEncoder.encode("aluno123"), true, LocalDateTime.now(), "RA018", LocalDate.of(2011, 1, 30), escolas.get(8), responsaveis.get(17), null),
            new Aluno(null, "Andre Rodrigues Jr", "andre.jr@aluno.com", passwordEncoder.encode("aluno123"), true, LocalDateTime.now(), "RA019", LocalDate.of(2010, 7, 7), escolas.get(9), responsaveis.get(18), null),
            new Aluno(null, "Bianca Lima Jr", "bianca.jr@aluno.com", passwordEncoder.encode("aluno123"), true, LocalDateTime.now(), "RA020", LocalDate.of(2010, 8, 8), escolas.get(9), responsaveis.get(19), null)
        );

        alunoRepository.saveAll(alunos);
    }

    private void seedTurmas() {
        List<Aluno> alunos = alunoRepository.findAll();

        // Distribuição: 20 alunos únicos espalhados por 10 turmas (2 por turma)
        List<Turma> turmas = List.of(
            new Turma(null, 2025, "6º Ano", "Manhã", List.of(alunos.get(0), alunos.get(2))),
            new Turma(null, 2025, "6º Ano", "Tarde", List.of(alunos.get(1), alunos.get(3))),
            
            new Turma(null, 2025, "5º Ano", "Manhã", List.of(alunos.get(4), alunos.get(6))),
            new Turma(null, 2025, "5º Ano", "Tarde", List.of(alunos.get(5), alunos.get(7))),
            
            new Turma(null, 2025, "4º Ano", "Manhã", List.of(alunos.get(8), alunos.get(9))),
            new Turma(null, 2025, "4º Ano", "Tarde", List.of(alunos.get(10), alunos.get(11))), 
            
            new Turma(null, 2025, "3º Ano", "Manhã", List.of(alunos.get(12), alunos.get(13))),
            new Turma(null, 2025, "3º Ano", "Tarde", List.of(alunos.get(14), alunos.get(15))),
            
            new Turma(null, 2025, "2º Ano", "Manhã", List.of(alunos.get(16), alunos.get(17))),
            new Turma(null, 2025, "2º Ano", "Tarde", List.of(alunos.get(18), alunos.get(19)))
        );

        turmaRepository.saveAll(turmas);
    }
}