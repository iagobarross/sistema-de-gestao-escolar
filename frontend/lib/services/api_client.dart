import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

class ApiClient {
  static const _storage = FlutterSecureStorage();

  // Substitua este IP pelo IP atual da sua rede quando for testar
  static const String _meuIp = '172.20.10.2';

  static String get baseDomain {
    if (kIsWeb) return 'http://localhost:8081/api/v1';
<<<<<<< Updated upstream
    return 'http://10.0.2.2:8081/api/v1';
=======
    return 'http://$_meuIp:8081/api/v1';
  }

  static String get wsDomain {
    if (kIsWeb) return 'ws://localhost:8081/ws-chat/websocket';
    return 'ws://$_meuIp:8081/ws-chat/websocket';
>>>>>>> Stashed changes
  }

  static Future<Map<String, String>> getHeaders() async {
    String? token = await _storage.read(key: 'jwt_token');
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': token != null ? 'Bearer $token' : '',
    };
  }
}