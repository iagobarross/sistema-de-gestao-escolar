import 'dart:convert';
import 'package:gestao_escolar_app/services/api_client.dart';
import 'package:gestao_escolar_app/services/auth_service.dart';
import 'package:http/http.dart' as http;

/// Serviço singleton que busca e cacheia o perfil completo do usuário logado.
///
/// O JWT contém apenas id, role e nome. Para obter o escolaId de um
/// funcionário (Diretor, Secretaria, Coordenador, Professor), precisamos
/// fazer uma chamada à API de funcionários uma única vez por sessão.
class ProfileService {
  ProfileService._();
  static final ProfileService instance = ProfileService._();

  Map<String, dynamic>? _cache;

  /// Retorna o perfil completo. Na primeira chamada faz a requisição;
  /// nas seguintes retorna o cache (evita chamadas repetidas).
  Future<Map<String, dynamic>?> getProfile() async {
    if (_cache != null) return _cache;

    final auth = AuthService();
    final payload = await auth.getPayload();
    if (payload == null) return null;

    final role = payload['role'] as String?;
    final id = payload['id'];
    if (id == null) return null;

    // Roles que têm perfil de Funcionario na API
    const rolesDeFuncionario = {
      'ADMIN',
      'DIRETOR',
      'COORDENADOR',
      'SECRETARIA',
      'PROFESSOR',
    };

    if (rolesDeFuncionario.contains(role)) {
      try {
        final res = await http.get(
          Uri.parse('${ApiClient.baseDomain}/funcionario/$id'),
          headers: await ApiClient.getHeaders(),
        );
        if (res.statusCode == 200) {
          _cache = Map<String, dynamic>.from(
            jsonDecode(utf8.decode(res.bodyBytes)),
          );
        }
      } catch (_) {
        // Se falhar, retorna null; a tela não filtrará
      }
    }

    return _cache;
  }

  /// ID da escola do funcionário logado. Nulo para ADMIN (sem escola vinculada).
  Future<int?> getEscolaId() async {
    final profile = await getProfile();
    final raw = profile?['escolaId'];
    if (raw == null) return null;
    return raw is int ? raw : int.tryParse(raw.toString());
  }

  /// Limpa o cache ao fazer logout.
  void clear() => _cache = null;
}
