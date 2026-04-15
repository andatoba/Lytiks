import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class MokoMuestrasService {
  static const String _host = '5.161.198.89';
  static const int _port = 8081;
  static const String _basePath = '/api/moko/muestras';
  final storage = const FlutterSecureStorage();

  Future<Uri> get baseUri async {
    final savedUrl = await storage.read(key: 'server_url');
    if (savedUrl != null && savedUrl.isNotEmpty) {
      return Uri.parse(savedUrl).replace(path: _basePath);
    }
    return Uri(scheme: 'http', host: _host, port: _port, path: _basePath);
  }

  Future<Map<String, dynamic>> registrarMuestra({
    required int clienteId,
    int? haciendaId,
    int? loteId,
    required String lote,
    required String tipoMuestra,
    required int muestraNumero,
    required String codigo,
    required String descripcion,
    String? fotoPath,
  }) async {
    final base = await baseUri;
    final request = http.MultipartRequest(
      'POST',
      base.replace(path: '${base.path}/registrar'),
    );

    request.fields['clienteId'] = clienteId.toString();
    if (haciendaId != null) {
      request.fields['haciendaId'] = haciendaId.toString();
    }
    if (loteId != null) {
      request.fields['loteId'] = loteId.toString();
    }
    request.fields['lote'] = lote;
    request.fields['tipoMuestra'] = tipoMuestra;
    request.fields['muestraNumero'] = muestraNumero.toString();
    request.fields['codigo'] = codigo;
    request.fields['descripcion'] = descripcion;

    if (fotoPath != null && fotoPath.isNotEmpty) {
      request.files.add(await http.MultipartFile.fromPath('foto', fotoPath));
    }

    final response = await request.send();
    final body = await response.stream.bytesToString();
    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(body) as Map<String, dynamic>;
    }
    throw Exception('Error al registrar muestra: ${response.statusCode} - $body');
  }

  Future<List<Map<String, dynamic>>> getMuestrasByCliente({
    required int clienteId,
    String? lote,
    String? tipo,
    String? query,
  }) async {
    final base = await baseUri;
    final response = await http.get(
      base.replace(
        path: '${base.path}/cliente/$clienteId',
        queryParameters: {
          if (lote != null && lote.isNotEmpty) 'lote': lote,
          if (tipo != null && tipo.isNotEmpty) 'tipo': tipo,
          if (query != null && query.isNotEmpty) 'query': query,
        },
      ),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes)) as List<dynamic>;
      return data.cast<Map<String, dynamic>>();
    }
    throw Exception('Error al cargar muestras: ${response.statusCode}');
  }

  Future<Map<String, dynamic>> cargarResultadoLaboratorio({
    required int muestraId,
    required String resultadoLaboratorio,
    String? documentoPath,
  }) async {
    final base = await baseUri;
    final request = http.MultipartRequest(
      'POST',
      base.replace(path: '${base.path}/$muestraId/laboratorio'),
    );
    request.fields['resultadoLaboratorio'] = resultadoLaboratorio;
    if (documentoPath != null && documentoPath.isNotEmpty) {
      request.files.add(
        await http.MultipartFile.fromPath('documento', documentoPath),
      );
    }

    final response = await request.send();
    final body = await response.stream.bytesToString();
    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(body) as Map<String, dynamic>;
    }
    throw Exception(
      'Error al cargar resultado de laboratorio: ${response.statusCode} - $body',
    );
  }
}
