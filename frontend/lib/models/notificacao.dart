enum TipoNotificacao {
  BAIXO_DESEMPENHO,
  BAIXA_FREQUENCIA,
  DESEMPENHO_E_FREQUENCIA,
}

enum StatusNotificacao { PENDENTE, LIDA, ENCAMINHADA }

class Notificacao {
  final int id;
  final int alunoId;
  final String nomeAluno;
  final String matriculaAluno;
  final String nomeTurma;
  final String conteudoIA;
  final String resumo;
  final TipoNotificacao tipo;
  final StatusNotificacao status;
  final DateTime criadaEm;
  final DateTime? encaminhadaEm;

  Notificacao({
    required this.id,
    required this.alunoId,
    required this.nomeAluno,
    required this.matriculaAluno,
    required this.nomeTurma,
    required this.conteudoIA,
    required this.resumo,
    required this.tipo,
    required this.status,
    required this.criadaEm,
    this.encaminhadaEm,
  });

  factory Notificacao.fromJson(Map<String, dynamic> j) => Notificacao(
    id: j['id'],
    alunoId: j['alunoId'] ?? 0,
    nomeAluno: j['nomeAluno'] ?? '',
    matriculaAluno: j['matriculaAluno'] ?? '',
    nomeTurma: j['nomeTurma'] ?? '',
    conteudoIA: j['conteudoIA'] ?? '',
    resumo: j['resumo'] ?? '',
    tipo: TipoNotificacao.values.firstWhere(
      (e) => e.name == j['tipo'],
      orElse: () => TipoNotificacao.BAIXO_DESEMPENHO,
    ),
    status: StatusNotificacao.values.firstWhere(
      (e) => e.name == j['status'],
      orElse: () => StatusNotificacao.PENDENTE,
    ),
    criadaEm: DateTime.parse(j['criadaEm']),
    encaminhadaEm: j['encaminhadaEm'] != null
        ? DateTime.parse(j['encaminhadaEm'])
        : null,
  );
}
