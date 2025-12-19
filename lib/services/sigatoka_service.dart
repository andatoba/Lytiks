import 'dart:convert';
import 'package:http/http.dart' as http;

class SigatokaService {
  // URL base del backend (puerto 8081 con context-path /api)
  static const String baseUrl = 'http://5.161.198.89:8081/api/sigatoka';

  Future<Map<String, dynamic>> crearEvaluacion(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/evaluacion'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> agregarMuestra(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/muestra'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> obtenerEvaluacion(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/evaluacion/$id'));
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> obtenerResultados(int evaluacionId) async {
    final response = await http.get(Uri.parse('$baseUrl/resultados/$evaluacionId'));
    return jsonDecode(response.body);
  }
}



