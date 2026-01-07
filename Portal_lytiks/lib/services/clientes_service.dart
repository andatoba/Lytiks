import 'dart:convert';
import 'package:http/http.dart' as http;

class ClientesService {
  static const String baseUrl = 'http://5.161.198.89:8081/api/clients';

  Future<List<Map<String, dynamic>>> getAllClientes() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/all'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return List<Map<String, dynamic>>.from(data);
      }

      throw Exception('Error al cargar clientes');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Map<String, dynamic>> createCliente(Map<String, dynamic> clientData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/create'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(clientData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      }

      final error = jsonDecode(utf8.decode(response.bodyBytes));
      throw Exception(error['message'] ?? 'Error al crear cliente');
    } catch (e) {
      throw Exception('$e');
    }
  }

  Future<Map<String, dynamic>> updateCliente(int id, Map<String, dynamic> clientData) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/update/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(clientData),
      );

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      }

      final error = jsonDecode(utf8.decode(response.bodyBytes));
      throw Exception(error['message'] ?? 'Error al actualizar cliente');
    } catch (e) {
      throw Exception('$e');
    }
  }
}
