import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class LoteService {
  final storage = const FlutterSecureStorage();

  Future<Uri> _buildUri(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final savedUrl = await storage.read(key: 'server_url');
    final rawUrl = (savedUrl == null || savedUrl.trim().isEmpty)
        ? 'http://5.161.198.89:8081/api'
        : savedUrl.trim();
    final baseUri = Uri.parse(rawUrl);
    final baseSegments = List<String>.from(baseUri.pathSegments);

    if (!baseSegments.contains('api')) {
      baseSegments.add('api');
    }

    final fullPath = [
      ...baseSegments,
      ...path.split('/').where((segment) => segment.isNotEmpty),
    ].join('/');

    return baseUri.replace(
      path: '/$fullPath',
      queryParameters: queryParameters?.map(
        (key, value) => MapEntry(key, value.toString()),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> getAllLotes() async {
    try {
      final response = await http.get(
        await _buildUri('lotes/activos'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('Error obteniendo lotes: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getLotesByHacienda(int haciendaId) async {
    try {
      final response = await http.get(
        await _buildUri('lotes/hacienda/$haciendaId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('Error obteniendo lotes de la hacienda: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> searchLotes(String nombre) async {
    try {
      final response = await http.get(
        await _buildUri(
          'lotes/search',
          queryParameters: {'nombre': nombre},
        ),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('Error buscando lotes: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> searchLotesByCodigo(String codigo) async {
    try {
      final response = await http.get(
        await _buildUri(
          'lotes/search/codigo',
          queryParameters: {'codigo': codigo},
        ),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('Error buscando lotes por código: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> createLote({
    required String nombre,
    required String codigo,
    required int haciendaId,
    String? detalle,
    double? hectareas,
    String? variedad,
    String? edad,
    String? usuarioCreacion,
  }) async {
    try {
      final response = await http.post(
        await _buildUri('lotes'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'nombre': nombre,
          'codigo': codigo,
          'haciendaId': haciendaId,
          'detalle': detalle,
          'hectareas': hectareas,
          'variedad': variedad,
          'edad': edad,
          'usuarioCreacion': usuarioCreacion,
          'estado': 'ACTIVO',
        }),
      ).timeout(const Duration(seconds: 10));

      return json.decode(response.body);
    } catch (e) {
      print('Error creando lote: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> updateLote({
    required int id,
    required String nombre,
    required String codigo,
    String? detalle,
    double? hectareas,
    String? variedad,
    String? edad,
    String? estado,
    String? usuarioActualizacion,
  }) async {
    try {
      final response = await http.put(
        await _buildUri('lotes/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'nombre': nombre,
          'codigo': codigo,
          'detalle': detalle,
          'hectareas': hectareas,
          'variedad': variedad,
          'edad': edad,
          'estado': estado,
          'usuarioActualizacion': usuarioActualizacion,
        }),
      ).timeout(const Duration(seconds: 10));

      return json.decode(response.body);
    } catch (e) {
      print('Error actualizando lote: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> deleteLote(int id) async {
    try {
      final response = await http.delete(
        await _buildUri('lotes/$id'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      return json.decode(response.body);
    } catch (e) {
      print('Error eliminando lote: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }
}
