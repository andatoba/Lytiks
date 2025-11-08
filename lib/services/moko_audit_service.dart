import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MokoAuditService {
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

  // Crear una nueva auditoría Moko
  Future<Map<String, dynamic>> createMokoAudit({
    required int tecnicoId,
    required String fecha,
    required String estado,
    required List<Map<String, dynamic>> details,
    String? observaciones,
    double? latitude,
    double? longitude,
    String? photoBase64Observaciones,
    String? photoBase64Seguimiento,
  }) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('${await baseUrl}/moko-audits');

      final body = {
        'tecnicoId': tecnicoId,
        'fecha': fecha,
        'estado': estado,
        'details': details,
        'observaciones': observaciones,
        'latitude': latitude,
        'longitude': longitude,
        if (photoBase64Observaciones != null)
          'photoBase64Observaciones': photoBase64Observaciones,
        if (photoBase64Seguimiento != null)
          'photoBase64Seguimiento': photoBase64Seguimiento,
      };

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        return {
          'success': true,
          'data': responseData,
          'message': 'Auditoría Moko creada exitosamente',
        };
      } else {
        return {
          'success': false,
          'message': 'Error al crear auditoría Moko: ${response.statusCode}',
          'error': response.body,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: $e',
        'error': e.toString(),
      };
    }
  }

  // Obtener auditorías Moko del cliente
  Future<Map<String, dynamic>> getMokoAudits({int? clientId}) async {
    try {
      final headers = await _getHeaders();
      String url = '${await baseUrl}/moko-audits';

      if (clientId != null) {
        url += '?clientId=$clientId';
      }

      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {
          'success': true,
          'data': responseData,
          'message': 'Auditorías Moko obtenidas exitosamente',
        };
      } else {
        return {
          'success': false,
          'message': 'Error al obtener auditorías Moko: ${response.statusCode}',
          'error': response.body,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: $e',
        'error': e.toString(),
      };
    }
  }

  // Obtener una auditoría Moko específica
  Future<Map<String, dynamic>> getMokoAudit(int auditId) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('${await baseUrl}/moko-audits/$auditId');

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {
          'success': true,
          'data': responseData,
          'message': 'Auditoría Moko obtenida exitosamente',
        };
      } else {
        return {
          'success': false,
          'message': 'Error al obtener auditoría Moko: ${response.statusCode}',
          'error': response.body,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: $e',
        'error': e.toString(),
      };
    }
  }

  // Actualizar una auditoría Moko
  Future<Map<String, dynamic>> updateMokoAudit({
    required int auditId,
    int? clientId,
    String? auditDate,
    String? status,
    List<Map<String, dynamic>>? mokoData,
    String? observations,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('${await baseUrl}/moko-audits/$auditId');

      final body = <String, dynamic>{};
      if (clientId != null) body['clientId'] = clientId;
      if (auditDate != null) body['auditDate'] = auditDate;
      if (status != null) body['status'] = status;
      if (mokoData != null) body['mokoData'] = mokoData;
      if (observations != null) body['observations'] = observations;
      if (latitude != null) body['latitude'] = latitude;
      if (longitude != null) body['longitude'] = longitude;

      final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {
          'success': true,
          'data': responseData,
          'message': 'Auditoría Moko actualizada exitosamente',
        };
      } else {
        return {
          'success': false,
          'message':
              'Error al actualizar auditoría Moko: ${response.statusCode}',
          'error': response.body,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: $e',
        'error': e.toString(),
      };
    }
  }

  // Eliminar una auditoría Moko
  Future<Map<String, dynamic>> deleteMokoAudit(int auditId) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('${await baseUrl}/moko-audits/$auditId');

      final response = await http.delete(url, headers: headers);

      if (response.statusCode == 200 || response.statusCode == 204) {
        return {
          'success': true,
          'message': 'Auditoría Moko eliminada exitosamente',
        };
      } else {
        return {
          'success': false,
          'message': 'Error al eliminar auditoría Moko: ${response.statusCode}',
          'error': response.body,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: $e',
        'error': e.toString(),
      };
    }
  }
}
