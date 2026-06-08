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
    if (res.statusCode != 204) throw Exception('Erro ao deletar atividade');
  }

  Future<AtividadeEntrega> entregar({
    required int atividadeId,
    String? conteudo,
    String? arquivoBase64,
    String? arquivoNome,
    String? arquivoTipo,
  }) async {
    final body = <String, dynamic>{'atividadeId': atividadeId};
    if (conteudo != null && conteudo.isNotEmpty) body['conteudo'] = conteudo;
    if (arquivoBase64 != null) {
      body['arquivoBase64'] = arquivoBase64;
      body['arquivoNome'] = arquivoNome;
      body['arquivoTipo'] = arquivoTipo;
    }
    final res = await http.post(
      Uri.parse('$_base/entregar'),
      headers: await ApiClient.getHeaders(),
      body: jsonEncode(body),
    );
    if (res.statusCode == 201) {
      return AtividadeEntrega.fromJson(jsonDecode(utf8.decode(res.bodyBytes)));
    }
    throw Exception(
      jsonDecode(res.body)['erro'] ?? 'Erro ao entregar atividade',
    );
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

  /// Todos os alunos da turma com status de entrega (inclusive pendentes).
  Future<List<AtividadeAlunoStatus>> statusAlunos(int atividadeId) async {
    final res = await http.get(
      Uri.parse('$_base/$atividadeId/status-alunos'),
      headers: await ApiClient.getHeaders(),
    );
    if (res.statusCode == 200) {
      return (jsonDecode(utf8.decode(res.bodyBytes)) as List)
          .map((j) => AtividadeAlunoStatus.fromJson(j))
          .toList();
    }
    throw Exception('Erro ao buscar status dos alunos: ${res.statusCode}');
  }

  /// Baixa o arquivo base64 de uma entrega específica (sob demanda).
  Future<Map<String, String>?> baixarArquivo(int entregaId) async {
    final res = await http.get(
      Uri.parse('$_base/entrega/$entregaId/arquivo'),
      headers: await ApiClient.getHeaders(),
    );
    if (res.statusCode == 200) {
      final j = jsonDecode(utf8.decode(res.bodyBytes));
      return {
        'arquivoBase64': j['arquivoBase64'] ?? '',
        'arquivoNome': j['arquivoNome'] ?? 'arquivo',
        'arquivoTipo': j['arquivoTipo'] ?? 'application/octet-stream',
      };
    }
    return null;
  }
}
