import 'package:gestao_escolar_app/services/api_client.dart';
import 'package:http/http.dart' as http;
import '../models/aluno.dart';
import 'dart:convert';
import 'dart:io';

class AlunoService {
  final String baseUrl = '${ApiClient.baseDomain}/aluno';

  Future<Map<String, dynamic>> getAlunos({
    int page = 0,
    int size = 10,
    String? nome,
    String? matricula,
    int? escolaId,
  }) async {
    String queryParams = '?page=$page&size=$size';

    if (nome != null && nome.isNotEmpty) {
      queryParams += '&nome=$nome';
    }

    if (matricula != null && matricula.isNotEmpty) {
      queryParams += '&matricula=$matricula';
    }

    if (escolaId != null) {
      queryParams += '&escolaId=$escolaId';
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl$queryParams'),
        headers: await ApiClient.getHeaders(),
      );
      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
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

  Future<Aluno> getAlunoById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$id'),
        headers: await ApiClient.getHeaders(),
      );
      if (response.statusCode == 200) {
        return Aluno.fromJson(jsonDecode(response.body));
      } else {
        throw Exception(
          "Falha ao carregar aluno. Status: ${response.statusCode}",
        );
      }
    } catch (e) {
      throw Exception("Erro ao buscar aluno: ${e.toString()}");
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
        headers: await ApiClient.getHeaders(),
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
        headers: await ApiClient.getHeaders(),
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
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: await ApiClient.getHeaders(),
      );
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
