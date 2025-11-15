import 'dart:convert';

List<Responsavel> responsavelFromJson(String str) =>
    List<Responsavel>.from(jsonDecode(str).map((x) => Responsavel.fromJson(x)));

String responsavelToJson(List<Responsavel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Responsavel {
  final int id;
  final String nome;
  final String cpf;
  final String telefone;

  Responsavel({
    required this.id,
    required this.nome,
    required this.cpf,
    required this.telefone,
  });

  factory Responsavel.fromJson(Map<String, dynamic> json) => Responsavel(
    id: json["id"],
    nome: json["nome"],
    cpf: json["cpf"],
    telefone: json["telefone"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "nome": nome,
    "cpf": cpf,
    "telefone": telefone,
  };
}
