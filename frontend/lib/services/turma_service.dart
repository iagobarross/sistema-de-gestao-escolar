import 'package:gestao_escolar_app/models/aluno.dart';
import 'package:http/http.dart' as http;
import '../models/turma.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

class TurmaService {
  String get baseUrl => getBaseUrl();

  String getBaseUrl() {
    if (kIsWeb) {
      return 'http://localhost:8081/api/v1/turma';
    } else {
      return 'http://10.0.2.2:8081/api/v1/turma';
    }
  }

  Future<List<Turma>> getTurmas() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        return turmaFromJson(response.body);
      } else {
        throw Exception(
          "Falha ao carregar turmas. Status: ${response.statusCode}",
        );
      }
    } on SocketException {
      throw Exception(
        "Erro de conexão: Verifique o IP e se o back-end está online.",
      );
    } catch (e) {
      throw Exception("Erro ao buscar turmas: ${e.toString()}");
    }
  }

  Future<Turma> getTurmaById(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$id'));
      if (response.statusCode == 200) {
        return Turma.fromJson(jsonDecode(response.body));
      } else {
        throw Exception(
          "Falha ao carregar turma. Status: ${response.statusCode}",
        );
      }
    } catch (e) {
      throw Exception("Erro ao buscar turma: ${e.toString()}");
    }
  }

  Future<List<Aluno>> getAlunosByTurma(int turmaId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$turmaId/alunos'));
      if (response.statusCode == 200) {
        return alunoFromJson(response.body);
      } else {
        throw Exception(
          "Falha ao carregar alunos da turma. Status: ${response.statusCode}",
        );
      }
    } catch (e) {
      throw Exception("Erro ao buscar alunos da turma: ${e.toString()}");
    }
  }

  Future<Turma> createTurma(int ano, String serie, String turno) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'ano': ano,
          'serie': serie,
          'turno': turno,
        }),
      );
      if (response.statusCode == 201) {
        return Turma.fromJson(jsonDecode(response.body));
      } else {
        throw Exception(
          "Falha ao criar turma. Status: ${response.statusCode} / Body: ${response.body}",
        );
      }
    } catch (e) {
      throw Exception("Erro ao criar turma: ${e.toString()}");
    }
  }

  Future<Turma> updateTurma(int id, int ano, String serie, String turno) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'ano': ano,
          'serie': serie,
          'turno': turno,
        }),
      );
      if (response.statusCode == 200) {
        return Turma.fromJson(jsonDecode(response.body));
      } else {
        throw Exception(
          "Falha ao atualizar turma. Status: ${response.statusCode} / Body: ${response.body}",
        );
      }
    } catch (e) {
      throw Exception("Erro ao atualizar turma: ${e.toString()}");
    }
  }

  Future<void> deleteTurma(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/$id'));
      if (response.statusCode != 204) {
        throw Exception(
          "Falha ao excluir turma. Status: ${response.statusCode}",
        );
      }
    } catch (e) {
      throw Exception("Erro ao excluir turma: ${e.toString()}");
    }
  }

  Future<void> adicionarAlunoNaTurma(int turmaId, int alunoId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$turmaId/matricular/$alunoId'),
      );

      if (response.statusCode == 200) {
        return; // Sucesso
      } else if (response.statusCode == 400) {
        throw Exception(response.body);
      } else {
        throw Exception(
          "Falha ao adicionar aluno à turma. Status: ${response.statusCode}",
        );
      }
    } catch (e) {
      // Repassa a exceção para a tela tratar
      rethrow;
    }
  }

  Future<void> removerAlunoDaTurma(int turmaId, int alunoId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$turmaId/alunos/$alunoId'),
      );
      if (response.statusCode != 204) {
        throw Exception(
          "Falha ao remover aluno da turma. Status: ${response.statusCode}",
        );
      }
    } catch (e) {
      throw Exception("Erro ao remover aluno: ${e.toString()}");
    }
  }
}
