import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class RegistroMokoService {
  static const String _host = '5.161.198.89';
  static const int _port = 8081;
  static const String _basePath = '/api/moko';
  final storage = const FlutterSecureStorage();

  Future<Uri> get baseUri async {
    final savedUrl = await storage.read(key: 'server_url');
    if (savedUrl != null && savedUrl.isNotEmpty) {
      return Uri.parse(savedUrl).replace(path: _basePath);
    }
    return Uri(scheme: 'http', host: _host, port: _port, path: _basePath);
  }

  // Obtener el próximo número de foco secuencial
  Future<int> getNextFocoNumber() async {
    try {
      final base = await baseUri;
      final response = await http.get(
        base.replace(path: '${base.path}/next-foco-number'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['nextNumber'] ?? 1;
      } else {
        throw Exception(
          'Error al obtener número de foco: ${response.statusCode}',
        );
      }
    } catch (e) {
      // En caso de error, devolver 1 como número por defecto
      return 1;
    }
  }

  // Obtener lista de síntomas desde la base de datos
  Future<List<Map<String, dynamic>>> getSintomas() async {
    try {
      final base = await baseUri;
      final response = await http.get(
        base.replace(path: '${base.path}/sintomas'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Error al obtener síntomas: ${response.statusCode}');
      }
    } catch (e) {
      // Datos de fallback en caso de error de conexión
      return [
        {
          'id': 1,
          'categoria': 'Externo',
          'sintoma_observable': 'Amarillamiento de hojas bajas',
          'descripcion_tecnica':
              'Primeras hojas muestran amarillamiento desde el borde hacia el centro.',
          'severidad': 'Bajo',
        },
        {
          'id': 2,
          'categoria': 'Externo',
          'sintoma_observable': 'Marchitez o colapso de hojas',
          'descripcion_tecnica':
              'Las hojas se doblan en forma de "paraguas"; planta pierde turgencia rápidamente.',
          'severidad': 'Medio',
        },
        {
          'id': 3,
          'categoria': 'Externo',
          'sintoma_observable': 'Muerte apical / pseudotallo blando',
          'descripcion_tecnica':
              'La parte superior del pseudotallo se ablanda, colapsa o presenta exudado.',
          'severidad': 'Alto',
        },
      ];
    }
  }

  // Guardar el registro de moko
  Future<Map<String, dynamic>> guardarRegistro(
    Map<String, dynamic> registroData,
    File? foto,
  ) async {
    try {
      final base = await baseUri;
      var request = http.MultipartRequest(
        'POST',
        base.replace(path: '${base.path}/registrar'),
      );

      // Agregar campos del formulario
      request.fields['numeroFoco'] = registroData['numeroFoco'].toString();
      request.fields['clienteId'] = registroData['clienteId'].toString();
      request.fields['gpsCoordinates'] = registroData['gpsCoordinates'] ?? '';
      request.fields['plantasAfectadas'] = registroData['plantasAfectadas']
          .toString();
      request.fields['fechaDeteccion'] = registroData['fechaDeteccion'];
      request.fields['sintomaId'] = registroData['sintomaId'].toString();
      request.fields['severidad'] = registroData['severidad'] ?? '';
      request.fields['metodoComprobacion'] =
          registroData['metodoComprobacion'] ?? '';
      request.fields['observaciones'] = registroData['observaciones'] ?? '';

      // Agregar foto si existe
      if (foto != null) {
        var stream = http.ByteStream(foto.openRead());
        var length = await foto.length();
        var multipartFile = http.MultipartFile(
          'foto',
          stream,
          length,
          filename: path.basename(foto.path),
        );
        request.files.add(multipartFile);
      }

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(responseData);
      } else {
        throw Exception(
          'Error al guardar registro: ${response.statusCode} - $responseData',
        );
      }
    } catch (e) {
      throw Exception('Error de conexión al guardar registro: $e');
    }
  }

  // Obtener lista de registros de moko (para la pantalla de lista)
  Future<List<Map<String, dynamic>>> getRegistros() async {
    try {
      final base = await baseUri;
      final response = await http.get(
        base.replace(path: '${base.path}/registros'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Error al obtener registros: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener un registro específico por ID
  Future<Map<String, dynamic>> getRegistroById(int id) async {
    try {
      final base = await baseUri;
      final response = await http.get(
        base.replace(path: '${base.path}/registro/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al obtener registro: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Actualizar un registro existente
  Future<Map<String, dynamic>> actualizarRegistro(
    int id,
    Map<String, dynamic> registroData,
    File? foto,
  ) async {
    try {
      final base = await baseUri;
      var request = http.MultipartRequest(
        'PUT',
        base.replace(path: '${base.path}/registro/$id'),
      );

      // Agregar campos del formulario
      request.fields['gpsCoordinates'] = registroData['gpsCoordinates'] ?? '';
      request.fields['plantasAfectadas'] = registroData['plantasAfectadas']
          .toString();
      request.fields['sintomaId'] = registroData['sintomaId'].toString();
      request.fields['severidad'] = registroData['severidad'] ?? '';
      request.fields['metodoComprobacion'] =
          registroData['metodoComprobacion'] ?? '';
      request.fields['observaciones'] = registroData['observaciones'] ?? '';

      // Agregar foto si existe
      if (foto != null) {
        var stream = http.ByteStream(foto.openRead());
        var length = await foto.length();
        var multipartFile = http.MultipartFile(
          'foto',
          stream,
          length,
          filename: path.basename(foto.path),
        );
        request.files.add(multipartFile);
      }

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return json.decode(responseData);
      } else {
        throw Exception(
          'Error al actualizar registro: ${response.statusCode} - $responseData',
        );
      }
    } catch (e) {
      throw Exception('Error de conexión al actualizar registro: $e');
    }
  }
}
