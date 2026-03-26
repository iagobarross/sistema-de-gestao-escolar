class MatrizCurricular {
  final int id;
  final int turmaId;
  final String nomeTurma;
  final int disciplinaId;
  final String nomeDisciplina;
  final int professorId;
  final String nomeProfessor;
  final int ano;
  final int cargaHorariaTotal;
  final int aulasRealizadas;
  final String status;

  MatrizCurricular({
    required this.id,
    required this.turmaId,
    required this.nomeTurma,
    required this.disciplinaId,
    required this.nomeDisciplina,
    required this.professorId,
    required this.nomeProfessor,
    required this.ano,
    required this.cargaHorariaTotal,
    required this.aulasRealizadas,
    required this.status,
  });

  factory MatrizCurricular.fromJson(Map<String, dynamic> j) => MatrizCurricular(
    id: j['id'],
    turmaId: j['turmaId'],
    nomeTurma: j['nomeTurma'],
    disciplinaId: j['disciplinaId'],
    nomeDisciplina: j['nomeDisciplina'],
    professorId: j['professorId'],
    nomeProfessor: j['nomeProfessor'],
    ano: j['ano'],
    cargaHorariaTotal: j['cargaHorariaTotal'],
    aulasRealizadas: j['aulasRealizadas'],
    status: j['status'],
  );
}
