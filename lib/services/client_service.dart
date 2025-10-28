import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ClientService {
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

  // Buscar cliente por cédula para autocompletado
  Future<Map<String, dynamic>> searchClientByCedula(String cedula) async {
    try {
      final headers = await _getHeaders();
      final url = await baseUrl;

      final response = await http.get(
        Uri.parse('$url/clients/search/cedula/$cedula'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Token expirado. Por favor, inicia sesión nuevamente.');
      } else {
        // En caso de error, retornar que no se encontró
        return {'found': false, 'message': 'Cliente no encontrado'};
      }
    } catch (e) {
      // En caso de error de conexión
      return {'found': false, 'error': 'Error de conexión: $e'};
    }
  }

  // Crear un nuevo cliente con mapa de datos
  Future<Map<String, dynamic>> createClient(
    Map<String, dynamic> clientData,
  ) async {
    try {
      final headers = await _getHeaders();
      final url = await baseUrl;

      final response = await http.post(
        Uri.parse('$url/clients/create'),
        headers: headers,
        body: json.encode(clientData),
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
      final url = await baseUrl;
      final response = await http.post(
        Uri.parse('$url/clients'),
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
      final url = await baseUrl;
      final response = await http.get(
        Uri.parse('$url/clients'),
        headers: headers,
      );

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
      final url = await baseUrl;
      final response = await http.get(
        Uri.parse('$url/clients/$id'),
        headers: headers,
      );

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

  // Actualizar un cliente
  Future<Map<String, dynamic>> updateClient({
    required int id,
    required String name,
    required String email,
    required String phone,
    required String address,
    String? company,
  }) async {
    try {
      final headers = await _getHeaders();
      final url = await baseUrl;
      final response = await http.put(
        Uri.parse('$url/clients/$id'),
        headers: headers,
        body: json.encode({
          'id': id,
          'name': name,
          'email': email,
          'phone': phone,
          'address': address,
          'company': company,
        }),
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
      final url = await baseUrl;
      final response = await http.delete(
        Uri.parse('$url/clients/$id'),
        headers: headers,
      );

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
}
