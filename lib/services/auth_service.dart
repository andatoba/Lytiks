import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  // Obtener perfil real del usuario desde el backend
  Future<Map<String, dynamic>?> getProfile(String username) async {
    final url = await baseUrl;
    final response = await http.get(
      Uri.parse('$url/auth/profile/$username'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }

  // Obtener cantidad de auditorías realizadas por el usuario (por su id)
  Future<int> getSigatokaAuditCount(int tecnicoId) async {
    final url = await baseUrl;
    final response = await http.get(
      Uri.parse('$url/sigatoka/technician/$tecnicoId'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.length;
    } else {
      return 0;
    }
  }

  // URL por defecto del backend Spring Boot corriendo en CentOS VM
  final String _defaultBaseUrl = 'http://5.161.198.89:8081/api';
  final storage = const FlutterSecureStorage();

  Future<String> get baseUrl async {
    final savedUrl = await storage.read(key: 'server_url');
    return savedUrl ?? _defaultBaseUrl;
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final url = await baseUrl;
      print('🔗 AuthService: Intentando conectar a $url/auth/login');

      final response = await http
          .post(
            Uri.parse('$url/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'username': username, 'password': password}),
          )
          .timeout(const Duration(seconds: 10));

      print('📡 AuthService: Response status: ${response.statusCode}');
      print('📡 AuthService: Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        // Guardar el token y la información del usuario
        await storage.write(key: 'token', value: responseData['token']);
        await storage.write(key: 'user_data', value: json.encode(responseData));

        return responseData;
      } else if (response.statusCode == 401) {
        throw Exception('Usuario o contraseña incorrectos');
      } else {
        throw Exception(
          'Error de conexión. Verifica que el servidor esté funcionando.',
        );
      }
    } catch (e) {
      if (e.toString().contains('SocketException')) {
        throw Exception(
          'No se puede conectar al servidor. Verifica la URL y que el servidor esté funcionando.',
        );
      }
      rethrow;
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await storage.read(key: 'token');
    return token != null && token.isNotEmpty;
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final userData = await storage.read(key: 'user_data');
    if (userData != null) {
      return json.decode(userData);
    }
    return null;
  }

  Future<String?> getToken() async {
    return await storage.read(key: 'token');
  }

  // Obtener username del usuario autenticado
  Future<String?> getUsername() async {
    final userData = await getUserData();
    return userData?['username'];
  }

  // Obtener id del usuario autenticado
  Future<int?> getUserId() async {
    final userData = await getUserData();
    return userData?['id'];
  }

  Future<void> logout() async {
    await storage.delete(key: 'token');
    await storage.delete(key: 'user_data');
  }

  String getRoleName(String role) {
    switch (role) {
      case 'TECHNICIAN':
        return 'Técnico';
      default:
        return role;
    }
  }

  bool isTechnician(String role) {
    return role == 'TECHNICIAN';
  }
}
