import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class HaciendaService {
  final storage = const FlutterSecureStorage();

  Future<String> _getBaseUrl() async {
    final savedUrl = await storage.read(key: 'server_url');
    return savedUrl ?? 'http://5.161.198.89:8081/api';
  }

  Future<List<Map<String, dynamic>>> getAllHaciendas() async {
    try {
      final baseUrl = await _getBaseUrl();
      final response = await http.get(
        Uri.parse('$baseUrl/haciendas/activas'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('Error obteniendo haciendas: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getHaciendasByCliente(int clienteId) async {
    try {
      final baseUrl = await _getBaseUrl();
      final response = await http.get(
        Uri.parse('$baseUrl/haciendas/cliente/$clienteId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('Error obteniendo haciendas del cliente: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> searchHaciendas(String nombre) async {
    try {
      final baseUrl = await _getBaseUrl();
      final response = await http.get(
        Uri.parse('$baseUrl/haciendas/search?nombre=$nombre'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('Error buscando haciendas: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> createHacienda({
    required String nombre,
    required int clienteId,
    String? detalle,
    String? ubicacion,
    double? hectareas,
    String? usuarioCreacion,
  }) async {
    try {
      final baseUrl = await _getBaseUrl();
      final response = await http.post(
        Uri.parse('$baseUrl/haciendas'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'nombre': nombre,
          'clienteId': clienteId,
          'detalle': detalle,
          'ubicacion': ubicacion,
          'hectareas': hectareas,
          'usuarioCreacion': usuarioCreacion,
          'estado': 'ACTIVO',
        }),
      ).timeout(const Duration(seconds: 10));

      return json.decode(response.body);
    } catch (e) {
      print('Error creando hacienda: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> updateHacienda({
    required int id,
    required String nombre,
    String? detalle,
    String? ubicacion,
    double? hectareas,
    String? estado,
    String? usuarioActualizacion,
  }) async {
    try {
      final baseUrl = await _getBaseUrl();
      final response = await http.put(
        Uri.parse('$baseUrl/haciendas/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'nombre': nombre,
          'detalle': detalle,
          'ubicacion': ubicacion,
          'hectareas': hectareas,
          'estado': estado,
          'usuarioActualizacion': usuarioActualizacion,
        }),
      ).timeout(const Duration(seconds: 10));

      return json.decode(response.body);
    } catch (e) {
      print('Error actualizando hacienda: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> deleteHacienda(int id) async {
    try {
      final baseUrl = await _getBaseUrl();
      final response = await http.delete(
        Uri.parse('$baseUrl/haciendas/$id'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      return json.decode(response.body);
    } catch (e) {
      print('Error eliminando hacienda: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }
}
