package com.fateczl.sistemaDeGestaoEscolar;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Random;

public class GeradorDeSeeder {

    // Listas para gerar nomes aleatórios
    private static final String[] NOMES_PROPRIOS = {
        "Ana", "Bruno", "Carlos", "Daniela", "Eduardo", "Fernanda", "Gabriel", "Helena", 
        "Igor", "Julia", "Lucas", "Mariana", "Nicolas", "Olivia", "Pedro", "Rafael", 
        "Sophia", "Thiago", "Vitoria", "Yuri", "Beatriz", "Guilherme", "Larissa", 
        "Matheus", "Camila", "João", "Maria", "Diogo", "Inês", "Tiago", "Margarida"
    };
    
    private static final String[] APELIDOS = {
        "Silva", "Santos", "Oliveira", "Souza", "Rodrigues", "Ferreira", "Alves", 
        "Pereira", "Lima", "Gomes", "Costa", "Ribeiro", "Martins", "Carvalho", 
        "Almeida", "Lopes", "Soares", "Fernandes", "Vieira", "Barbosa", "Mendes", "Cruz"
    };

    // Método que constrói um nome completo aleatório
    private static String gerarNomeAleatorio(Random r) {
        String nome = NOMES_PROPRIOS[r.nextInt(NOMES_PROPRIOS.length)];
        String apelido1 = APELIDOS[r.nextInt(APELIDOS.length)];
        String apelido2 = APELIDOS[r.nextInt(APELIDOS.length)];
        
        // Evitar que a pessoa tenha dois apelidos iguais (ex: Silva Silva)
        while(apelido1.equals(apelido2)) {
            apelido2 = APELIDOS[r.nextInt(APELIDOS.length)];
        }
        
        return nome + " " + apelido1 + " " + apelido2;
    }

