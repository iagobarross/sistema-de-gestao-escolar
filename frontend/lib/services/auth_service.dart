import 'dart:convert';
import 'package:gestao_escolar_app/services/api_client.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../models/auth_models.dart';

class AuthService {
  final storage = const FlutterSecureStorage();

  final String baseUrl = ApiClient.baseDomain;

  Future<bool> login(String email, String senha) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'senha': senha}),
      );

      if (response.statusCode == 200) {
        final authData = AuthResponse.fromJson(jsonDecode(response.body));
        await storage.write(key: 'jwt_token', value: authData.accessToken);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<String?> getToken() async {
    return await storage.read(key: 'jwt_token');
  }

  Future<void> logout() async {
    await storage.delete(key: 'jwt_token');
  }

  Future<String?> getRole() async {
    String? token = await getToken();
    if (token != null && !JwtDecoder.isExpired(token)) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      return decodedToken['role'];
    }
    return null;
  }
}
