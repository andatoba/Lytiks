import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class MokoCapacitacionesService {
  static const String _host = '5.161.198.89';
  static const int _port = 8081;
  static const String _basePath = '/api/moko/capacitaciones';
  final storage = const FlutterSecureStorage();

  Future<Uri> get baseUri async {
    final savedUrl = await storage.read(key: 'server_url');
    if (savedUrl != null && savedUrl.isNotEmpty) {
      return Uri.parse(savedUrl).replace(path: _basePath);
    }
    return Uri(scheme: 'http', host: _host, port: _port, path: _basePath);
  }

  Future<Map<String, dynamic>> registrarCapacitacion({
    required int clienteId,
    int? haciendaId,
    int? loteId,
    String? hacienda,
    required String lote,
    required String tema,
    required String descripcion,
    required int participantes,
    required List<String> fotos,
  }) async {
    final base = await baseUri;
    final request = http.MultipartRequest(
      'POST',
      base.replace(path: '${base.path}/registrar'),
    );
    request.fields['clienteId'] = clienteId.toString();
    if (haciendaId != null) request.fields['haciendaId'] = haciendaId.toString();
    if (loteId != null) request.fields['loteId'] = loteId.toString();
    if (hacienda != null && hacienda.isNotEmpty) {
      request.fields['hacienda'] = hacienda;
    }
    request.fields['lote'] = lote;
    request.fields['tema'] = tema;
    request.fields['descripcion'] = descripcion;
    request.fields['participantes'] = participantes.toString();

    for (final foto in fotos) {
      if (foto.isNotEmpty) {
        request.files.add(await http.MultipartFile.fromPath('fotos', foto));
      }
    }

    final response = await request.send();
    final body = await response.stream.bytesToString();
    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(body) as Map<String, dynamic>;
    }
    throw Exception('Error al registrar capacitación: ${response.statusCode} - $body');
  }

  Future<List<Map<String, dynamic>>> getCapacitacionesByCliente({
    required int clienteId,
    String? hacienda,
    String? lote,
  }) async {
    final base = await baseUri;
    final response = await http.get(
      base.replace(
        path: '${base.path}/cliente/$clienteId',
        queryParameters: {
          if (hacienda != null && hacienda.isNotEmpty) 'hacienda': hacienda,
          if (lote != null && lote.isNotEmpty) 'lote': lote,
        },
      ),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes)) as List<dynamic>;
      return data.cast<Map<String, dynamic>>();
    }
    throw Exception('Error al cargar capacitaciones: ${response.statusCode}');
  }

  Future<int> countCapacitacionesByCliente({
    required int clienteId,
    String? hacienda,
    String? lote,
  }) async {
    final base = await baseUri;
    final response = await http.get(
      base.replace(
        path: '${base.path}/cliente/$clienteId/count',
        queryParameters: {
          if (hacienda != null && hacienda.isNotEmpty) 'hacienda': hacienda,
          if (lote != null && lote.isNotEmpty) 'lote': lote,
        },
      ),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes))
          as Map<String, dynamic>;
      return (data['count'] as num?)?.toInt() ?? 0;
    }
    throw Exception('Error al contar capacitaciones: ${response.statusCode}');
  }
}