    public static void main(String[] args) throws IOException {
        Random random = new Random();
        StringBuilder sb = new StringBuilder();

        // 1. Cabeçalho e Imports (Mantidos iguais)
        sb.append("""
            package com.fateczl.sistemaDeGestaoEscolar.config;

            import java.time.LocalDate;
            import java.time.LocalDateTime;
            import java.util.List;

            import com.fateczl.sistemaDeGestaoEscolar.usuario.Role;
            import com.fateczl.sistemaDeGestaoEscolar.usuario.funcionario.Funcionario;
            import com.fateczl.sistemaDeGestaoEscolar.usuario.funcionario.FuncionarioRepository;
            import org.springframework.beans.factory.annotation.Autowired;
            import org.springframework.boot.CommandLineRunner;
            import org.springframework.context.annotation.Configuration;
            import org.springframework.security.crypto.password.PasswordEncoder;
            import org.springframework.transaction.annotation.Transactional;

            import com.fateczl.sistemaDeGestaoEscolar.disciplina.Disciplina;
            import com.fateczl.sistemaDeGestaoEscolar.disciplina.DisciplinaRepository;
            import com.fateczl.sistemaDeGestaoEscolar.escola.Escola;
            import com.fateczl.sistemaDeGestaoEscolar.escola.EscolaRepository;
            import com.fateczl.sistemaDeGestaoEscolar.usuario.responsavel.Responsavel;
            import com.fateczl.sistemaDeGestaoEscolar.usuario.responsavel.ResponsavelRepository;
            import com.fateczl.sistemaDeGestaoEscolar.turma.Turma;
            import com.fateczl.sistemaDeGestaoEscolar.turma.TurmaRepository;
            import com.fateczl.sistemaDeGestaoEscolar.usuario.aluno.Aluno;
            import com.fateczl.sistemaDeGestaoEscolar.usuario.aluno.AlunoRepository;
            import com.fateczl.sistemaDeGestaoEscolar.usuario.UsuarioRepository;

            @Configuration
            public class DataSeeder implements CommandLineRunner {

                @Autowired private EscolaRepository escolaRepository;
                @Autowired private DisciplinaRepository disciplinaRepository;
                @Autowired private ResponsavelRepository responsavelRepository;
                @Autowired private AlunoRepository alunoRepository;
                @Autowired private TurmaRepository turmaRepository;
                @Autowired private UsuarioRepository usuarioRepository;
                @Autowired private FuncionarioRepository funcionarioRepository;
                @Autowired private PasswordEncoder passwordEncoder;

                @Override
                @Transactional
                public void run(String... args) throws Exception {
                    if (escolaRepository.count() == 0) seedEscolas();
                    if (disciplinaRepository.count() == 0) seedDisciplinas();

                    if (funcionarioRepository.count() == 0) {
                        criarFunc("Administrador Global", "admin@sistema.com", Role.ADMIN, Funcionario.Cargo.ADMIN, null);
                    }

                    if (alunoRepository.count() == 0) {
            """);

        for (int i = 1; i <= 10; i++) {
            sb.append("            popularEscola").append(i).append("();\n");
        }

        sb.append("""
                    }
                }
            """);

        // 2. Gerar Métodos de População para as 10 Escolas
        String[] nomesEscolas = {
            "viver", "aprender", "saber", "pingodegente", "bandeirantes",
            "raiodeluz", "solnascente", "objetivo", "novageracao", "centrointegrado"
        };

        String[] turnos = {"Manhã", "Tarde"};
        String[] series = {"6º Ano", "7º Ano", "8º Ano", "9º Ano"};

        int raCounter = 1000;
        int cpfCounter = 1;

        for (int e = 1; e <= 10; e++) {
            String dominio = "@" + nomesEscolas[e - 1] + ".com.br";
            sb.append("\n    private void popularEscola").append(e).append("() {\n");
            sb.append("        Escola esc = escolaRepository.findById(").append(e).append("L).orElseThrow();\n\n");

            // Funcionários com nomes aleatórios
            sb.append("        // --- Funcionários ---\n");
            sb.append(String.format("        criarFunc(\"%s\", \"diretor%s\", Role.DIRETOR, Funcionario.Cargo.DIRETOR, esc);\n", gerarNomeAleatorio(random), dominio));
            sb.append(String.format("        criarFunc(\"%s\", \"secretaria%s\", Role.SECRETARIA, Funcionario.Cargo.SECRETARIA, esc);\n", gerarNomeAleatorio(random), dominio));
            sb.append(String.format("        criarFunc(\"%s\", \"coordenador%s\", Role.COORDENADOR, Funcionario.Cargo.COORDENADOR, esc);\n", gerarNomeAleatorio(random), dominio));
            sb.append(String.format("        criarFunc(\"%s\", \"professor%s\", Role.PROFESSOR, Funcionario.Cargo.PROFESSOR, esc);\n\n", gerarNomeAleatorio(random), dominio));

            // Turmas e Alunos
            for (String serie : series) {
                for (String turno : turnos) {
                    sb.append("        // --- ").append(serie).append(" - ").append(turno).append(" ---\n");
                    
                    StringBuilder listaAlunos = new StringBuilder("List.of(");

                    for (int a = 1; a <= 20; a++) {
                        String cpf = String.format("%011d", cpfCounter++);
                        String ra = "RA" + String.format("%05d", raCounter++);
                        String idResp = "r" + cpf;
                        String idAluno = "a" + ra;

                        // Gera nomes aleatórios para Responsável e Aluno
                        String nomeResp = gerarNomeAleatorio(random);
                        String nomeAluno = gerarNomeAleatorio(random);

                        sb.append(String.format("        Responsavel %s = criarResp(\"%s\", \"%s\");\n", idResp, nomeResp, cpf));
                        sb.append(String.format("        Aluno %s = criarAluno(\"%s\", \"%s\", %s, esc);\n", idAluno, nomeAluno, ra, idResp));

                        listaAlunos.append(idAluno);
                        if (a < 20) listaAlunos.append(", ");
                    }
                    listaAlunos.append(")");

                    sb.append(String.format("\n        criarTurma(\"%s\", \"%s\", 2025, %s);\n\n", serie, turno, listaAlunos.toString()));
                }
            }
            sb.append("    }\n");
        }

        // 3. Helpers e Dados Fixos
        sb.append("""

                // =====================================================================================
                // MÉTODOS AUXILIARES (HELPERS)
                // =====================================================================================

                private Responsavel criarResp(String nome, String cpf) {
                    String email = "resp." + cpf + "@email.com";
                    Responsavel r = new Responsavel(null, nome, email, passwordEncoder.encode("123456"), true, LocalDateTime.now(), cpf, "11999999999", null);
                    return responsavelRepository.save(r);
                }

                private Aluno criarAluno(String nome, String ra, Responsavel r, Escola e) {
                    String email = ra.toLowerCase() + "@aluno.com";
                    Aluno a = new Aluno(null, nome, email, passwordEncoder.encode("aluno123"), true, LocalDateTime.now(), ra, LocalDate.of(2010, 5, 15), e, r, null);
                    return alunoRepository.save(a);
                }

                private void criarTurma(String nome, String turno, Integer ano, List<Aluno> alunos) {
                    Turma t = new Turma(null, ano, nome, turno, alunos);
                    turmaRepository.save(t);
                }

                private void criarFunc(String nome, String email, Role role, Funcionario.Cargo cargo, Escola escola) {
                    if (usuarioRepository.findByEmail(email).isPresent()) return;
                    Funcionario f = new Funcionario();
                    f.setNome(nome);
                    f.setEmail(email);
                    f.setSenha(passwordEncoder.encode("123456"));
                    f.setRole(role);
                    f.setCargo(cargo);
                    f.setEscola(escola);
                    f.setAtivo(true);
                    f.setDataCriacao(LocalDateTime.now());
                    funcionarioRepository.save(f);
                }

                private void seedEscolas() {
                    List<Escola> escolas = List.of(
                        new Escola(null, "ESC001", "Colégio Viver",                  "11111111000101", "Rua das Flores, 123"),
                        new Escola(null, "ESC002", "Escola Aprender Mais",           "11111111000102", "Av. Principal, 456"),
                        new Escola(null, "ESC003", "Centro Educacional Saber",       "11111111000103", "Praça da Árvore, 789"),
                        new Escola(null, "ESC004", "Escola Municipal Pingo de Gente","11111111000104", "Rua do Meio, 101"),
                        new Escola(null, "ESC005", "Colégio Bandeirantes",           "11111111000105", "Av. das Nações, 202"),
                        new Escola(null, "ESC006", "Instituto de Ensino Raio de Luz","11111111000106", "Rua Sete, 303"),
                        new Escola(null, "ESC007", "Escola Estadual Sol Nascente",   "11111111000107", "Alameda dos Anjos, 404"),
                        new Escola(null, "ESC008", "Colégio Objetivo",               "11111111000108", "Rua Oito, 505"),
                        new Escola(null, "ESC009", "Escola Nova Geração",            "11111111000109", "Av. Brasil, 606"),
                        new Escola(null, "ESC010", "Centro Integrado de Educação",   "11111111000110", "Rua Dez, 707")
                    );
                    escolaRepository.saveAll(escolas);
                }

                private void seedDisciplinas() {
                    List<Disciplina> disciplinas = List.of(
                        new Disciplina(null, "POR", "Português",       "Leitura e gramática",               5.0, 100),
                        new Disciplina(null, "MAT", "Matemática",      "Álgebra e geometria",               5.0, 100),
                        new Disciplina(null, "HIS", "História",        "História do Brasil e Geral",        5.0,  80),
                        new Disciplina(null, "GEO", "Geografia",       "Geografia física e política",       5.0,  80),
                        new Disciplina(null, "CIE", "Ciências",        "Biologia, física e química",        6.0, 100),
                        new Disciplina(null, "ING", "Inglês",          "Leitura e conversação",             5.0,  60),
                        new Disciplina(null, "EDF", "Educação Física", "Prática de esportes",               5.0,  40),
                        new Disciplina(null, "ART", "Artes",           "História da arte e prática",        5.0,  40),
                        new Disciplina(null, "FIL", "Filosofia",       "Pensadores e correntes filosóficas",6.0,  60),
                        new Disciplina(null, "SOC", "Sociologia",      "Estudo da sociedade",               6.0,  60)
                    );
                    disciplinaRepository.saveAll(disciplinas);
                }
            }
            """);

        // 4. Salvar o ficheiro na raiz do projeto
        Path path = Paths.get("DataSeederGerado.java");
        Files.writeString(path, sb.toString());

        System.out.println("Sucesso! Ficheiro gerado em: " + path.toAbsolutePath());
        System.out.println("Agora é só copiar o conteúdo dele para o seu DataSeeder real!");
    }
}