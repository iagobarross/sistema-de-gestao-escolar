import 'dart:convert';
import 'package:gestao_escolar_app/services/api_client.dart';
import 'package:http/http.dart' as http;

class FuncionarioService {
  final String _base = '${ApiClient.baseDomain}/funcionario';

  Future<List<Map<String, dynamic>>> listarPorEscola(int escolaId) async {
    final res = await http.get(
      Uri.parse('$_base?escolaId=$escolaId'),
      headers: await ApiClient.getHeaders(),
    );
    if (res.statusCode == 200) {
      return List<Map<String, dynamic>>.from(
        jsonDecode(utf8.decode(res.bodyBytes)),
      );
    }
    throw Exception('Erro ao listar funcionários: ${res.statusCode}');
  }

  Future<Map<String, dynamic>> criar(Map<String, dynamic> dados) async {
    final res = await http.post(
      Uri.parse(_base),
      headers: await ApiClient.getHeaders(),
      body: jsonEncode(dados),
    );
    if (res.statusCode == 201) {
      return jsonDecode(res.body);
    }
    throw Exception('Erro ao criar funcionário: ${res.body}');
  }

  Future<Map<String, dynamic>> criarEscolaComDiretor(
    Map<String, dynamic> dados,
  ) async {
    final res = await http.post(
      Uri.parse('${ApiClient.baseDomain}/escola/com-diretor'),
      headers: await ApiClient.getHeaders(),
      body: jsonEncode(dados),
    );
    if (res.statusCode == 201) return jsonDecode(res.body);
    throw Exception('Erro ao criar escola: ${res.body}');
  }
}
