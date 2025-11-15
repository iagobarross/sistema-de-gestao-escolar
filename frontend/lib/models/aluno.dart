import 'dart:convert';

import 'package:gestao_escolar_app/models/escola.dart';
import 'package:gestao_escolar_app/models/responsavel.dart';

List<Aluno> alunoFromJson(String str) =>
    List<Aluno>.from(jsonDecode(str).map((x) => Aluno.fromJson(x)));

String alunoToJson(List<Aluno> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Aluno {
  final int id;
  final String nome;
  final String email;
  final DateTime dataCriacao;
  final String matricula;
  final DateTime dataNascimento;
  final int escolaId;
  final int responsavelId;

  Aluno({
    required this.id,
    required this.nome,
    required this.email,
    required this.dataCriacao,
    required this.matricula,
    required this.dataNascimento,
    required this.escolaId,
    required this.responsavelId,
  });

  factory Aluno.fromJson(Map<String, dynamic> json) => Aluno(
    id: json["id"],
    nome: json["nome"],
    email: json["email"],
    dataCriacao: DateTime.parse(json["dataCriacao"]),
    matricula: json["matricula"],
    dataNascimento: DateTime.parse(json["dataNascimento"]),
    escolaId: json["escolaId"],
    responsavelId: json["responsavelId"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "nome": nome,
    "email": email,
    "dataCriacao": dataCriacao.toIso8601String(),
    "dataNascimento": dataNascimento.toIso8601String(),
    "escolaId": escolaId,
    "matricula": matricula,
    "responsavelId": responsavelId,
  };
}
