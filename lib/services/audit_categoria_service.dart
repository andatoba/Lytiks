import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

class AuditCategoriaService {
  static const String _host = '5.161.198.89';
  static const int _port = 8081;
  static const String _basePath = '/api';
  final storage = const FlutterSecureStorage();

  Future<Uri> get baseUri async {
    final savedUrl = await storage.read(key: 'server_url');
    if (savedUrl != null && savedUrl.isNotEmpty) {
      return Uri.parse(savedUrl);
    }
    return Uri(
      scheme: 'http',
      host: _host,
      port: _port,
      path: _basePath,
    );
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await storage.read(key: 'token');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Obtiene todas las categorías activas
  Future<List<Map<String, dynamic>>> getCategoriasActivas() async {
    try {
      final headers = await _getHeaders();
      final uri = (await baseUri).replace(
        path: '$_basePath/audit-categorias',
      );
      
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else if (response.statusCode == 401) {
        throw Exception('Token expirado. Por favor, inicia sesión nuevamente.');
      } else {
        throw Exception('Error al obtener categorías: ${response.body}');
      }
    } catch (e) {
      if (e.toString().contains('SocketException')) {
        throw Exception('No se puede conectar al servidor.');
      }
      debugPrint('❌ Error en getCategoriasActivas: $e');
      rethrow;
    }
  }

  /// Obtiene todas las categorías con sus criterios
  Future<List<Map<String, dynamic>>> getCategoriasConCriterios() async {
    try {
      final headers = await _getHeaders();
      final uri = (await baseUri).replace(
        path: '$_basePath/audit-categorias/con-criterios',
      );
      
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else if (response.statusCode == 401) {
        throw Exception('Token expirado. Por favor, inicia sesión nuevamente.');
      } else {
        throw Exception('Error al obtener categorías con criterios: ${response.body}');
      }
    } catch (e) {
      if (e.toString().contains('SocketException')) {
        throw Exception('No se puede conectar al servidor.');
      }
      debugPrint('❌ Error en getCategoriasConCriterios: $e');
      rethrow;
    }
  }

  /// Obtiene una categoría por ID
  Future<Map<String, dynamic>> getCategoriaById(int id) async {
    try {
      final headers = await _getHeaders();
      final uri = (await baseUri).replace(
        path: '$_basePath/audit-categorias/$id',
      );
      
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 404) {
        throw Exception('Categoría no encontrada');
      } else if (response.statusCode == 401) {
        throw Exception('Token expirado. Por favor, inicia sesión nuevamente.');
      } else {
        throw Exception('Error al obtener categoría: ${response.body}');
      }
    } catch (e) {
      if (e.toString().contains('SocketException')) {
        throw Exception('No se puede conectar al servidor.');
      }
      debugPrint('❌ Error en getCategoriaById: $e');
      rethrow;
    }
  }

  /// Obtiene una categoría por código
  Future<Map<String, dynamic>> getCategoriaByCodigo(String codigo) async {
    try {
      final headers = await _getHeaders();
      final uri = (await baseUri).replace(
        path: '$_basePath/audit-categorias/codigo/$codigo',
      );
      
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 404) {
        throw Exception('Categoría no encontrada');
      } else if (response.statusCode == 401) {
        throw Exception('Token expirado. Por favor, inicia sesión nuevamente.');
      } else {
        throw Exception('Error al obtener categoría: ${response.body}');
      }
    } catch (e) {
      if (e.toString().contains('SocketException')) {
        throw Exception('No se puede conectar al servidor.');
      }
      debugPrint('❌ Error en getCategoriaByCodigo: $e');
      rethrow;
    }
  }

  /// Obtiene los criterios de una categoría
  Future<List<Map<String, dynamic>>> getCriteriosByCategoria(int categoriaId) async {
    try {
      final headers = await _getHeaders();
      final uri = (await baseUri).replace(
        path: '$_basePath/audit-categorias/$categoriaId/criterios',
      );
      
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else if (response.statusCode == 401) {
        throw Exception('Token expirado. Por favor, inicia sesión nuevamente.');
      } else {
        throw Exception('Error al obtener criterios: ${response.body}');
      }
    } catch (e) {
      if (e.toString().contains('SocketException')) {
        throw Exception('No se puede conectar al servidor.');
      }
      debugPrint('❌ Error en getCriteriosByCategoria: $e');
      rethrow;
    }
  }

  /// Crea una nueva categoría
  Future<Map<String, dynamic>> crearCategoria({
    required String codigo,
    required String nombre,
    String? descripcion,
    int? orden,
  }) async {
    try {
      final headers = await _getHeaders();
      final uri = (await baseUri).replace(
        path: '$_basePath/audit-categorias',
      );
      
      final body = {
        'codigo': codigo,
        'nombre': nombre,
        'descripcion': descripcion,
        'orden': orden,
        'activo': true,
      };
      
      final response = await http.post(
        uri,
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Token expirado. Por favor, inicia sesión nuevamente.');
      } else {
        throw Exception('Error al crear categoría: ${response.body}');
      }
    } catch (e) {
      if (e.toString().contains('SocketException')) {
        throw Exception('No se puede conectar al servidor.');
      }
      debugPrint('❌ Error en crearCategoria: $e');
      rethrow;
    }
  }

  /// Actualiza una categoría existente
  Future<Map<String, dynamic>> actualizarCategoria(
    int id,
    Map<String, dynamic> datos,
  ) async {
    try {
      final headers = await _getHeaders();
      final uri = (await baseUri).replace(
        path: '$_basePath/audit-categorias/$id',
      );
      
      final response = await http.put(
        uri,
        headers: headers,
        body: json.encode(datos),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 404) {
        throw Exception('Categoría no encontrada');
      } else if (response.statusCode == 401) {
        throw Exception('Token expirado. Por favor, inicia sesión nuevamente.');
      } else {
        throw Exception('Error al actualizar categoría: ${response.body}');
      }
    } catch (e) {
      if (e.toString().contains('SocketException')) {
        throw Exception('No se puede conectar al servidor.');
      }
      debugPrint('❌ Error en actualizarCategoria: $e');
      rethrow;
    }
  }

  /// Elimina una categoría
  Future<Map<String, dynamic>> eliminarCategoria(int id) async {
    try {
      final headers = await _getHeaders();
      final uri = (await baseUri).replace(
        path: '$_basePath/audit-categorias/$id',
      );
      
      final response = await http.delete(uri, headers: headers);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 404) {
        throw Exception('Categoría no encontrada');
      } else if (response.statusCode == 401) {
        throw Exception('Token expirado. Por favor, inicia sesión nuevamente.');
      } else {
        throw Exception('Error al eliminar categoría: ${response.body}');
      }
    } catch (e) {
      if (e.toString().contains('SocketException')) {
        throw Exception('No se puede conectar al servidor.');
      }
      debugPrint('❌ Error en eliminarCategoria: $e');
      rethrow;
    }
  }
}
