class Aula {
  final int id;
  final int matrizCurricularId;
  final String nomeDisciplina;
  final String nomeTurma;
  final DateTime data;
  final String conteudo;
  final int numeroAula;
  final bool chamadaLancada;

  Aula({
    required this.id,
    required this.matrizCurricularId,
    required this.nomeDisciplina,
    required this.nomeTurma,
    required this.data,
    required this.conteudo,
    required this.numeroAula,
    required this.chamadaLancada,
  });

  factory Aula.fromJson(Map<String, dynamic> j) => Aula(
    id: j['id'],
    matrizCurricularId: j['matrizCurricularId'],
    nomeDisciplina: j['nomeDisciplina'],
    nomeTurma: j['nomeTurma'],
    data: DateTime.parse(j['data']),
    conteudo: j['conteudo'] ?? '',
    numeroAula: j['numeroAula'],
    chamadaLancada: j['chamadaLancada'] ?? false,
  );
}
