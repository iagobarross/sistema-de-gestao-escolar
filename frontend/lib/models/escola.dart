import 'dart:convert';

List<Escola> escolaFromJson(String str) =>
    List<Escola>.from(jsonDecode(str).map((x) => Escola.fromJson(x)));

String escolaToJson(List<Escola> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Escola {
  final int id;
  final String codigo;
  final String nome;
  final String cnpj;
  final String endereco;

  Escola({
    required this.id,
    required this.codigo,
    required this.nome,
    required this.cnpj,
    required this.endereco,
  });

  factory Escola.fromJson(Map<String, dynamic> json) => Escola(
    id: json["id"],
    codigo: json["codigo"],
    nome: json["nome"],
    cnpj: json["cnpj"],
    endereco: json["endereco"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "codigo": codigo,
    "nome": nome,
    "cnpj": cnpj,
    "endereco": endereco,
  };
}
