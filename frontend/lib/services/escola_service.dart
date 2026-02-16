import 'package:gestao_escolar_app/services/api_client.dart';
import 'package:http/http.dart' as http;
import '../models/escola.dart';
import 'dart:convert';
import 'dart:io';

class EscolaService {
  final String baseUrl = '${ApiClient.baseDomain}/escola';

  Future<List<Escola>> getEscolas() async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: await ApiClient.getHeaders(),
      );
      if (response.statusCode == 200) {
        return escolaFromJson(response.body);
      } else {
        throw Exception(
          "Falha ao carregar escolas. Status: ${response.statusCode}",
        );
      }
    } on SocketException {
      throw Exception(
        "Erro de conexão: Verifique o IP e se o back-end está online",
      );
    } catch (e) {
      throw Exception("Erro ao buscar escolas: ${e.toString()}");
    }
  }

  Future<Escola> getEscolaById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$id'),
        headers: await ApiClient.getHeaders(),
      );
      if (response.statusCode == 200) {
        return Escola.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        throw Exception("Escola não encontrada.");
      } else {
        throw Exception(
          "Falha ao buscar escola. Status: ${response.statusCode}",
        );
      }
    } on SocketException {
      throw Exception("Erro de conexão.");
    } catch (e) {
      throw Exception("Erro ao buscar escola por ID: ${e.toString()}");
    }
  }

  Future<Escola> createEscola(
    String codigo,
    String nome,
    String cnpj,
    String endereco,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: await ApiClient.getHeaders(),
        body: jsonEncode(<String, String>{
          // Espelha o EscolaRequestDTO
          'codigo': codigo,
          'nome': nome,
          'cnpj': cnpj,
          'endereco': endereco,
        }),
      );
      if (response.statusCode == 201) {
        return Escola.fromJson(jsonDecode(response.body));
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
          "Falha ao criar escola: $errorMessage (Status: ${response.statusCode})",
        );
      }
    } on SocketException {
      throw Exception("Erro de conexão.");
    } catch (e) {
      throw Exception("Erro ao criar escola: ${e.toString()}");
    }
  }

  Future<Escola> updateEscola(
    int id,
    String codigo,
    String nome,
    String cnpj,
    String endereco,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: await ApiClient.getHeaders(),
        body: jsonEncode(<String, String>{
          // Espelha o EscolaRequestDTO
          'codigo': codigo,
          'nome': nome,
          'cnpj': cnpj,
          'endereco': endereco,
        }),
      );
      if (response.statusCode == 200) {
        return Escola.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        throw Exception("Escola não encontrada para atualização.");
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
          "Falha ao atualizar escola: $errorMessage (Status: ${response.statusCode})",
        );
      }
    } on SocketException {
      throw Exception("Erro de conexão.");
    } catch (e) {
      throw Exception("Erro ao atualizar escola: ${e.toString()}");
    }
  }

  Future<void> deleteEscola(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: await ApiClient.getHeaders(),
      );

      if (response.statusCode == 204) {
        return; // Sucesso
      } else if (response.statusCode == 404) {
        throw Exception("Escola não encontrada para exclusão.");
      } else if (response.statusCode == 400) {
        String errorMessage = "Erro ao excluir.";
        try {
          final decoded = jsonDecode(response.body);
          if (decoded['message'] != null) errorMessage = decoded['message'];
        } catch (_) {}
        throw Exception(errorMessage);
      } else {
        throw Exception(
          "Falha ao excluir escola. Status: ${response.statusCode}",
        );
      }
    } on SocketException {
      throw Exception("Erro de conexão.");
    } catch (e) {
      throw Exception("Erro ao excluir escola: ${e.toString()}");
    }
  }
}
