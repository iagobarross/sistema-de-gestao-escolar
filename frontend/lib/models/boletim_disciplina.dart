class BoletimDisciplina {
  final int disciplinaId;
  final String nomeDisciplina;
  final String nomeProfessor;
  final double notaMinima;
  final double? mediaBimestre1;
  final double? mediaBimestre2;
  final double? mediaBimestre3;
  final double? mediaBimestre4;
  final double? mediaFinal;
  final int totalAulas;
  final int faltas;
  final double? percentualPresenca;
  final String situacao;

  BoletimDisciplina({
    required this.disciplinaId,
    required this.nomeDisciplina,
    required this.nomeProfessor,
    required this.notaMinima,
    this.mediaBimestre1,
    this.mediaBimestre2,
    this.mediaBimestre3,
    this.mediaBimestre4,
    this.mediaFinal,
    required this.totalAulas,
    required this.faltas,
    this.percentualPresenca,
    required this.situacao,
  });

  factory BoletimDisciplina.fromJson(Map<String, dynamic> j) =>
      BoletimDisciplina(
        disciplinaId: j['disciplinaId'],
        nomeDisciplina: j['nomeDisciplina'],
        nomeProfessor: j['nomeProfessor'],
        notaMinima: (j['notaMinima'] as num).toDouble(),
        mediaBimestre1: j['mediaBimestre1'] != null
            ? (j['mediaBimestre1'] as num).toDouble()
            : null,
        mediaBimestre2: j['mediaBimestre2'] != null
            ? (j['mediaBimestre2'] as num).toDouble()
            : null,
        mediaBimestre3: j['mediaBimestre3'] != null
            ? (j['mediaBimestre3'] as num).toDouble()
            : null,
        mediaBimestre4: j['mediaBimestre4'] != null
            ? (j['mediaBimestre4'] as num).toDouble()
            : null,
        mediaFinal: j['mediaFinal'] != null
            ? (j['mediaFinal'] as num).toDouble()
            : null,
        totalAulas: j['totalAulas'],
        faltas: j['faltas'],
        percentualPresenca: j['percentualPresenca'] != null
            ? (j['percentualPresenca'] as num).toDouble()
            : null,
        situacao: j['situacao'],
      );
}
