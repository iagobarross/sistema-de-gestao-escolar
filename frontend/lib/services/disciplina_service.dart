import 'package:gestao_escolar_app/services/api_client.dart';

import '../../models/disciplina.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class DisciplinaService {
  final String baseUrl = '${ApiClient.baseDomain}/disciplina';

  Future<List<Disciplina>> getDisciplinas() async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: await ApiClient.getHeaders(),
      );
      if (response.statusCode == 200) {
        return disciplinaFromJson(response.body);
      } else {
        throw Exception(
          "Falha ao carregar disciplinas. Status: ${response.statusCode}",
        );
      }
    } on SocketException {
      throw Exception(
        "Erro de conexão: Verifique o IP e se o back-end está online",
      );
    } catch (e) {
      throw Exception("Erro ao buscar disciplinas: ${e.toString()}");
    }
  }

  Future<Disciplina> getDisciplinaById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$id'),
        headers: await ApiClient.getHeaders(),
      );
      if (response.statusCode == 200) {
        return Disciplina.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        throw Exception("Disciplina não encontrada.");
      } else {
        throw Exception(
          "Falha ao buscar disciplina. Status: ${response.statusCode}",
        );
      }
    } on SocketException {
      throw Exception("Erro de conexão.");
    } catch (e) {
      throw Exception("Erro ao buscar disciplina por ID: ${e.toString()}");
    }
  }

  Future<Disciplina> createDisciplina(
    String nome,
    String codigo,
    String descricao,
    double notaMinima,
    int cargaHoraria,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: await ApiClient.getHeaders(),
        body: jsonEncode(<String, dynamic>{
          // Espelha o DisciplinaRequestDTO
          'nome': nome,
          'codigo': codigo,
          'descricao': descricao,
          'notaMinima': notaMinima,
          'cargaHoraria': cargaHoraria,
        }),
      );
      if (response.statusCode == 201) {
        return Disciplina.fromJson(jsonDecode(response.body));
      } else {
        String errorMessage = response.body;
        try {
          final decoded = jsonDecode(response.body);
          if (decoded['message'] != null) {
            errorMessage = decoded['message'];
          } else if (decoded['errors'] != null) {
            errorMessage = decoded['errors'].toString();
          }
        } catch (_) {}
        throw Exception(
          "Falha ao criar disciplina: $errorMessage (Status: ${response.statusCode})",
        );
      }
    } on SocketException {
      throw Exception("Erro de conexão.");
    } catch (e) {
      throw Exception("Erro ao criar disciplina: ${e.toString()}");
    }
  }

  Future<Disciplina> updateDisciplina(
    int id,
    String nome,
    String codigo,
    String descricao,
    double notaMinima,
    int cargaHoraria,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: await ApiClient.getHeaders(),
        body: jsonEncode(<String, dynamic>{
          'nome': nome,
          'codigo': codigo,
          'descricao': descricao,
          'notaMinima': notaMinima,
          'cargaHoraria': cargaHoraria,
        }),
      );
      if (response.statusCode == 200) {
        return Disciplina.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        throw Exception("Disciplina não encontrada para atualização.");
      } else {
        String errorMessage = response.body;
        try {
          final decoded = jsonDecode(response.body);
          if (decoded['message'] != null) {
            errorMessage = decoded['message'];
          } else if (decoded['errors'] != null) {
            errorMessage = decoded['errors'].toString();
          }
        } catch (_) {}
        throw Exception(
          "Falha ao atualizar disciplina: $errorMessage (Status: ${response.statusCode})",
        );
      }
    } on SocketException {
      throw Exception("Erro de conexão.");
    } catch (e) {
      throw Exception("Erro ao atualizar disciplina: ${e.toString()}");
    }
  }

  Future<void> deleteDisciplina(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: await ApiClient.getHeaders(),
      );

      if (response.statusCode == 204) {
        return; // Sucesso
      } else if (response.statusCode == 404) {
        throw Exception("Disciplina não encontrada para exclusão.");
      } else if (response.statusCode == 400) {
        String errorMessage = "Erro ao excluir.";
        try {
          final decoded = jsonDecode(response.body);
          if (decoded['message'] != null) errorMessage = decoded['message'];
        } catch (_) {}
        throw Exception(errorMessage);
      } else {
        throw Exception(
          "Falha ao excluir disciplina. Status: ${response.statusCode}",
        );
      }
    } on SocketException {
      throw Exception("Erro de conexão.");
    } catch (e) {
      throw Exception("Erro ao excluir disciplina: ${e.toString()}");
    }
  }
}
