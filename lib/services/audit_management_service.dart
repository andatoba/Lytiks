import 'dart:convert';
import 'package:http/http.dart' as http;

class AuditManagementService {
  static const String _host = '5.161.198.89';
  static const int _port = 8081;
  static const String _basePath = '/api';
  
  Future<Uri> get baseUri async {
    return Uri(
      scheme: 'http',
      host: _host,
      port: _port,
      path: _basePath,
    );
  }

  // Obtener todas las auditorías (Moko, Sigatoka y regulares)
  Future<List<Map<String, dynamic>>> getAllAudits() async {
    List<Map<String, dynamic>> allAudits = [];

    try {
      // Obtener auditorías Moko
      final uri = (await baseUri).replace(path: '${_basePath}/moko/all');
      final mokoResponse = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      if (mokoResponse.statusCode == 200) {
        final List<dynamic> mokoData = json.decode(mokoResponse.body);
        for (var audit in mokoData) {
          allAudits.add({
            'id': audit['id'],
            'type': 'Moko',
            'fecha': audit['fecha'],
            'hacienda': audit['hacienda'] ?? 'N/A',
            'lote': audit['lote'] ?? 'N/A',
            'estado': audit['estado'] ?? 'PENDIENTE',
            'tecnicoId': audit['tecnicoId'],
            'observaciones': audit['observaciones'] ?? '',
            'cumplimientoGeneral': audit['cumplimientoGeneral'],
            'estadoImplementacion': audit['estadoImplementacion'],
          });
        }
      }

      // Obtener auditorías Sigatoka
      final sigatokaUri = (await baseUri).replace(path: '${_basePath}/sigatoka/all');
      final sigatokaResponse = await http.get(
        sigatokaUri,
        headers: {'Content-Type': 'application/json'},
      );

      if (sigatokaResponse.statusCode == 200) {
        final List<dynamic> sigatokaData = json.decode(sigatokaResponse.body);
        for (var audit in sigatokaData) {
          allAudits.add({
            'id': audit['id'],
            'type': 'Sigatoka',
            'fecha': audit['fecha'],
            'hacienda': audit['hacienda'] ?? 'N/A',
            'lote': audit['lote'] ?? 'N/A',
            'estado': audit['estado'] ?? 'PENDIENTE',
            'tecnicoId': audit['tecnicoId'],
            'observaciones': audit['observaciones'] ?? '',
            'nivelAnalisis': audit['nivelAnalisis'],
            'tipoCultivo': audit['tipoCultivo'],
            'estadoGeneral': audit['estadoGeneral'],
          });
        }
      }

      // Obtener auditorías regulares
      final regularUri = (await baseUri).replace(path: '${_basePath}/audits/all');
      final regularResponse = await http.get(
        regularUri,
        headers: {'Content-Type': 'application/json'},
      );

      if (regularResponse.statusCode == 200) {
        final List<dynamic> regularData = json.decode(regularResponse.body);
        for (var audit in regularData) {
          allAudits.add({
            'id': audit['id'],
            'type': 'Regular',
            'date': audit['fecha'],
            'clientName': audit['hacienda'] ?? 'N/A',
            'cultivo': audit['cultivo'] ?? 'N/A',
            'status': audit['estado'] ?? 'PENDIENTE',
            'tecnicoId': audit['tecnicoId'],
            'observaciones': audit['observaciones'] ?? '',
          });
        }
      }

      // Ordenar por fecha (más recientes primero)
      allAudits.sort((a, b) {
        String dateA = a['fecha'] ?? '';
        String dateB = b['fecha'] ?? '';
        return dateB.compareTo(dateA);
      });
    } catch (e) {
      print('Error al obtener auditorías: $e');
    }

    return allAudits;
  }

  // Filtrar auditorías por tipo
  Future<List<Map<String, dynamic>>> getAuditsByType(String type) async {
    final allAudits = await getAllAudits();

    if (type == 'Todas') {
      return allAudits;
    }

    return allAudits.where((audit) => audit['type'] == type).toList();
  }

  // Buscar auditorías por texto
  Future<List<Map<String, dynamic>>> searchAudits(
    String searchQuery,
    String filterType,
  ) async {
    final audits = await getAuditsByType(filterType);

    if (searchQuery.isEmpty) {
      return audits;
    }

    return audits.where((audit) {
      final searchLower = searchQuery.toLowerCase();
      final hacienda = (audit['hacienda'] ?? '').toString().toLowerCase();
      final lote = (audit['lote'] ?? '').toString().toLowerCase();
      final cultivo = (audit['cultivo'] ?? '').toString().toLowerCase();
      final observaciones = (audit['observaciones'] ?? '')
          .toString()
          .toLowerCase();

      return hacienda.contains(searchLower) ||
          lote.contains(searchLower) ||
          cultivo.contains(searchLower) ||
          observaciones.contains(searchLower);
    }).toList();
  }

  // Crear auditoría Sigatoka
  Future<Map<String, dynamic>> createSigatokaAudit(
    Map<String, dynamic> auditData,
  ) async {
    try {
      final uri = (await baseUri).replace(path: '${_basePath}/sigatoka/create');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(auditData),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Error del servidor: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // Obtener detalles de auditoría Sigatoka
  Future<Map<String, dynamic>?> getSigatokaAuditDetails(int auditId) async {
    try {
      final uri = (await baseUri).replace(path: '${_basePath}/sigatoka/$auditId');
      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('Error al obtener detalles de auditoría Sigatoka: $e');
    }
    return null;
  }

  // Obtener estadísticas de auditorías
  Future<Map<String, dynamic>> getAuditStatistics() async {
    final allAudits = await getAllAudits();

    int totalAudits = allAudits.length;
    int mokoAudits = allAudits.where((a) => a['type'] == 'Moko').length;
    int sigatokaAudits = allAudits.where((a) => a['type'] == 'Sigatoka').length;
    int regularAudits = allAudits.where((a) => a['type'] == 'Regular').length;

    int pendingAudits = allAudits
        .where((a) => a['estado'] == 'PENDIENTE')
        .length;
    int completedAudits = allAudits
        .where((a) => a['estado'] == 'COMPLETADA')
        .length;

    return {
      'total': totalAudits,
      'moko': mokoAudits,
      'sigatoka': sigatokaAudits,
      'regular': regularAudits,
      'pending': pendingAudits,
      'completed': completedAudits,
    };
  }

  // Actualizar estado de auditoría
  Future<bool> updateAuditStatus(
    String type,
    int auditId,
    String newStatus,
  ) async {
    try {
      final base = await baseUri;
      Uri uri;
      switch (type) {
        case 'Moko':
          uri = base.replace(path: '${_basePath}/moko/$auditId/status');
          break;
        case 'Sigatoka':
          uri = base.replace(path: '${_basePath}/sigatoka/$auditId/status');
          break;
        case 'Regular':
          uri = base.replace(path: '${_basePath}/audits/$auditId/status');
          break;
        default:
          return false;
      }

      final response = await http.put(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'estado': newStatus}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error al actualizar estado: $e');
      return false;
    }
  }
}
