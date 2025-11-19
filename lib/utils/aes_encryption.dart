import 'package:encrypt/encrypt.dart';

class AESEncryption {
  // Claves proporcionadas por el sistema
  static const String _keyString = '92EQ11A79WOP3B9I';  // 16 caracteres para AES-128
  static const String _ivString = 'SSL23LALLDL14378';   // 16 caracteres para IV
  
  static final _key = Key.fromBase16(_stringToHex(_keyString));
  static final _iv = IV.fromBase16(_stringToHex(_ivString));
  static final _encrypter = Encrypter(AES(_key, mode: AESMode.cbc, padding: 'PKCS7'));

  /// Convierte string a hexadecimal
  static String _stringToHex(String input) {
    return input.codeUnits.map((unit) => unit.toRadixString(16).padLeft(2, '0')).join('');
  }

  /// Encripta un texto plano
  static String encrypt(String plainText) {
    try {
      final encrypted = _encrypter.encrypt(plainText, iv: _iv);
      return encrypted.base64;
    } catch (e) {
      throw Exception('Error al encriptar: $e');
    }
  }

  /// Desencripta un texto encriptado (en base64)
  static String decrypt(String encryptedText) {
    try {
      final encrypted = Encrypted.fromBase64(encryptedText);
      final decrypted = _encrypter.decrypt(encrypted, iv: _iv);
      return decrypted;
    } catch (e) {
      throw Exception('Error al desencriptar: $e');
    }
  }

  /// Verifica si una contraseña plana coincide con una encriptada
  static bool verifyPassword(String plainPassword, String encryptedPassword) {
    try {
      final encryptedPlain = encrypt(plainPassword);
      return encryptedPlain == encryptedPassword;
    } catch (e) {
      return false;
    }
  }

  /// Método de prueba para validar la encriptación
  static void testEncryption() {
    const testPassword = 'test123';
    
    try {
      // Encriptar
      final encrypted = encrypt(testPassword);
      print('🔒 Contraseña original: $testPassword');
      print('🔐 Contraseña encriptada: $encrypted');
      
      // Desencriptar
      final decrypted = decrypt(encrypted);
      print('🔓 Contraseña desencriptada: $decrypted');
      
      // Verificar
      final isValid = verifyPassword(testPassword, encrypted);
      print('✅ Verificación: ${isValid ? 'EXITOSA' : 'FALLIDA'}');
      
    } catch (e) {
      print('❌ Error en prueba: $e');
    }
  }
}