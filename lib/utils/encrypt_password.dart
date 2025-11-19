import '../utils/aes_encryption.dart';

void main() {
  // Encriptar la contraseña 'test123'
  try {
    final password = 'test123';
    final encrypted = AESEncryption.encrypt(password);
    
    print('🔒 Contraseña original: $password');
    print('🔐 Contraseña encriptada: $encrypted');
    
    // Verificar que la encriptación funciona
    final decrypted = AESEncryption.decrypt(encrypted);
    print('🔓 Contraseña desencriptada: $decrypted');
    
    final isValid = AESEncryption.verifyPassword(password, encrypted);
    print('✅ Verificación: ${isValid ? 'EXITOSA' : 'FALLIDA'}');
    
    print('\n📋 SQL para actualizar la contraseña en la base de datos:');
    print("UPDATE is_usuarios SET clave = '$encrypted' WHERE usuario = 'testop';");
    
  } catch (e) {
    print('❌ Error: $e');
  }
}