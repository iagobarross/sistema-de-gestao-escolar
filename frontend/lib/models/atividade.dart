enum StatusEntrega { PENDENTE, ENTREGUE, ATRASADA }

class Atividade {
  final int id;
  final int matrizCurricularId;
  final String nomeDisciplina;
  final String nomeTurma;
  final String nomeProfessor;
  final String titulo;
  final String descricao;
  final DateTime dataEntrega;
  final DateTime criadaEm;
  final int totalAlunos;

  Atividade({
    required this.id,
    required this.matrizCurricularId,
    required this.nomeDisciplina,
    required this.nomeTurma,
    required this.nomeProfessor,
    required this.titulo,
    required this.descricao,
    required this.dataEntrega,
    required this.criadaEm,
    required this.totalAlunos,
  });

  bool get atrasada => DateTime.now().isAfter(dataEntrega);

  factory Atividade.fromJson(Map<String, dynamic> j) => Atividade(
    id: j['id'],
    matrizCurricularId: j['matrizCurricularId'],
    nomeDisciplina: j['nomeDisciplina'] ?? '',
    nomeTurma: j['nomeTurma'] ?? '',
    nomeProfessor: j['nomeProfessor'] ?? '',
    titulo: j['titulo'] ?? '',
    descricao: j['descricao'] ?? '',
    dataEntrega: DateTime.parse(j['dataEntrega']),
    criadaEm: DateTime.parse(j['criadaEm']),
    totalAlunos: j['totalAlunos'] ?? 0,
  );
}

class AtividadeEntrega {
  final int id;
  final int atividadeId;
  final String tituloAtividade;
  final int alunoId;
  final String nomeAluno;
  final String matriculaAluno;
  final String? conteudo;
  final DateTime? entregueEm;
  final StatusEntrega status;
  final String? arquivoNome;
  final String? arquivoTipo;
  final bool temArquivo;

  AtividadeEntrega({
    required this.id,
    required this.atividadeId,
    required this.tituloAtividade,
    required this.alunoId,
    required this.nomeAluno,
    required this.matriculaAluno,
    this.conteudo,
    this.entregueEm,
    required this.status,
    this.arquivoNome,
    this.arquivoTipo,
    required this.temArquivo,
  });

  factory AtividadeEntrega.fromJson(Map<String, dynamic> j) => AtividadeEntrega(
    id: j['id'],
    atividadeId: j['atividadeId'],
    tituloAtividade: j['tituloAtividade'] ?? '',
    alunoId: j['alunoId'],
    nomeAluno: j['nomeAluno'] ?? '',
    matriculaAluno: j['matriculaAluno'] ?? '',
    conteudo: j['conteudo'],
    entregueEm: j['entregueEm'] != null
        ? DateTime.parse(j['entregueEm'])
        : null,
    status: StatusEntrega.values.firstWhere(
      (s) => s.name == j['status'],
      orElse: () => StatusEntrega.PENDENTE,
    ),
    arquivoNome: j['arquivoNome'],
    arquivoTipo: j['arquivoTipo'],
    // Usa nome como fallback caso temArquivo não venha no JSON
    temArquivo:
        j['temArquivo'] == true ||
        (j['arquivoNome'] != null && (j['arquivoNome'] as String).isNotEmpty),
  );
}

/// Status de um aluno em relação a uma atividade (inclusive pendentes).
class AtividadeAlunoStatus {
  final int alunoId;
  final String nomeAluno;
  final String matriculaAluno;
  final int? entregaId;
  final String status; // PENDENTE | ENTREGUE | ATRASADA
  final String? conteudo;
  final String? arquivoNome;
  final String? arquivoTipo;
  final bool temArquivo;
  final DateTime? entregueEm;

  AtividadeAlunoStatus({
    required this.alunoId,
    required this.nomeAluno,
    required this.matriculaAluno,
    this.entregaId,
    required this.status,
    this.conteudo,
    this.arquivoNome,
    this.arquivoTipo,
    required this.temArquivo,
    this.entregueEm,
  });

  bool get entregou => status != 'PENDENTE';

  factory AtividadeAlunoStatus.fromJson(Map<String, dynamic> j) =>
      AtividadeAlunoStatus(
        alunoId: j['alunoId'],
        nomeAluno: j['nomeAluno'] ?? '',
        matriculaAluno: j['matriculaAluno'] ?? '',
        entregaId: j['entregaId'],
        status: j['status'] ?? 'PENDENTE',
        conteudo: j['conteudo'],
        arquivoNome: j['arquivoNome'],
        arquivoTipo: j['arquivoTipo'],
        temArquivo:
            j['temArquivo'] == true ||
            (j['arquivoNome'] != null &&
                (j['arquivoNome'] as String).isNotEmpty),
        entregueEm: j['entregueEm'] != null
            ? DateTime.parse(j['entregueEm'])
            : null,
      );
}
