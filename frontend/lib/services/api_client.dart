import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

class ApiClient {
  static const _storage = FlutterSecureStorage();

  static String get baseDomain {
    if (kIsWeb) return 'http://localhost:8081/api/v1';
    return 'http://10.0.2.2:8081/api/v1';
  }

  static Future<Map<String, String>> getHeaders() async {
    String? token = await _storage.read(key: 'jwt_token');
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': token != null ? 'Bearer $token' : '',
    };
  }
}
