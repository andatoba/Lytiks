import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class RegistroMokoService {
  static const String _host = '5.161.198.89'; // IP del servidor remoto
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
      print(
          '🔗 Cargando síntomas desde: ${base.replace(path: '${base.path}/sintomas')}');

      final response = await http.get(
        base.replace(path: '${base.path}/sintomas'),
        headers: {'Content-Type': 'application/json'},
      );

      print('📥 Respuesta síntomas: ${response.statusCode}');
      print('📋 Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('✅ Síntomas parseados: ${data.length} encontrados');
        for (var sintoma in data) {
          print(
              '  - ${sintoma['id']}: ${sintoma['sintomaObservable']} (${sintoma['severidad']})');
        }
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Error al obtener síntomas: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ ERROR cargando síntomas: $e');
      // Datos de fallback en caso de error de conexión
      return [
        {
          'id': 1,
          'categoria': 'Externo',
          'sintomaObservable': 'Amarillamiento de hojas bajas',
          'descripcionTecnica':
              'Primeras hojas muestran amarillamiento desde el borde hacia el centro.',
          'severidad': 'Bajo',
        },
        {
          'id': 2,
          'categoria': 'Externo',
          'sintomaObservable': 'Marchitez o colapso de hojas',
          'descripcionTecnica':
              'Las hojas se doblan en forma de "paraguas"; planta pierde turgencia rápidamente.',
          'severidad': 'Medio',
        },
        {
          'id': 3,
          'categoria': 'Externo',
          'sintomaObservable': 'Muerte apical / pseudotallo blando',
          'descripcionTecnica':
              'La parte superior del pseudotallo se ablanda, colapsa o presenta exudado.',
          'severidad': 'Alto',
        },
      ];
    }
  }

  // Obtener lista de productos de contención desde el backend
  Future<List<Map<String, dynamic>>> getProductos() async {
    try {
      final base = await baseUri;
      print(
          '🔗 Cargando productos desde: ${base.replace(path: '${base.path}/productos-contencion')}');

      final response = await http.get(
        base.replace(path: '${base.path}/productos-contencion'),
        headers: {'Content-Type': 'application/json'},
      );

      print('📥 Respuesta productos: ${response.statusCode}');
      print('📋 Body productos: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('✅ Productos parseados: ${data.length} encontrados');
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Error al obtener productos: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ ERROR cargando productos: $e');
      // Fallback vacío
      return [];
    }
  }

  // Guardar aplicación de producto
  Future<Map<String, dynamic>> postAplicacion(
      Map<String, dynamic> aplicacionData) async {
    try {
      final base = await baseUri;
      print(
          '🔗 Guardando aplicación en: ${base.replace(path: '${base.path}/aplicaciones-contencion')}');

      final response = await http.post(
        base.replace(path: '${base.path}/aplicaciones-contencion'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(aplicacionData),
      );

      print('📥 Respuesta aplicación: ${response.statusCode}');
      print('📋 Body aplicación: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al guardar aplicación: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ ERROR guardando aplicación: $e');
      throw Exception('Error de conexión al guardar aplicación: $e');
    }
  }

  // Guardar contención completa (aplicaciones + seguimiento)
  Future<Map<String, dynamic>> guardarContencionCompleta(
    Map<String, dynamic> payload,
  ) async {
    try {
      final base = await baseUri;
      final response = await http.post(
        base.replace(path: '${base.path}/contencion/guardar-completo'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      }

      throw Exception(
        'Error al guardar contención completa: ${response.statusCode} - ${response.body}',
      );
    } catch (e) {
      throw Exception('Error de conexión al guardar contención completa: $e');
    }
  }

  // Guardar el registro de moko
  Future<Map<String, dynamic>> guardarRegistro(
    Map<String, dynamic> registroData,
    File? foto,
  ) async {
    try {
      final base = await baseUri;
      print(
          '🔗 Intentando conectar a: ${base.replace(path: '${base.path}/registrar')}');

      var request = http.MultipartRequest(
        'POST',
        base.replace(path: '${base.path}/registrar'),
      );

      // Agregar campos del formulario
      request.fields['numeroFoco'] = registroData['numeroFoco'].toString();
      request.fields['clienteId'] = registroData['clienteId'].toString();
      request.fields['lote'] = registroData['lote'] ?? '';
      request.fields['areaHectareas'] =
          registroData['areaHectareas'].toString();
      request.fields['gpsCoordinates'] = registroData['gpsCoordinates'] ?? '';
      if (registroData['loteLatitud'] != null) {
        request.fields['loteLatitud'] = registroData['loteLatitud'].toString();
      }
      if (registroData['loteLongitud'] != null) {
        request.fields['loteLongitud'] =
            registroData['loteLongitud'].toString();
      }
      request.fields['plantasAfectadas'] =
          registroData['plantasAfectadas'].toString();
      request.fields['fechaDeteccion'] = registroData['fechaDeteccion'];

      // Enviar síntomas múltiples como JSON
      if (registroData.containsKey('sintomasIds')) {
        request.fields['sintomasIds'] =
            json.encode(registroData['sintomasIds']);
        request.fields['sintomasDetalles'] =
            json.encode(registroData['sintomasDetalles']);
      } else if (registroData.containsKey('sintomaId')) {
        // Backward compatibility
        request.fields['sintomaId'] = registroData['sintomaId'].toString();
      }

      request.fields['severidad'] = registroData['severidad'] ?? '';
      request.fields['metodoComprobacion'] =
          registroData['metodoComprobacion'] ?? '';
      request.fields['observaciones'] = registroData['observaciones'] ?? '';

      print('📝 Datos a enviar: ${request.fields}');

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
        print('📸 Foto agregada: ${foto.path}');
      }

      // Enviar con timeout
      var response = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception(
              'Timeout: El servidor no responde después de 30 segundos. Verifica tu conexión a internet y que el servidor ${_host}:${_port} esté accesible.');
        },
      );

      var responseData = await response.stream.bytesToString();
      print(
          '📥 Respuesta del servidor: ${response.statusCode} - $responseData');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(responseData);
      } else {
        throw Exception(
          'Error HTTP ${response.statusCode}: $responseData',
        );
      }
    } on TimeoutException catch (e) {
      throw Exception(
          'El servidor tardó demasiado en responder. Intenta nuevamente. Error: $e');
    } on SocketException catch (e) {
      throw Exception(
          'No se puede conectar al servidor ${_host}:${_port}. Verifica que:\n1. Tengas conexión a internet\n2. El servidor esté ejecutándose\n3. No haya firewall bloqueando el puerto 8081\n\nError técnico: $e');
    } catch (e) {
      if (e.toString().contains('Failed to fetch')) {
        throw Exception(
            'Error de red: No se puede alcanzar el servidor ${_host}:${_port}. Verifica tu conexión a internet.');
      }
      throw Exception('Error inesperado: $e');
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
      request.fields['plantasAfectadas'] =
          registroData['plantasAfectadas'].toString();
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

  // Inicializar productos en el backend
  Future<Map<String, dynamic>> initProductos() async {
    try {
      final base = await baseUri;
      final response = await http.post(
        base.replace(path: '${base.path}/init-productos'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
            'Error al inicializar productos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión al inicializar productos: $e');
    }
  }

  // Obtener seguimiento de aplicación
  Future<Map<String, dynamic>> getSeguimiento(int aplicacionId) async {
    try {
      final base = await baseUri;
      final response = await http.get(
        base.replace(path: '${base.path}/seguimiento/$aplicacionId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al obtener seguimiento: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión al obtener seguimiento: $e');
    }
  }

  // Marcar aplicación como completada
  Future<Map<String, dynamic>> marcarCompletada(
    int seguimientoId, {
    String? observaciones,
    File? foto,
  }) async {
    try {
      final base = await baseUri;
      var request = http.MultipartRequest(
        'POST',
        base.replace(path: '${base.path}/seguimiento/$seguimientoId/completar'),
      );

      if (observaciones != null) {
        request.fields['observaciones'] = observaciones;
      }

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
            'Error al marcar completada: ${response.statusCode} - $responseData');
      }
    } catch (e) {
      throw Exception('Error de conexión al marcar completada: $e');
    }
  }

  // Reprogramar aplicación
  Future<Map<String, dynamic>> reprogramarAplicacion(
    int seguimientoId,
    DateTime nuevaFecha,
    String nuevaHora,
  ) async {
    try {
      final base = await baseUri;
      final response = await http.post(
        base.replace(
            path: '${base.path}/seguimiento/$seguimientoId/reprogramar'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'nuevaFecha': nuevaFecha.toIso8601String(),
          'nuevaHora': nuevaHora,
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al reprogramar: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión al reprogramar: $e');
    }
  }
}
