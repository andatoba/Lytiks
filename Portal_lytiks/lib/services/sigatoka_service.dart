import 'dart:convert';
import 'package:http/http.dart' as http;

class SigatokaService {
  final String baseUrl = 'http://5.161.198.89:8081/api/sigatoka';

  Future<Map<String, dynamic>> crearEvaluacion(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/crear-evaluacion'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
      } else {
        return {
          'success': false,
          'error': 'Error ${response.statusCode}: ${response.body}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Error de conexión: $e',
      };
    }
  }

  Future<Map<String, dynamic>> obtenerEvaluaciones() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/evaluaciones'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
      } else {
        return {
          'success': false,
          'error': 'Error ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Error de conexión: $e',
      };
    }
  }

  Future<Map<String, dynamic>> agregarMuestras(int evaluacionId, List<Map<String, dynamic>> muestras) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$evaluacionId/muestras'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'muestras': muestras}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
      } else {
        return {
          'success': false,
          'error': 'Error ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Error de conexión: $e',
      };
    }
  }
}
