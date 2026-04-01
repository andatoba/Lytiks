import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

class AuditService {
  // Obtener todas las auditorías (normales, moko, sigatoka) creadas por un usuario
  Future<Map<String, dynamic>> getAllAuditsByUser(int userId) async {
    try {
      final headers = await _getHeaders();
      final uri =
          (await baseUri).replace(path: '$_basePath/audits/user/$userId');
      final response = await http.get(
        uri,
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Token expirado. Por favor, inicia sesión nuevamente.');
      } else {
        throw Exception(
            'Error al obtener auditorías del usuario: ${response.body}');
      }
    } catch (e) {
      if (e.toString().contains('SocketException')) {
        throw Exception('No se puede conectar al servidor.');
      }
      rethrow;
    }
  }

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

  // Test de conexión con el servidor
  Future<bool> testConnection() async {
    try {
      // Usar un endpoint simple que no requiere autenticación
      final uri = (await baseUri).replace(path: '${_basePath}/clients');
      final response = await http.get(uri).timeout(const Duration(seconds: 5));

      // Si obtenemos cualquier respuesta válida del servidor, tenemos conexión
      return response.statusCode >= 200 && response.statusCode < 500;
    } catch (e) {
      debugPrint('❌ Error en test de conexión: $e');
      return false;
    }
  }

  // Crear una nueva auditoría
  Future<Map<String, dynamic>> createAuditBackend({
    required String hacienda,
    required String cultivo,
    required String fecha,
    required int tecnicoId,
    required String estado,
    String? observaciones,
    required List<Map<String, dynamic>> scores,
    String? cedulaCliente,
    List<Map<String, dynamic>>? trayectoUbicaciones,
    Map<String, dynamic>? evaluaciones,
  }) async {
    try {
      final headers = await _getHeaders();
      final uri = (await baseUri).replace(path: '${_basePath}/audits/create');
      final Map<String, dynamic> body = {
        'hacienda': hacienda,
        'cultivo': cultivo,
        'fecha': fecha,
        'tecnicoId': tecnicoId,
        'estado': estado,
        'observaciones': observaciones,
        'scores': scores,
      };
      if (cedulaCliente != null && cedulaCliente.isNotEmpty) {
        body['cedulaCliente'] = cedulaCliente;
      }
      if (trayectoUbicaciones != null && trayectoUbicaciones.isNotEmpty) {
        body['trayectoUbicaciones'] = trayectoUbicaciones;
      }
      if (evaluaciones != null && evaluaciones.isNotEmpty) {
        body['evaluaciones'] = evaluaciones;
      }
      final response = await http.post(
        uri,
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Token expirado. Por favor, inicia sesión nuevamente.');
      } else {
        throw Exception('Error al crear auditoría: \\${response.body}');
      }
    } catch (e) {
      if (e.toString().contains('SocketException')) {
        throw Exception('No se puede conectar al servidor.');
      }
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> buildBackendScoresFromAuditMap(
    Map<String, dynamic> auditMap,
  ) async {
    final List<Map<String, dynamic>> scores = [];

    for (final entry in auditMap.entries) {
      final key = entry.key;
      final value = entry.value;

      if (value is List) {
        for (final rawItem in value) {
          if (rawItem is! Map) {
            continue;
          }
          final item = Map<String, dynamic>.from(rawItem);
          final int puntuacion =
              int.tryParse((item['calculatedScore'] ?? 0).toString()) ?? 0;
          final int maxPuntuacion =
              int.tryParse((item['maxScore'] ?? 100).toString()) ?? 100;
          final String? photoPath = item['photoPath']?.toString();
          scores.add({
            'categoria': '$key - ${item['name'] ?? 'Sin nombre'}',
            'puntuacion': puntuacion,
            'maxPuntuacion': maxPuntuacion,
            'observaciones': item['observaciones']?.toString(),
            'photoBase64': await _fileToBase64(photoPath),
          });
        }
      }
    }

    final seleccionResumen = auditMap['SeleccionResumen'];
    if (seleccionResumen is Map) {
      final resumen = Map<String, dynamic>.from(seleccionResumen);
      scores.add({
        'categoria': 'SELECCION - CRITERIO',
        'puntuacion': (100 - _toDouble(resumen['porcentajeMalSeleccionadas']))
            .clamp(0, 100)
            .round(),
        'maxPuntuacion': 100,
        'observaciones': 'Total plantas: ${resumen['totalPlantas'] ?? 0}, '
            'Mal seleccionadas: ${resumen['plantasMalSeleccionadas'] ?? 0}, '
            'Observacion: ${resumen['observacion'] ?? ''}',
      });
    }

    final cosechaResumen = auditMap['CosechaResumen'];
    if (cosechaResumen is Map) {
      final resumen = Map<String, dynamic>.from(cosechaResumen);
      scores.add({
        'categoria': 'COSECHA - RESUMEN',
        'puntuacion':
            int.tryParse((resumen['calificacion'] ?? 0).toString()) ?? 0,
        'maxPuntuacion': 100,
        'observaciones': 'Bajo grado: ${resumen['porcentajeBajoGrado'] ?? 0}%, '
            'Sobre grado: ${resumen['porcentajeSobreGrado'] ?? 0}%, '
            'Cintas: ${jsonEncode(resumen['colorCintaPorSemana'] ?? {})}',
        'photoBase64': await _fileToBase64(resumen['photoPath']?.toString()),
      });
    }

    return scores;
  }

  static double _toDouble(dynamic value) {
    if (value == null) {
      return 0;
    }
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value.toString()) ?? 0;
  }

  static Future<String?> _fileToBase64(String? path) async {
    if (path == null || path.isEmpty || kIsWeb) {
      return null;
    }
    try {
      final file = File(path);
      if (!await file.exists()) {
        return null;
      }
      final bytes = await file.readAsBytes();
      return base64Encode(bytes);
    } catch (_) {
      return null;
    }
  }

  // Obtener todas las auditorías
  Future<List<Map<String, dynamic>>> getAudits() async {
    try {
      final headers = await _getHeaders();
      final uri = (await baseUri).replace(path: '${_basePath}/audits');
      final response = await http.get(
        uri,
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
      final uri =
          (await baseUri).replace(path: '${_basePath}/audits/client/$clientId');
      final response = await http.get(
        uri,
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
      final uri = (await baseUri).replace(path: '${_basePath}/audits/$id');
      final response = await http.get(
        uri,
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
      final uri =
          (await baseUri).replace(path: '${_basePath}/audit-categories');
      final response = await http.get(
        uri,
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
      final uri =
          (await baseUri).replace(path: '${_basePath}/audits/$id/status');
      final response = await http.put(
        uri,
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
      final uri =
          (await baseUri).replace(path: '${_basePath}/audits/$auditId/image');
      final request = http.MultipartRequest(
        'POST',
        uri,
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
