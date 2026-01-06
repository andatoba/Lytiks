import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/aes_encryption.dart';

class AuthService {
  static const String baseUrl = 'http://5.161.198.89:8081';

  Future<Map<String, dynamic>> login(String usuario, String password) async {
    try {
      // Encriptar la contraseña con AES
      final encryptedPassword = AESEncryption.encryptPassword(password);
      
      final body = jsonEncode({
        'username': usuario,
        'password': encryptedPassword,
      });
      
      print('=== LOGIN DEBUG ===');
      print('URL: $baseUrl/api/auth/login');
      print('Body: $body');

      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: body,
      );
      
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${utf8.decode(response.bodyBytes)}');

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        
        // Validar que el usuario tenga rol ADMINISTRADOR
        final userRole = data['user']?['rol']?.toString().toUpperCase() ?? '';
        print('Rol del usuario: $userRole');
        
        if (userRole != 'ADMINISTRADOR') {
          return {
            'success': false,
            'message': 'Acceso denegado. Solo usuarios con rol ADMINISTRADOR pueden acceder al portal.',
          };
        }
        
        return {
          'success': true,
          'data': data,
          'message': 'Inicio de sesión exitoso',
        };
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Usuario o contraseña incorrectos',
        };
      } else {
        print('Error response: ${utf8.decode(response.bodyBytes)}');
        return {
          'success': false,
          'message': 'Error al iniciar sesión: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('Exception: $e');
      return {
        'success': false,
        'message': 'Error de conexión: $e',
      };
    }
  }

  Future<bool> validateToken(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/auth/validate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
