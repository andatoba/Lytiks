import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ClientService {
  static const String _host = '5.161.198.89';
  static const int _port = 8081;
  static const String _basePath = '/api';

  final storage = const FlutterSecureStorage();
  static const String _selectedClientKey = 'selected_client';

  // Verificar si hay token válido
  Future<bool> hasValidToken() async {
    final token = await storage.read(key: 'token');
    return token != null && token.isNotEmpty;
  }

  Future<Uri> get baseUri async {
    return Uri(scheme: 'http', host: _host, port: _port, path: _basePath);
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await storage.read(key: 'token');

    print('\n🔐 Obteniendo headers para la petición:');
    print('Token almacenado completo: $token');

    if (token == null || token.isEmpty) {
      print('❌ No se encontró token de autenticación');
      throw Exception(
        'No hay token de autenticación. Por favor inicie sesión nuevamente.',
      );
    }

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    print('📤 Headers completos que se enviarán:');
    headers.forEach((key, value) => print('  $key: $value'));

    return headers;
  }

  // Buscar cliente por cédula para autocompletado
  // Verificar disponibilidad del servidor
  Future<bool> _checkServerAvailability() async {
    try {
      final baseURL = await baseUri;
      final uri = Uri(
        scheme: baseURL.scheme,
        host: baseURL.host,
        port: baseURL.port,
        path: '$_basePath/health',
      );
      print('🌐 Verificando disponibilidad del servidor en: ${uri.toString()}');
      final response = await http.get(uri).timeout(const Duration(seconds: 5));
      print('📡 Respuesta health check: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Error en health check: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> searchClientByCedula(String cedula) async {
    try {
      print('\n🔍 Iniciando búsqueda de cliente por cédula: $cedula');

      final headers = await _getHeaders();
      final uri = (await baseUri).replace(
        path: '$_basePath/clients/search/cedula/$cedula',
      );

      print('🌐 URL completa de búsqueda: ${uri.toString()}');

      print('\n🔍 Iniciando búsqueda de cliente');
      print('🔍 Cédula: $cedula');
      print('🌐 URL completa: ${uri.toString()}');
      print('🔐 Headers completos: $headers');
      print('🌍 URI parseada: ${uri.toString()}');
      print('   - Scheme: ${uri.scheme}');
      print('   - Host: ${uri.host}');
      print('   - Port: ${uri.port}');
      print('   - Path: ${uri.path}');

      // Intentar la conexión con un timeout más largo para redes lentas
      final response = await http
          .get(uri, headers: headers)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception(
                'La conexión está tomando demasiado tiempo. Verifica tu conexión a internet.',
              );
            },
          );

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      print('\n📥 Respuesta del servidor:');
      print('   - Status code: ${response.statusCode}');
      print('   - Headers: ${response.headers}');
      print('   - Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('✅ Cliente encontrado: $responseData');

        // Si la respuesta contiene un error, retornar null
        if (responseData.containsKey('error')) {
          print('❌ Error del servidor: ${responseData['error']}');
          return null;
        }

        // La respuesta ahora contiene directamente los datos del cliente
        return responseData;
      } else if (response.statusCode == 401) {
        print('❌ Error 401: Token expirado');
        throw Exception('Token expirado. Por favor, inicia sesión nuevamente.');
      } else if (response.statusCode == 404) {
        print('❌ Error 404: Cliente no encontrado');
        return null;
      } else {
        print('❌ Error ${response.statusCode}: ${response.body}');
        throw Exception('Error al buscar cliente: ${response.body}');
      }
    } catch (e) {
      print('\n❌ Error detallado:');
      print('   Tipo de error: ${e.runtimeType}');
      print('   Mensaje: $e');

      if (e.toString().contains('TimeoutException')) {
        throw Exception(
          'Tiempo de espera agotado. Por favor, inténtelo nuevamente.',
        );
      } else if (e.toString().contains('SocketException')) {
        throw Exception(
          'No se puede conectar al servidor. Verifica tu conexión a internet y que el servidor esté disponible.',
        );
      } else if (e.toString().contains('HandshakeException')) {
        throw Exception(
          'Error de seguridad en la conexión. Verifica la configuración SSL del servidor.',
        );
      } else if (e.toString().contains('Certificate')) {
        throw Exception('Error de certificado SSL. La conexión no es segura.');
      }

      throw Exception('Error de conexión: $e');
    }
  }

  Future<Map<String, dynamic>?> searchClientByEmail(String email) async {
    try {
      print('\n🔍 Iniciando búsqueda de cliente por email: $email');

      final headers = await _getHeaders();
      final encodedEmail = Uri.encodeComponent(email.trim());
      final uri = (await baseUri).replace(
        path: '$_basePath/clients/search/email/$encodedEmail',
      );

      print('🌐 URL completa de búsqueda: ${uri.toString()}');

      final response = await http
          .get(uri, headers: headers)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception(
                'La conexión está tomando demasiado tiempo. Verifica tu conexión a internet.',
              );
            },
          );

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData is Map && responseData.containsKey('error')) {
          return null;
        }
        return Map<String, dynamic>.from(responseData as Map);
      } else if (response.statusCode == 401) {
        throw Exception('Token expirado. Por favor, inicia sesión nuevamente.');
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Error al buscar cliente: ${response.body}');
      }
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception(
          'Tiempo de espera agotado. Por favor, inténtelo nuevamente.',
        );
      } else if (e.toString().contains('SocketException')) {
        throw Exception(
          'No se puede conectar al servidor. Verifica tu conexión a internet y que el servidor esté disponible.',
        );
      }
      throw Exception('Error de conexión: $e');
    }
  }

  Future<List<Map<String, dynamic>>> searchClientsByName(String nombre) async {
    try {
      print('\n🔍 Iniciando búsqueda de clientes por nombre: $nombre');

      final trimmed = nombre.trim();
      if (RegExp(r'^[0-9]+$').hasMatch(trimmed)) {
        final client = await searchClientByCedula(trimmed);
        return client == null ? [] : [client];
      }

      final headers = await _getHeaders();
      final encodedName = Uri.encodeComponent(trimmed);
      final uri = (await baseUri).replace(
        path: '$_basePath/clients/search/name/$encodedName',
      );

      print('🌐 URL completa de búsqueda: ${uri.toString()}');

      final response = await http
          .get(uri, headers: headers)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception(
                'La conexión está tomando demasiado tiempo. Verifica tu conexión a internet.',
              );
            },
          );

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData is List) {
          return responseData
              .map((item) => Map<String, dynamic>.from(item as Map))
              .toList();
        }
        return [];
      } else if (response.statusCode == 401) {
        throw Exception('Token expirado. Por favor, inicia sesión nuevamente.');
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception('Error al buscar clientes: ${response.body}');
      }
    } catch (e) {
      print('\n❌ Error detallado:');
      print('   Tipo de error: ${e.runtimeType}');
      print('   Mensaje: $e');

      if (e.toString().contains('TimeoutException')) {
        throw Exception(
          'Tiempo de espera agotado. Por favor, inténtelo nuevamente.',
        );
      } else if (e.toString().contains('SocketException')) {
        throw Exception(
          'No se puede conectar al servidor. Verifica tu conexión a internet y que el servidor esté disponible.',
        );
      } else if (e.toString().contains('HandshakeException')) {
        throw Exception(
          'Error de seguridad en la conexión. Verifica la configuración SSL del servidor.',
        );
      } else if (e.toString().contains('Certificate')) {
        throw Exception('Error de certificado SSL. La conexión no es segura.');
      }

      throw Exception('Error de conexión: $e');
    }
  }

  // Crear un nuevo cliente con mapa de datos
  Future<Map<String, dynamic>> createClient(
    Map<String, dynamic> clientData,
  ) async {
    try {
      final headers = await _getHeaders();
      final uri = (await baseUri).replace(path: '${_basePath}/clients/create');

      // Asegurar tipos de datos correctos antes de enviar
      final sanitizedData = {
        'cedula': clientData['cedula']?.toString(),
        'nombre': clientData['nombre']?.toString(),
        'apellidos': clientData['apellidos']?.toString(),
        'telefono': clientData['telefono']?.toString(),
        'email': clientData['email']?.toString(),
        'direccion': clientData['direccion']?.toString(),
        'parroquia': clientData['parroquia']?.toString(),
        'fincaNombre': clientData['fincaNombre']?.toString(),
        'fincaHectareas': clientData['fincaHectareas'] != null
            ? double.tryParse(clientData['fincaHectareas'].toString())
            : null,
        'cultivosPrincipales': clientData['cultivosPrincipales']?.toString(),
        'geolocalizacionLat': clientData['geolocalizacionLat'] != null
            ? double.parse(clientData['geolocalizacionLat'].toString())
            : null,
        'geolocalizacionLng': clientData['geolocalizacionLng'] != null
            ? double.parse(clientData['geolocalizacionLng'].toString())
            : null,
        'observaciones': clientData['observaciones']?.toString(),
        'tecnicoAsignadoId': clientData['tecnicoAsignadoId'] != null
            ? int.parse(clientData['tecnicoAsignadoId'].toString())
            : null,
      };

      print('📤 Datos sanitizados que se enviarán al servidor:');
      sanitizedData.forEach(
        (key, value) => print('  $key: $value (${value?.runtimeType})'),
      );

      final response = await http.post(
        uri,
        headers: headers,
        body: json.encode(sanitizedData),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Token expirado. Por favor, inicia sesión nuevamente.');
      } else {
        return {
          'success': false,
          'message': 'Error al crear cliente: ${response.body}',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }

  // Crear un nuevo cliente (método original para compatibilidad)
  Future<Map<String, dynamic>> createClientLegacy({
    required String name,
    required String email,
    required String phone,
    required String address,
    String? company,
  }) async {
    try {
      final headers = await _getHeaders();
      final uri = (await baseUri).replace(path: '${_basePath}/clients');
      final response = await http.post(
        uri,
        headers: headers,
        body: json.encode({
          'name': name,
          'email': email,
          'phone': phone,
          'address': address,
          'company': company,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Token expirado. Por favor, inicia sesión nuevamente.');
      } else {
        throw Exception('Error al crear cliente: ${response.body}');
      }
    } catch (e) {
      if (e.toString().contains('SocketException')) {
        throw Exception('No se puede conectar al servidor.');
      }
      rethrow;
    }
  }

  // Obtener todos los clientes
  Future<List<Map<String, dynamic>>> getClients() async {
    try {
      final headers = await _getHeaders();
      final uri = (await baseUri).replace(path: '${_basePath}/clients');
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> clientsJson = json.decode(response.body);
        return clientsJson.cast<Map<String, dynamic>>();
      } else if (response.statusCode == 401) {
        throw Exception('Token expirado. Por favor, inicia sesión nuevamente.');
      } else {
        throw Exception('Error al obtener clientes: ${response.body}');
      }
    } catch (e) {
      if (e.toString().contains('SocketException')) {
        throw Exception('No se puede conectar al servidor.');
      }
      rethrow;
    }
  }

  // Obtener un cliente por ID
  Future<Map<String, dynamic>> getClientById(int id) async {
    try {
      final headers = await _getHeaders();
      final uri = (await baseUri).replace(path: '${_basePath}/clients/$id');
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Token expirado. Por favor, inicia sesión nuevamente.');
      } else if (response.statusCode == 404) {
        throw Exception('Cliente no encontrado.');
      } else {
        throw Exception('Error al obtener cliente: ${response.body}');
      }
    } catch (e) {
      if (e.toString().contains('SocketException')) {
        throw Exception('No se puede conectar al servidor.');
      }
      rethrow;
    }
  }

  // Actualizar un cliente (PUT con JSON completo)
  Future<Map<String, dynamic>> updateClient({
    required int id,
    required Map<String, dynamic> clientData,
  }) async {
    try {
      final headers = await _getHeaders();
      final uri = (await baseUri).replace(
        path: '${_basePath}/clients/update/$id',
      );
      final response = await http.put(
        uri,
        headers: headers,
        body: json.encode(clientData),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Token expirado. Por favor, inicia sesión nuevamente.');
      } else if (response.statusCode == 404) {
        throw Exception('Cliente no encontrado.');
      } else {
        throw Exception('Error al actualizar cliente: ${response.body}');
      }
    } catch (e) {
      if (e.toString().contains('SocketException')) {
        throw Exception('No se puede conectar al servidor.');
      }
      rethrow;
    }
  }

  // Eliminar un cliente
  Future<void> deleteClient(int id) async {
    try {
      final headers = await _getHeaders();
      final uri = (await baseUri).replace(path: '${_basePath}/clients/$id');
      final response = await http.delete(uri, headers: headers);

      if (response.statusCode == 401) {
        throw Exception('Token expirado. Por favor, inicia sesión nuevamente.');
      } else if (response.statusCode == 404) {
        throw Exception('Cliente no encontrado.');
      } else if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('Error al eliminar cliente: ${response.body}');
      }
    } catch (e) {
      if (e.toString().contains('SocketException')) {
        throw Exception('No se puede conectar al servidor.');
      }
      rethrow;
    }
  }

  Future<void> saveSelectedClient(Map<String, dynamic> client) async {
    try {
      await storage.write(key: _selectedClientKey, value: json.encode(client));
    } catch (_) {}
  }

  Future<Map<String, dynamic>?> getSelectedClient() async {
    try {
      final data = await storage.read(key: _selectedClientKey);
      if (data == null || data.isEmpty) {
        return null;
      }
      final decoded = json.decode(data);
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } catch (_) {}
    return null;
  }

  Future<void> clearSelectedClient() async {
    try {
      await storage.delete(key: _selectedClientKey);
    } catch (_) {}
  }
  
  // Obtener evaluaciones Sigatoka de un cliente
  Future<List<Map<String, dynamic>>> getEvaluacionesSigatokaByCliente(int clienteId) async {
    try {
      final headers = await _getHeaders();
      final uri = (await baseUri).replace(
        path: '$_basePath/sigatoka/cliente/$clienteId',
      );
      
      final response = await http.get(uri, headers: headers).timeout(
        const Duration(seconds: 15),
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('Error obteniendo evaluaciones Sigatoka: $e');
      return [];
    }
  }
  
  // Obtener evaluaciones Moko de un cliente
  Future<List<Map<String, dynamic>>> getEvaluacionesMokoByCliente(int clienteId) async {
    try {
      final headers = await _getHeaders();
      final uri = (await baseUri).replace(
        path: '$_basePath/moko/registros/cliente/$clienteId',
      );
      
      final response = await http.get(uri, headers: headers).timeout(
        const Duration(seconds: 15),
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('Error obteniendo evaluaciones Moko: $e');
      return [];
    }
  }
  
  // Obtener auditorías de campo de un cliente
  Future<List<Map<String, dynamic>>> getAuditoriasByCliente(int clienteId) async {
    try {
      final headers = await _getHeaders();
      final uri = (await baseUri).replace(
        path: '$_basePath/audits/cliente/$clienteId',
      );
      
      final response = await http.get(uri, headers: headers).timeout(
        const Duration(seconds: 15),
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('Error obteniendo auditorías: $e');
      return [];
    }
  }
}
