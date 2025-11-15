import 'dart:convert';

List<Disciplina> disciplinaFromJson(String str) =>
    List<Disciplina>.from(jsonDecode(str).map((x) => Disciplina.fromJson(x)));

String disciplinaToJson(List<Disciplina> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Disciplina {
  final int id;
  final String nome;
  final String codigo;
  final String descricao;
  final double notaMinima;
  final int cargaHoraria;

  Disciplina({
    required this.id,
    required this.nome,
    required this.codigo,
    required this.descricao,
    required this.notaMinima,
    required this.cargaHoraria,
  });

  factory Disciplina.fromJson(Map<String, dynamic> json) => Disciplina(
    id: json["id"],
    nome: json["nome"],
    codigo: json["codigo"],
    descricao: json["descricao"],
    notaMinima: (json["notaMinima"] as num).toDouble(),
    cargaHoraria: json["cargaHoraria"],
  );

  
  Map<String, dynamic> toJson() => {
    "id": id,
    "nome": nome,
    "codigo": codigo,
    "descricao": descricao,
    "notaMinima": notaMinima,
    "cargaHoraria": cargaHoraria,
  };
}
