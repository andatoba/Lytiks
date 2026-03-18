import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class PlagasService {
  static const String _baseUrl = 'http://5.161.198.89:8081/api/plagas';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<Map<String, String>> _headers() async {
    final token = await _storage.read(key: 'token');
    if (token != null && token.isNotEmpty) {
      return {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };
    }
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  Future<Map<String, dynamic>> guardarResumen(Map<String, dynamic> payload) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/guardar-resumen'),
      headers: await _headers(),
      body: jsonEncode(payload),
    );

    final decodedBody = response.bodyBytes.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decodedBody;
    }

    final message = decodedBody['message']?.toString() ?? 'No se pudo guardar el resumen de plagas';
    throw Exception(message);
  }
}
