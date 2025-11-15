import 'package:http/http.dart' as http;
import '../models/aluno.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

class AlunoService {
  String get baseUrl => getBaseUrl();

  String getBaseUrl() {
    if (kIsWeb) {
      return 'http://localhost:8081/api/v1/aluno';
    } else {
      return 'http://10.0.2.2:8081/api/v1/aluno';
    }
  }

  Future<List<Aluno>> getAlunos() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        return alunoFromJson(response.body);
      } else {
        throw Exception(
          "Falha ao carregar alunos. Status: ${response.statusCode}",
        );
      }
    } on SocketException {
      throw Exception(
        "Erro de conexão: Verifique o IP e se o back-end está online.",
      );
    } catch (e) {
      throw Exception("Erro ao buscar alunos: ${e.toString()}");
    }
  }

  Map<String, dynamic> _createAlunoBody(AlunoRequestDTO dto) {
    return {
      'nome': dto.nome,
      'email': dto.email,
      'senha': dto.senha,
      'escolaId': dto.escolaId,
      'matricula': dto.matricula,
      'dataNascimento': dto.dataNascimento,
      'responsavelId': dto.responsavelId,
    };
  }

  Future<Aluno> createAluno(AlunoRequestDTO dto) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(_createAlunoBody(dto)),
      );
      if (response.statusCode == 201) {
        return Aluno.fromJson(jsonDecode(response.body));
      } else {
        throw Exception(
          "Falha ao criar aluno. Status: ${response.statusCode} / Body: ${response.body}",
        );
      }
    } catch (e) {
      throw Exception("Erro ao criar aluno: ${e.toString()}");
    }
  }

  Future<Aluno> updateAluno(int id, AlunoRequestDTO dto) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(
          _createAlunoBody(dto),
        ), // Envia o mesmo corpo da criação
      );
      if (response.statusCode == 200) {
        return Aluno.fromJson(jsonDecode(response.body));
      } else {
        throw Exception(
          "Falha ao atualizar aluno. Status: ${response.statusCode} / Body: ${response.body}",
        );
      }
    } catch (e) {
      throw Exception("Erro ao atualizar aluno: ${e.toString()}");
    }
  }

  Future<void> deleteAluno(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/$id'));
      if (response.statusCode != 204) {
        throw Exception(
          "Falha ao excluir aluno. Status: ${response.statusCode}",
        );
      }
    } catch (e) {
      throw Exception("Erro ao excluir aluno: ${e.toString()}");
    }
  }
}

class AlunoRequestDTO {
  final String nome;
  final String email;
  final String senha;
  final int escolaId;
  final String matricula;
  final String dataNascimento; // "YYYY-MM-DD"
  final int responsavelId;

  AlunoRequestDTO({
    required this.nome,
    required this.email,
    required this.senha,
    required this.escolaId,
    required this.matricula,
    required this.dataNascimento,
    required this.responsavelId,
  });
}
