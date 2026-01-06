import 'package:encrypt/encrypt.dart' as encrypt;

class AESEncryption {
  // Claves proporcionadas por el sistema (mismas que el backend)
  static const String _keyString = "92EQ11A79WOP3B9I"; // 16 caracteres para AES-128
  static const String _ivString = "SSL23LALLDL14378"; // 16 caracteres para IV

  /// Encripta un texto plano usando AES
  static String encryptPassword(String plainText) {
    try {
      final key = encrypt.Key.fromUtf8(_keyString);
      final iv = encrypt.IV.fromUtf8(_ivString);
      
      final encrypter = encrypt.Encrypter(
       
        encrypt.AES(key, mode: encrypt.AESMode.cbc, padding: 'PKCS7')
        //encrypt.AES(key, mode: encrypt.AESMode.cbc)
      );
      
      final encrypted = encrypter.encrypt(plainText, iv: iv);
      return encrypted.base64;
    } catch (e) {
      throw Exception('Error al encriptar: $e');
    }
  }

  /// Desencripta un texto encriptado (en base64) usando AES
  static String decryptPassword(String encryptedText) {
    try {
      final key = encrypt.Key.fromUtf8(_keyString);
      final iv = encrypt.IV.fromUtf8(_ivString);
      
      final encrypter = encrypt.Encrypter(
        encrypt.AES(key, mode: encrypt.AESMode.cbc, padding: 'PKCS7')
      );
      
      final decrypted = encrypter.decrypt64(encryptedText, iv: iv);
      return decrypted;
    } catch (e) {
      throw Exception('Error al desencriptar: $e');
    }
  }
}
