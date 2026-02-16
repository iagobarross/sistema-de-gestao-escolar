import 'aluno.dart';

class TurmaDetails {
  final int id;
  final int ano;
  final String serie;
  final String turno;
  final List<Aluno> alunos;

  TurmaDetails({
    required this.id,
    required this.ano,
    required this.serie,
    required this.turno,
    required this.alunos,
  });
}
