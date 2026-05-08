import 'dart:convert';
import 'package:gestao_escolar_app/models/atividade.dart';
import 'package:gestao_escolar_app/services/api_client.dart';
import 'package:http/http.dart' as http;

class AtividadeService {
  final String _base = '${ApiClient.baseDomain}/atividade';

  Future<List<Atividade>> minhasAtividades() async {
    final res = await http.get(
      Uri.parse('$_base/professor/minhas'),
      headers: await ApiClient.getHeaders(),
    );
    if (res.statusCode == 200) {
      return (jsonDecode(utf8.decode(res.bodyBytes)) as List)
          .map((j) => Atividade.fromJson(j))
          .toList();
    }
    throw Exception('Erro ${res.statusCode}');
  }

  Future<List<Atividade>> porTurma(int turmaId) async {
    final res = await http.get(
      Uri.parse('$_base/turma/$turmaId'),
      headers: await ApiClient.getHeaders(),
    );
    if (res.statusCode == 200) {
      return (jsonDecode(utf8.decode(res.bodyBytes)) as List)
          .map((j) => Atividade.fromJson(j))
          .toList();
    }
    throw Exception('Erro ${res.statusCode}');
  }

  Future<Atividade> criar(Map<String, dynamic> body) async {
    final res = await http.post(
      Uri.parse(_base),
      headers: await ApiClient.getHeaders(),
      body: jsonEncode(body),
    );
    if (res.statusCode == 201) return Atividade.fromJson(jsonDecode(res.body));
    throw Exception(jsonDecode(res.body)['erro'] ?? 'Erro ao criar atividade');
  }

  Future<void> deletar(int id) async {
    final res = await http.delete(
      Uri.parse('$_base/$id'),
      headers: await ApiClient.getHeaders(),
    );
    if (res.statusCode != 204) throw Exception('Erro ao deletar');
  }

  Future<AtividadeEntrega> entregar(int atividadeId, String conteudo) async {
    final res = await http.post(
      Uri.parse('$_base/entregar'),
      headers: await ApiClient.getHeaders(),
      body: jsonEncode({'atividadeId': atividadeId, 'conteudo': conteudo}),
    );
    if (res.statusCode == 201)
      return AtividadeEntrega.fromJson(jsonDecode(res.body));
    throw Exception(jsonDecode(res.body)['erro'] ?? 'Erro ao entregar');
  }

  Future<List<AtividadeEntrega>> minhasEntregas() async {
    final res = await http.get(
      Uri.parse('$_base/minhas-entregas'),
      headers: await ApiClient.getHeaders(),
    );
    if (res.statusCode == 200) {
      return (jsonDecode(utf8.decode(res.bodyBytes)) as List)
          .map((j) => AtividadeEntrega.fromJson(j))
          .toList();
    }
    throw Exception('Erro ${res.statusCode}');
  }

  Future<List<AtividadeEntrega>> entregasDaAtividade(int atividadeId) async {
    final res = await http.get(
      Uri.parse('$_base/$atividadeId/entregas'),
      headers: await ApiClient.getHeaders(),
    );
    if (res.statusCode == 200) {
      return (jsonDecode(utf8.decode(res.bodyBytes)) as List)
          .map((j) => AtividadeEntrega.fromJson(j))
          .toList();
    }
    throw Exception('Erro ${res.statusCode}');
  }
}
