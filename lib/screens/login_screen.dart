import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/auth_service.dart';
import '../services/location_tracking_service.dart';
import '../widgets/dynamic_logo_widget.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  final _authService = AuthService();
  final _locationTrackingService = LocationTrackingService();
  final _storage = const FlutterSecureStorage();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final loginResponse = await _authService.login(
          _usernameController.text.trim(),
          _passwordController.text,
        );

        // Navegamos según el rol del usuario
        if (mounted) {
          final userRole = loginResponse['user']['rol']?.toString().toUpperCase() ?? '';
          final userId = loginResponse['user']['id']?.toString() ?? '';
          
          // Construir nombre completo del usuario
          final firstName = loginResponse['user']['firstName']?.toString() ?? '';
          final lastName = loginResponse['user']['lastName']?.toString() ?? '';
          final userName = '$firstName $lastName'.trim();
          // Fallback a username si no hay firstName/lastName
          final displayName = userName.isNotEmpty 
              ? userName 
              : loginResponse['user']['username']?.toString() ?? '';
          
          print('🔍 Rol del usuario recibido: $userRole');
          print('👤 Nombre del usuario: $displayName');

          if (userRole == 'OPERADOR') {
            // Guardar información del usuario para tracking
            await _storage.write(key: 'user_id', value: userId);
            await _storage.write(key: 'user_name', value: displayName);
            
            // Guardar id_empresa del usuario
            final idEmpresa = loginResponse['user']['idEmpresa']?.toString() ?? '0';
            await _storage.write(key: 'id_empresa', value: idEmpresa);
            print('🏢 ID Empresa guardado: $idEmpresa');
            
            // Iniciar seguimiento automático de ubicación
            await _locationTrackingService.startTracking(
              userId: userId,
              userName: displayName,
            );
            
            print('✅ Seguimiento de ubicación iniciado para $displayName');
            
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          } else {
            // Solo usuarios operadores pueden acceder
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Solo usuarios operadores pueden acceder a esta aplicación',
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceAll('Exception: ', '')),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenHeight = constraints.maxHeight;
            final screenWidth = constraints.maxWidth;

            // Responsive calculations
            final verticalPadding = (screenHeight * 0.05).clamp(20.0, 60.0);
            final horizontalPadding = (screenWidth * 0.06).clamp(16.0, 32.0);
            final logoHeight = (screenWidth * 0.25).clamp(64.0, 120.0);
            final titleSize = (screenWidth * 0.08).clamp(24.0, 36.0);
            final subtitleSize = (screenWidth * 0.04).clamp(14.0, 18.0);

            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: verticalPadding,
                ),
                child: Column(
                  children: [
                    SizedBox(height: verticalPadding),

                    // Logo (responsive)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(
                        (screenWidth * 0.06).clamp(16.0, 32.0),
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF004B63),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromRGBO(0, 75, 99, 0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: DynamicLogoWidget(
                        height: logoHeight,
                        fit: BoxFit.contain,
                      ),
                    ),

                    SizedBox(height: (screenHeight * 0.04).clamp(20.0, 40.0)),

                    // Título
                    Text(
                      'Lytiks',
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF004B63),
                        letterSpacing: 2,
                      ),
                    ),

                    SizedBox(height: (screenHeight * 0.01).clamp(6.0, 12.0)),

                    Text(
                      'Control Inteligente de Plagas',
                      style: TextStyle(
                        fontSize: subtitleSize,
                        color: const Color(0xFF6B8A99),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: (screenHeight * 0.06).clamp(30.0, 48.0)),

                    // Formulario
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Campo Usuario
                          TextFormField(
                            controller: _usernameController,
                            decoration: const InputDecoration(
                              labelText: 'Usuario',
                              prefixIcon: Icon(Icons.person_outline),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingresa tu usuario';
                              }
                              return null;
                            },
                          ),

                          SizedBox(
                            height: (screenHeight * 0.02).clamp(12.0, 20.0),
                          ),

                          // Campo Contraseña
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Contraseña',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingresa tu contraseña';
                              }
                              if (value.length < 6) {
                                return 'La contraseña debe tener al menos 6 caracteres';
                              }
                              return null;
                            },
                          ),

                          SizedBox(
                            height: (screenHeight * 0.03).clamp(16.0, 24.0),
                          ),

                          // Botón de Login
                          SizedBox(
                            width: double.infinity,
                            height: (screenHeight * 0.07).clamp(48.0, 64.0),
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF004B63),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 3,
                              ),
                              child: _isLoading
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.white,
                                                ),
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Text(
                                          'Verificando...',
                                          style: TextStyle(
                                            fontSize: (screenWidth * 0.04)
                                                .clamp(14.0, 18.0),
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    )
                                  : Text(
                                      'Iniciar Sesión',
                                      style: TextStyle(
                                        fontSize: (screenWidth * 0.04).clamp(
                                          14.0,
                                          18.0,
                                        ),
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),

                          SizedBox(
                            height: (screenHeight * 0.02).clamp(12.0, 20.0),
                          ),

                          // Enlace ¿Olvidaste tu contraseña?
                          TextButton(
                            onPressed: () {
                              // Implementar recuperación de contraseña
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Función de recuperación en desarrollo',
                                  ),
                                ),
                              );
                            },
                            child: Text(
                              '¿Olvidaste tu contraseña?',
                              style: TextStyle(
                                color: const Color(0xFF004B63),
                                fontWeight: FontWeight.w500,
                                fontSize: (screenWidth * 0.035).clamp(
                                  12.0,
                                  16.0,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: (screenHeight * 0.05).clamp(20.0, 40.0)),

                    // Footer
                    Container(
                      padding: EdgeInsets.all(
                        (screenWidth * 0.04).clamp(12.0, 20.0),
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF004B63).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.agriculture,
                            color: const Color(0xFF004B63),
                            size: (screenWidth * 0.05).clamp(16.0, 24.0),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Tecnología para el agro sostenible',
                            style: TextStyle(
                              color: const Color(0xFF004B63),
                              fontWeight: FontWeight.w500,
                              fontSize: (screenWidth * 0.035).clamp(12.0, 16.0),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
