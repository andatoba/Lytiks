import 'dart:convert';
import 'package:http/http.dart' as http;

class IsUsuariosService {
  final String baseUrl = 'http://5.161.198.89:8081/api/is-usuarios';

  // Obtener todos los usuarios
  Future<List<Map<String, dynamic>>> getAllUsuarios() async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Error al cargar usuarios');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener usuario por ID
  Future<Map<String, dynamic>> getUsuarioById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('Usuario no encontrado');
      }
    } catch (e) {
      throw Exception('Error al cargar usuario: $e');
    }
  }

  // Crear nuevo usuario
  Future<Map<String, dynamic>> createUsuario(Map<String, dynamic> userData) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userData),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Error al crear usuario');
      }
    } catch (e) {
      throw Exception('$e');
    }
  }

  // Actualizar usuario
  Future<void> updateUsuario(int id, Map<String, dynamic> userData) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userData),
      );

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Error al actualizar usuario');
      }
    } catch (e) {
      throw Exception('$e');
    }
  }

  // Cambiar estado del usuario
  Future<void> cambiarEstado(int id, String estado) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/$id/estado'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'estado': estado,
          'usuario_actual': 'ADMIN',
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Error al cambiar estado');
      }
    } catch (e) {
      throw Exception('$e');
    }
  }

  // Cambiar acceso a app móvil
  Future<void> cambiarAccesoApp(int id, bool accesoApp) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/$id/acceso-app'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'acceso_app_movil': accesoApp,
          'usuario_actual': 'ADMIN',
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Error al cambiar acceso a app');
      }
    } catch (e) {
      throw Exception('$e');
    }
  }

  // Resetear contraseña
  Future<void> resetPassword(int id, String newPassword) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/$id/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'password': newPassword,
          'usuario_actual': 'ADMIN',
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Error al resetear contraseña');
      }
    } catch (e) {
      throw Exception('$e');
    }
  }

  // Obtener roles
  Future<List<Map<String, dynamic>>> getRoles() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/roles'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Error al cargar roles');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}
