import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class LogoService {
  final storage = const FlutterSecureStorage();

  Future<String> _getBaseUrl() async {
    final savedUrl = await storage.read(key: 'server_url');
    return savedUrl ?? 'http://5.161.198.89:8081/api';
  }

  /// Obtiene el logo activo (opcionalmente filtrado por empresa)
  Future<Map<String, dynamic>?> getLogoActivo({int? idEmpresa}) async {
    try {
      final baseUrl = await _getBaseUrl();
      
      // Si no se proveyó idEmpresa, intentar obtenerlo del usuario autenticado
      int? empresaId = idEmpresa;
      if (empresaId == null) {
        final idEmpresaStr = await storage.read(key: 'id_empresa');
        if (idEmpresaStr != null) {
          empresaId = int.tryParse(idEmpresaStr);
        }
      }
      
      // Construir URL con o sin parámetro idEmpresa
      String url = '$baseUrl/logo/activo';
      if (empresaId != null && empresaId > 0) {
        url += '?idEmpresa=$empresaId';
        print('🏢 Solicitando logo para empresa ID: $empresaId');
      }
      
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('Error obteniendo logo activo: $e');
      return null;
    }
  }

  /// Obtiene todos los logos (opcionalmente filtrado por empresa)
  Future<List<Map<String, dynamic>>> getAllLogos({int? idEmpresa}) async {
    try {
      final baseUrl = await _getBaseUrl();
      
      String url = '$baseUrl/logo';
      if (idEmpresa != null && idEmpresa > 0) {
        url += '?idEmpresa=$idEmpresa';
      }
      
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('Error obteniendo logos: $e');
      return [];
    }
  }

  /// Crea un nuevo logo
  Future<Map<String, dynamic>> createLogo({
    required String nombre,
    required String rutaLogo,
    String? logoBase64,
    String? tipoMime,
    bool activo = false,
    String? descripcion,
  }) async {
    try {
      final baseUrl = await _getBaseUrl();
      final response = await http.post(
        Uri.parse('$baseUrl/logo'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'nombre': nombre,
          'rutaLogo': rutaLogo,
          'logoBase64': logoBase64,
          'tipoMime': tipoMime,
          'activo': activo,
          'descripcion': descripcion,
        }),
      ).timeout(const Duration(seconds: 10));

      return json.decode(response.body);
    } catch (e) {
      print('Error creando logo: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Actualiza un logo existente
  Future<Map<String, dynamic>> updateLogo({
    required int id,
    required String nombre,
    required String rutaLogo,
    String? logoBase64,
    String? tipoMime,
    bool? activo,
    String? descripcion,
  }) async {
    try {
      final baseUrl = await _getBaseUrl();
      final response = await http.put(
        Uri.parse('$baseUrl/logo/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'nombre': nombre,
          'rutaLogo': rutaLogo,
          'logoBase64': logoBase64,
          'tipoMime': tipoMime,
          'activo': activo,
          'descripcion': descripcion,
        }),
      ).timeout(const Duration(seconds: 10));

      return json.decode(response.body);
    } catch (e) {
      print('Error actualizando logo: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Activa un logo específico
  Future<Map<String, dynamic>> activarLogo(int id) async {
    try {
      final baseUrl = await _getBaseUrl();
      final response = await http.put(
        Uri.parse('$baseUrl/logo/$id/activar'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      return json.decode(response.body);
    } catch (e) {
      print('Error activando logo: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Elimina un logo
  Future<Map<String, dynamic>> deleteLogo(int id) async {
    try {
      final baseUrl = await _getBaseUrl();
      final response = await http.delete(
        Uri.parse('$baseUrl/logo/$id'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      return json.decode(response.body);
    } catch (e) {
      print('Error eliminando logo: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }
}
