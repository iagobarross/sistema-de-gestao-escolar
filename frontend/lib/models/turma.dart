import 'dart:convert';

List<Turma> turmaFromJson(String str) =>
    List<Turma>.from(jsonDecode(str).map((x) => Turma.fromJson(x)));

String turmaToJson(List<Turma> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Turma {
  final int id;
  final int ano;
  final String serie;
  final String turno;

  Turma({
    required this.id,
    required this.ano,
    required this.serie,
    required this.turno,
  });

  factory Turma.fromJson(Map<String, dynamic> json) => Turma(
    id: json["id"],
    ano: json["ano"],
    serie: json["serie"],
    turno: json["turno"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "ano": ano,
    "serie": serie,
    "turno": turno,
  };
}
