import 'dart:convert';
import 'package:http/http.dart' as http;

class SigatokaAuditService {
  static const String baseUrl = 'http://5.161.198.89:8081/api';

  // Crear auditoría Sigatoka
  Future<Map<String, dynamic>> createSigatokaAudit({
    required String nivelAnalisis,
    required String tipoCultivo,
    required String hacienda,
    required String lote,
    required int tecnicoId,
    required String observaciones,
    required String recomendaciones,
    double? stoverReal,
    double? stoverRecomendado,
    String? estadoGeneral,
    Map<String, Map<String, double?>>? basicParams,
    Map<String, List<double?>>? completeParams,
  }) async {
    try {
      // Preparar parámetros para envío
      List<Map<String, dynamic>> parameters = [];

      if (nivelAnalisis == 'Básico' && basicParams != null) {
        // Procesar parámetros básicos (solo semanas 0 y 10)
        basicParams.forEach((paramName, weeks) {
          if (weeks['week0'] != null) {
            parameters.add({
              'parameterName': paramName,
              'weekNumber': 0,
              'value': weeks['week0'],
            });
          }
          if (weeks['week10'] != null) {
            parameters.add({
              'parameterName': paramName,
              'weekNumber': 10,
              'value': weeks['week10'],
            });
          }
        });
      } else if (nivelAnalisis == 'Completo' && completeParams != null) {
        // Procesar parámetros completos (todas las semanas)
        completeParams.forEach((paramName, weekValues) {
          for (int week = 0; week < weekValues.length; week++) {
            if (weekValues[week] != null) {
              parameters.add({
                'parameterName': paramName,
                'weekNumber': week,
                'value': weekValues[week],
              });
            }
          }
        });
      }

      final auditData = {
        'nivelAnalisis': nivelAnalisis,
        'tipoCultivo': tipoCultivo,
        'hacienda': hacienda,
        'lote': lote,
        'tecnicoId': tecnicoId,
        'observaciones': observaciones,
        'recomendaciones': recomendaciones,
        'stoverReal': stoverReal,
        'stoverRecomendado': stoverRecomendado,
        'estadoGeneral': estadoGeneral ?? _calculateOverallStatus(parameters),
        'parameters': parameters,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/sigatoka/create'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(auditData),
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        print('Auditoría Sigatoka guardada exitosamente: ${result['auditId']}');
        return result;
      } else {
        print('Error al guardar auditoría Sigatoka: ${response.statusCode}');
        return {
          'success': false,
          'message': 'Error del servidor: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('Error de conexión al guardar auditoría Sigatoka: $e');
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // Obtener todas las auditorías Sigatoka
  Future<List<Map<String, dynamic>>> getAllSigatokaAudits() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/sigatoka/all'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((audit) => audit as Map<String, dynamic>).toList();
      } else {
        print('Error al obtener auditorías Sigatoka: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error de conexión al obtener auditorías Sigatoka: $e');
      return [];
    }
  }

  // Obtener auditorías por técnico
  Future<List<Map<String, dynamic>>> getSigatokaAuditsByTechnician(
    int tecnicoId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/sigatoka/technician/$tecnicoId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((audit) => audit as Map<String, dynamic>).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Error al obtener auditorías por técnico: $e');
      return [];
    }
  }

  // Obtener detalles de una auditoría específica con parámetros
  Future<Map<String, dynamic>?> getSigatokaAuditDetails(int auditId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/sigatoka/$auditId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Error al obtener detalles de auditoría: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error de conexión al obtener detalles: $e');
      return null;
    }
  }

  // Obtener auditorías por tipo de cultivo
  Future<List<Map<String, dynamic>>> getSigatokaAuditsByCrop(
    String tipoCultivo,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/sigatoka/crop/$tipoCultivo'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((audit) => audit as Map<String, dynamic>).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Error al obtener auditorías por cultivo: $e');
      return [];
    }
  }

  // Actualizar estado de auditoría
  Future<bool> updateSigatokaAuditStatus(int auditId, String newStatus) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/sigatoka/$auditId/status'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'estado': newStatus}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error al actualizar estado: $e');
      return false;
    }
  }

  // Calcular estado general basado en parámetros
  String _calculateOverallStatus(List<Map<String, dynamic>> parameters) {
    if (parameters.isEmpty) return 'Sin evaluar';

    double totalValue = 0;
    int count = 0;

    for (var param in parameters) {
      if (param['value'] != null) {
        totalValue += param['value'];
        count++;
      }
    }

    if (count == 0) return 'Sin evaluar';

    double average = totalValue / count;

    // Lógica simplificada para clasificación
    if (average < 30) return 'Óptimo';
    if (average < 70) return 'Moderado';
    return 'Crítico';
  }

  // Verificar conectividad con el servidor
  Future<bool> testConnection() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/sigatoka/all'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      print('Error de conectividad con servidor Sigatoka: $e');
      return false;
    }
  }
}
