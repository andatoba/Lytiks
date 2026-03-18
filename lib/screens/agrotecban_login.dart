import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../services/auth_service.dart';
import '../services/location_tracking_service.dart';
import 'cliente_home_screen.dart';
import 'home_screen.dart';

class AgrotecbanLogin extends StatefulWidget {
  AgrotecbanLogin({Key? key}) : super(key: key);

  @override
  State<AgrotecbanLogin> createState() => _AgrotecbanLoginState();
}

class _AgrotecbanLoginState extends State<AgrotecbanLogin> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  final LocationTrackingService _locationTrackingService =
      LocationTrackingService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  bool _isPasswordVisible = false;
  bool _rememberMe = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF8FAF8),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              bool isWideScreen = constraints.maxWidth > 800;
              
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    // Logo y título
                    const SizedBox(height: 40),
                    Container(
                      height: 120,
                      decoration: const BoxDecoration(
                        color: Color(0xFF00903E),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.agriculture,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'AGROTECBAN',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0B3D25),
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Plataforma inteligente de datos agronómicos para banano y otros cultivos',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF0B3D25),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 40),
                    
                    // Contenido principal
                    isWideScreen 
                        ? _buildWideLayout()
                        : _buildMobileLayout(),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildWideLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Información del sistema (lado izquierdo)
        Expanded(
          flex: 2,
          child: _buildSystemInfo(),
        ),
        const SizedBox(width: 32),
        // Formulario de login (lado derecho)
        Expanded(
          flex: 3,
          child: _buildLoginForm(),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildLoginForm(),
        const SizedBox(height: 32),
        _buildSystemInfo(),
      ],
    );
  }

  Widget _buildSystemInfo() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.94),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF00903E).withOpacity(0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0B3D25).withOpacity(0.28),
            offset: const Offset(0, 20),
            blurRadius: 40,
            spreadRadius: -18,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFDF00),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.eco,
                  color: Color(0xFF00903E),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Estado del Sistema',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFF0B3D25),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Monitoreo activo de variables agronómicas en banano y otros cultivos para una mejor toma de decisiones.',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF0B3D25),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          _buildSystemFeature('Indicadores agronómicos actualizados en línea'),
          _buildSystemFeature('Panel para técnicos de campo y gestión agrícola'),
          _buildSystemFeature('Reportes por lote, finca, cultivo y fecha'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF00903E).withOpacity(0.15),
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.nature,
                  color: Color(0xFF00903E),
                  size: 16,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tecnología enfocada en productividad y salud vegetal sostenible.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF0B3D25),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemFeature(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle,
            color: Color(0xFF00903E),
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF0B3D25),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.94),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF00903E).withOpacity(0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0B3D25).withOpacity(0.28),
            offset: const Offset(0, 20),
            blurRadius: 40,
            spreadRadius: -18,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Decoración de fondo
          Stack(
            children: [
              Positioned(
                top: -20,
                right: -20,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFDF00).withOpacity(0.2),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(50),
                    ),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Iniciar sesión',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0B3D25),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Accede al panel de análisis y seguimiento de datos agronómicos.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF0B3D25),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Campo de email
                  const Text(
                    'CORREO INSTITUCIONAL',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0B3D25),
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7FAF7),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        hintText: 'tecnico@agrotecban.com',
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: Color(0xFF0B3D25),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Campo de contraseña
                  const Text(
                    'CONTRASEÑA',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0B3D25),
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7FAF7),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        hintText: '••••••••',
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: Color(0xFF0B3D25),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: const Color(0xFF0B3D25),
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Checkbox y enlace
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            onChanged: (value) {
                              setState(() {
                                _rememberMe = value ?? false;
                              });
                            },
                          ),
                          const Text(
                            'Mantener sesión',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF0B3D25),
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          // Acción de soporte técnico
                        },
                        child: const Text(
                          'Soporte técnico',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00903E),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Botón de login
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00903E),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 8,
                        shadowColor: const Color(0xFF00903E).withOpacity(0.3),
                      ),
                      child: _isLoading
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                    strokeWidth: 2,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'VALIDANDO ACCESO',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ],
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'INGRESAR',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward, size: 18),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Footer
                  const Center(
                    child: Text(
                      'Powered by Lytiks',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF0B3D25),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogin() async {
    // Validación básica
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor complete todos los campos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final loginResponse = await _authService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) {
        return;
      }

      final userRole =
          loginResponse['user']['rol']?.toString().toUpperCase() ?? '';
      final userId = loginResponse['user']['id']?.toString() ?? '';

      final firstName = loginResponse['user']['firstName']?.toString() ?? '';
      final lastName = loginResponse['user']['lastName']?.toString() ?? '';
      final userName = '$firstName $lastName'.trim();
      final displayName = userName.isNotEmpty
          ? userName
          : loginResponse['user']['username']?.toString() ?? '';

      if (userRole == 'OPERADOR') {
        await _storage.write(key: 'user_id', value: userId);
        await _storage.write(key: 'user_name', value: displayName);
        await _storage.write(key: 'user_role', value: userRole);

        final idEmpresa = loginResponse['user']['idEmpresa']?.toString() ?? '0';
        await _storage.write(key: 'id_empresa', value: idEmpresa);

        await _locationTrackingService.startTracking(
          userId: userId,
          userName: displayName,
        );

        if (!mounted) {
          return;
        }
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else if (userRole == 'CLIENTE') {
        await _storage.write(key: 'user_id', value: userId);
        await _storage.write(key: 'user_name', value: displayName);
        await _storage.write(key: 'user_role', value: userRole);

        final idEmpresa = loginResponse['user']['idEmpresa']?.toString() ?? '0';
        await _storage.write(key: 'id_empresa', value: idEmpresa);

        if (!mounted) {
          return;
        }
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ClienteHomeScreen(userData: loginResponse),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Rol de usuario no autorizado para esta aplicación'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}