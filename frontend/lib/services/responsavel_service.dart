import 'package:http/http.dart' as http;
import '../models/responsavel.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

class ResponsavelService {
  String get baseUrl => getBaseUrl();

  String getBaseUrl() {
    if (kIsWeb) {
      return 'http://localhost:8081/api/v1/responsavel';
    } else {
      return 'http://10.0.2.2:8081/api/v1/responsavel';
    }
  }

  Future<List<Responsavel>> getResponsaveis() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        return responsavelFromJson(response.body);
      } else {
        throw Exception(
          "Falha ao carregar responsáveis. Status: ${response.statusCode}",
        );
      }
    } on SocketException {
      throw Exception(
        "Erro de conexão: Verifique o IP e se o back-end está online.",
      );
    } catch (e) {
      throw Exception("Erro ao buscar responsáveis: ${e.toString()}");
    }
  }

  Future<Responsavel> getResponsavelById(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$id'));
      if (response.statusCode == 200) {
        return Responsavel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception(
          "Falha ao carregar responsável. Status: ${response.statusCode}",
        );
      }
    } catch (e) {
      throw Exception("Erro ao buscar responsável: ${e.toString()}");
    }
  }

  Future<Responsavel> createResponsavel(
    String nome,
    String email,
    String senha,
    String cpf,
    String telefone,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'nome': nome,
          'email': email,
          'senha': senha,
          'cpf': cpf,
          'telefone': telefone,
        }),
      );
      if (response.statusCode == 201) {
        return Responsavel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception(
          "Falha ao criar responsável. Status: ${response.statusCode} / Body: ${response.body}",
        );
      }
    } catch (e) {
      throw Exception("Erro ao criar responsável: ${e.toString()}");
    }
  }

  Future<Responsavel> updateResponsavel(
    int id,
    String nome,
    String email,
    String cpf,
    String telefone, [
    String? senha,
  ]) async {
    try {
      Map<String, dynamic> body = {
        'nome': nome,
        'email': email,
        'cpf': cpf,
        'telefone': telefone,
      };

      if (senha != null && senha.isNotEmpty) {
        body['senha'] = senha;
      }

      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(body),
      );
      if (response.statusCode == 200) {
        return Responsavel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception(
          "Falha ao atualizar responsável. Status: ${response.statusCode} / Body: ${response.body}",
        );
      }
    } catch (e) {
      throw Exception("Erro ao atualizar responsável: ${e.toString()}");
    }
  }

  Future<void> deleteResponsavel(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/$id'));
      if (response.statusCode != 204) {
        throw Exception(
          "Falha ao excluir responsável. Status: ${response.statusCode}",
        );
      }
    } catch (e) {
      throw Exception("Erro ao excluir responsável: ${e.toString()}");
    }
  }
}
