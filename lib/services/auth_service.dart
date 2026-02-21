import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/aes_encryption.dart';

class AuthService {
  // Obtener perfil real del usuario desde el backend
  Future<Map<String, dynamic>?> getProfile(String username) async {
    final base = await baseUri;
    final url = base.toString();
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
    final base = await baseUri;
    final url = base.toString();
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

  static const String _host = '5.161.198.89';
  static const int _port = 8081;
  static const String _basePath = '/api';
  final storage = const FlutterSecureStorage();

  Future<Uri> get baseUri async {
    final savedUrl = await storage.read(key: 'server_url');
    if (savedUrl != null && savedUrl.isNotEmpty) {
      return Uri.parse(savedUrl);
    }
    return Uri(scheme: 'http', host: _host, port: _port, path: _basePath);
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final base = await baseUri;
      final uri = base.replace(path: '${base.path}/auth/login');
      print('🔗 AuthService: Intentando conectar a ${uri.toString()}');
      print('URI parseado:');
      print('  Scheme: ${uri.scheme}');
      print('  Host: ${uri.host}');
      print('  Port: ${uri.port}');
      print('  Path: ${uri.path}');

      // Encriptar la contraseña antes de enviarla
      final encryptedPassword = AESEncryption.encrypt(password);
      final body = json.encode({'username': username, 'password': encryptedPassword});
      print('Body de la petición: $body');

      print('⏳ Iniciando petición HTTP...');
      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: body,
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              print(
                '❌ Error: La petición excedió el tiempo de espera (30 segundos)',
              );
              throw Exception('Tiempo de espera agotado');
            },
          );

      print('📡 AuthService: Response status: ${response.statusCode}');
      print('📡 AuthService: Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        print('🔐 Token recibido: ${responseData['token']}');

        if (responseData['token'] == null ||
            responseData['token'].toString().isEmpty) {
          throw Exception('El servidor no devolvió un token válido');
        }

        // Guardar el token y la información del usuario
        await storage.write(
          key: 'token',
          value: responseData['token'].toString(),
        );
        await storage.write(key: 'user_data', value: json.encode(responseData));

        // Verificar que el token se guardó correctamente
        final savedToken = await storage.read(key: 'token');
        print('💾 Token guardado: $savedToken');

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
  
  // Obtener id_empresa del usuario autenticado
  Future<int?> getIdEmpresa() async {
    // Primero intentar desde user_data guardado
    final userData = await getUserData();
    if (userData != null && userData['user'] != null) {
      final idEmpresa = userData['user']['idEmpresa'];
      if (idEmpresa != null) {
        return idEmpresa is int ? idEmpresa : int.tryParse(idEmpresa.toString());
      }
    }
    
    // Fallback: leer desde storage directo
    final idEmpresaStr = await storage.read(key: 'id_empresa');
    if (idEmpresaStr != null) {
      return int.tryParse(idEmpresaStr);
    }
    
    return null;
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
