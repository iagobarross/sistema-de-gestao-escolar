import 'dart:convert';
import 'package:gestao_escolar_app/models/notificacao.dart';
import 'package:gestao_escolar_app/services/api_client.dart';
import 'package:http/http.dart' as http;

class NotificacaoService {
  final String _base = '${ApiClient.baseDomain}/notificacao';

  Future<List<Notificacao>> listar() async {
    final res = await http.get(
      Uri.parse(_base),
      headers: await ApiClient.getHeaders(),
    );
    if (res.statusCode == 200) {
      final List lista = jsonDecode(utf8.decode(res.bodyBytes));
      return lista.map((j) => Notificacao.fromJson(j)).toList();
    }
    throw Exception('Erro ao carregar notificações: ${res.statusCode}');
  }

  Future<String> analisar() async {
    final res = await http.post(
      Uri.parse('$_base/analisar'),
      headers: await ApiClient.getHeaders(),
    );
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      return body['mensagem'] as String;
    }
    throw Exception('Erro ao iniciar análise: ${res.statusCode}');
  }

  Future<Notificacao> marcarLida(int id) async {
    final res = await http.patch(
      Uri.parse('$_base/$id/ler'),
      headers: await ApiClient.getHeaders(),
    );
    if (res.statusCode == 200) {
      return Notificacao.fromJson(jsonDecode(res.body));
    }
    throw Exception('Erro ao marcar como lida: ${res.statusCode}');
  }

  Future<Notificacao> encaminharAoResponsavel(int id) async {
    final res = await http.post(
      Uri.parse('$_base/$id/encaminhar'),
      headers: await ApiClient.getHeaders(),
    );
    if (res.statusCode == 200) {
      return Notificacao.fromJson(jsonDecode(res.body));
    }
    final erro = jsonDecode(res.body)['erro'] ?? 'Erro ao encaminhar';
    throw Exception(erro);
  }

  Future<int> contarPendentes() async {
    final res = await http.get(
      Uri.parse('$_base/pendentes/count'),
      headers: await ApiClient.getHeaders(),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body)['total'] as int;
    }
    return 0;
  }
}
