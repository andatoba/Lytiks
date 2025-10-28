import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

class AuditService {
  final String _defaultBaseUrl = 'http://5.161.198.89:8081/api';
  final storage = const FlutterSecureStorage();

  Future<String> get baseUrl async {
    final savedUrl = await storage.read(key: 'server_url');
    return savedUrl ?? _defaultBaseUrl;
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await storage.read(key: 'token');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Test de conexión con el servidor
  Future<bool> testConnection() async {
    try {
      // Usar un endpoint simple que no requiere autenticación
      final url = Uri.parse('${await baseUrl}/clients');
      final response = await http.get(url).timeout(const Duration(seconds: 5));

      // Si obtenemos cualquier respuesta válida del servidor, tenemos conexión
      return response.statusCode >= 200 && response.statusCode < 500;
    } catch (e) {
      debugPrint('❌ Error en test de conexión: $e');
      return false;
    }
  }

  // Crear una nueva auditoría
  Future<Map<String, dynamic>> createAudit({
    required int clientId,
    required int categoryId,
    required String auditDate,
    required String status,
    required List<Map<String, dynamic>> auditData,
    String? observations,
    double? latitude,
    double? longitude,
    String? imagePath,
  }) async {
    try {
      final headers = await _getHeaders();
      final url = await baseUrl;
      final response = await http.post(
        Uri.parse('$url/audits'),
        headers: headers,
        body: json.encode({
          'clientId': clientId,
          'categoryId': categoryId,
          'auditDate': auditDate,
          'status': status,
          'auditData': auditData,
          'observations': observations,
          'latitude': latitude,
          'longitude': longitude,
          'imagePath': imagePath,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Token expirado. Por favor, inicia sesión nuevamente.');
      } else {
        throw Exception('Error al crear auditoría: ${response.body}');
      }
    } catch (e) {
      if (e.toString().contains('SocketException')) {
        throw Exception('No se puede conectar al servidor.');
      }
      rethrow;
    }
  }

  // Obtener todas las auditorías
  Future<List<Map<String, dynamic>>> getAudits() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/audits'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> auditsJson = json.decode(response.body);
        return auditsJson.cast<Map<String, dynamic>>();
      } else if (response.statusCode == 401) {
        throw Exception('Token expirado. Por favor, inicia sesión nuevamente.');
      } else {
        throw Exception('Error al obtener auditorías: ${response.body}');
      }
    } catch (e) {
      if (e.toString().contains('SocketException')) {
        throw Exception('No se puede conectar al servidor.');
      }
      rethrow;
    }
  }

  // Obtener auditorías por cliente
  Future<List<Map<String, dynamic>>> getAuditsByClient(int clientId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/audits/client/$clientId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> auditsJson = json.decode(response.body);
        return auditsJson.cast<Map<String, dynamic>>();
      } else if (response.statusCode == 401) {
        throw Exception('Token expirado. Por favor, inicia sesión nuevamente.');
      } else {
        throw Exception(
          'Error al obtener auditorías del cliente: ${response.body}',
        );
      }
    } catch (e) {
      if (e.toString().contains('SocketException')) {
        throw Exception('No se puede conectar al servidor.');
      }
      rethrow;
    }
  }

  // Obtener una auditoría por ID
  Future<Map<String, dynamic>> getAuditById(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/audits/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Token expirado. Por favor, inicia sesión nuevamente.');
      } else if (response.statusCode == 404) {
        throw Exception('Auditoría no encontrada.');
      } else {
        throw Exception('Error al obtener auditoría: ${response.body}');
      }
    } catch (e) {
      if (e.toString().contains('SocketException')) {
        throw Exception('No se puede conectar al servidor.');
      }
      rethrow;
    }
  }

  // Obtener todas las categorías de auditoría
  Future<List<Map<String, dynamic>>> getAuditCategories() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/audit-categories'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> categoriesJson = json.decode(response.body);
        return categoriesJson.cast<Map<String, dynamic>>();
      } else if (response.statusCode == 401) {
        throw Exception('Token expirado. Por favor, inicia sesión nuevamente.');
      } else {
        throw Exception('Error al obtener categorías: ${response.body}');
      }
    } catch (e) {
      if (e.toString().contains('SocketException')) {
        throw Exception('No se puede conectar al servidor.');
      }
      rethrow;
    }
  }

  // Actualizar el estado de una auditoría
  Future<Map<String, dynamic>> updateAuditStatus(int id, String status) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/audits/$id/status'),
        headers: headers,
        body: json.encode({'status': status}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Token expirado. Por favor, inicia sesión nuevamente.');
      } else if (response.statusCode == 404) {
        throw Exception('Auditoría no encontrada.');
      } else {
        throw Exception('Error al actualizar auditoría: ${response.body}');
      }
    } catch (e) {
      if (e.toString().contains('SocketException')) {
        throw Exception('No se puede conectar al servidor.');
      }
      rethrow;
    }
  }

  // Subir imagen de auditoría
  Future<String> uploadAuditImage(String imagePath, int auditId) async {
    try {
      final token = await storage.read(key: 'token');
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/audits/$auditId/image'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final responseData = json.decode(responseBody);
        return responseData['imagePath'];
      } else if (response.statusCode == 401) {
        throw Exception('Token expirado. Por favor, inicia sesión nuevamente.');
      } else {
        throw Exception('Error al subir imagen: $responseBody');
      }
    } catch (e) {
      if (e.toString().contains('SocketException')) {
        throw Exception('No se puede conectar al servidor.');
      }
      rethrow;
    }
  }
}
