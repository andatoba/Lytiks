import 'package:flutter/material.dart';
import '../utils/aes_encryption.dart';

void main() {
  runApp(const EncryptionTestApp());
}

class EncryptionTestApp extends StatelessWidget {
  const EncryptionTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Encryption Test',
      home: const EncryptionTestScreen(),
    );
  }
}

class EncryptionTestScreen extends StatefulWidget {
  const EncryptionTestScreen({super.key});

  @override
  State<EncryptionTestScreen> createState() => _EncryptionTestScreenState();
}

class _EncryptionTestScreenState extends State<EncryptionTestScreen> {
  final TextEditingController _passwordController = TextEditingController();
  String _encryptedPassword = '';
  String _testResult = '';

  void _encryptPassword() {
    try {
      final password = _passwordController.text;
      if (password.isNotEmpty) {
        final encrypted = AESEncryption.encrypt(password);
        setState(() {
          _encryptedPassword = encrypted;
          _testResult = 'Contraseña encriptada exitosamente';
        });
      }
    } catch (e) {
      setState(() {
        _testResult = 'Error: $e';
      });
    }
  }

  void _runTest() {
    try {
      AESEncryption.testEncryption();
      setState(() {
        _testResult = 'Prueba de encriptación completada. Revisa la consola.';
      });
    } catch (e) {
      setState(() {
        _testResult = 'Error en prueba: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test de Encriptación AES'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Contraseña a encriptar',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _encryptPassword,
              child: const Text('Encriptar'),
            ),
            const SizedBox(height: 16),
            if (_encryptedPassword.isNotEmpty) ...[
              const Text('Contraseña encriptada:', style: TextStyle(fontWeight: FontWeight.bold)),
              SelectableText(_encryptedPassword),
              const SizedBox(height: 16),
            ],
            ElevatedButton(
              onPressed: _runTest,
              child: const Text('Ejecutar Prueba'),
            ),
            const SizedBox(height: 16),
            Text(_testResult),
          ],
        ),
      ),
    );
  }
}