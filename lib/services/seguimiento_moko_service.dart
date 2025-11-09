import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SeguimientoMokoService {
  static const String _host = '5.161.198.89';
  static const int _port = 8081;
  static const String _basePath = '/api/seguimiento-moko';
  final storage = const FlutterSecureStorage();

  Future<Uri> get baseUri async {
    final savedUrl = await storage.read(key: 'server_url');
    if (savedUrl != null && savedUrl.isNotEmpty) {
      return Uri.parse(savedUrl).replace(path: _basePath);
    }
    return Uri(scheme: 'http', host: _host, port: _port, path: _basePath);
  }

  // Guardar seguimiento de foco
  Future<Map<String, dynamic>> guardarSeguimiento(
    Map<String, dynamic> seguimientoData,
  ) async {
    try {
      final base = await baseUri;
      final response = await http.post(
        base.replace(path: '${base.path}/registrar'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(seguimientoData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception(
          'Error al guardar seguimiento: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error de conexión al guardar seguimiento: $e');
    }
  }

  // Obtener seguimientos de un foco específico
  Future<List<Map<String, dynamic>>> getSeguimientosByFoco(int focoId) async {
    try {
      final base = await baseUri;
      final response = await http.get(
        base.replace(path: '${base.path}/foco/$focoId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception(
          'Error al obtener seguimientos: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener todos los seguimientos
  Future<List<Map<String, dynamic>>> getAllSeguimientos() async {
    try {
      final base = await baseUri;
      final response = await http.get(
        base.replace(path: '${base.path}/todos'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception(
          'Error al obtener seguimientos: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Actualizar seguimiento existente
  Future<Map<String, dynamic>> actualizarSeguimiento(
    int id,
    Map<String, dynamic> seguimientoData,
  ) async {
    try {
      final base = await baseUri;
      final response = await http.put(
        base.replace(path: '${base.path}/actualizar/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(seguimientoData),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
          'Error al actualizar seguimiento: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error de conexión al actualizar seguimiento: $e');
    }
  }

  // Eliminar seguimiento
  Future<bool> eliminarSeguimiento(int id) async {
    try {
      final base = await baseUri;
      final response = await http.delete(
        base.replace(path: '${base.path}/eliminar/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error de conexión al eliminar seguimiento: $e');
    }
  }
}
