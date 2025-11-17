import 'dart:convert';

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
  final String nomeEscola;
  final String nomeResponsavel;
  final List<String> turmas;

  Aluno({
    required this.id,
    required this.nome,
    required this.email,
    required this.dataCriacao,
    required this.matricula,
    required this.dataNascimento,
    required this.escolaId,
    required this.responsavelId,
    required this.nomeEscola,
    required this.nomeResponsavel,
    required this.turmas,
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
    nomeEscola: json["nomeEscola"] ?? 'N/A',
    nomeResponsavel: json["nomeResponsavel"] ?? 'N/A',
    turmas: List<String>.from(json["turmas"] ?? []),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "nome": nome,
    "email": email,
    "dataCriacao": dataCriacao.toIso8601String(),
    "dataNascimento":
        "${dataNascimento.year.toString().padLeft(4, '0')} - ${dataNascimento.month.toString().padLeft(2, '0')} - ${dataNascimento.day.toString().padLeft(2, '0')}",
    "escolaId": escolaId,
    "matricula": matricula,
    "responsavelId": responsavelId,
    "nomeEscola": nomeEscola,
    "nomeResponsavel": nomeResponsavel,
    "turmas": turmas,
  };
}
