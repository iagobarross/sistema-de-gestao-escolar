import 'dart:convert';

import 'package:gestao_escolar_app/models/aluno.dart';

List<Turma> turmaFromJson(String str) =>
    List<Turma>.from(jsonDecode(str).map((x) => Turma.fromJson(x)));

String turmaToJson(List<Turma> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Turma {
  final int id;
  final int ano;
  final String serie;
  final String turno;
  final List<Aluno> alunos;

  Turma({
    required this.id,
    required this.ano,
    required this.serie,
    required this.turno,
    required this.alunos,
  });

  factory Turma.fromJson(Map<String, dynamic> json) => Turma(
    id: json["id"],
    ano: json["ano"],
    serie: json["serie"],
    turno: json["turno"],
    alunos: List<Aluno>.from(
      (json["alunos"] ?? []).map((x) => Aluno.fromJson(x)),
    ),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "ano": ano,
    "serie": serie,
    "turno": turno,
  };
}
