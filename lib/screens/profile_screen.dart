import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  Map<String, dynamic>? userData;
  Map<String, dynamic>? userProfile;
  int auditCount = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Map<String, dynamic>? _extractUserMap(Map<String, dynamic>? data) {
    if (data == null) {
      return null;
    }
    final rawUser = data['user'];
    if (rawUser is Map<String, dynamic>) {
      return rawUser;
    }
    if (rawUser is Map) {
      return Map<String, dynamic>.from(rawUser);
    }
    return data;
  }

  String _readField(Map<String, dynamic>? source, List<String> keys) {
    if (source == null) return '';
    for (final key in keys) {
      final value = source[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    return '';
  }

  String _getDisplayName() {
    final nombres = _readField(userProfile, ['nombres', 'firstName', 'nombre']) != ''
        ? _readField(userProfile, ['nombres', 'firstName', 'nombre'])
        : _readField(_extractUserMap(userData), ['nombres', 'firstName', 'nombre']);
    final apellidos = _readField(userProfile, ['apellidos', 'lastName', 'apellido']) != ''
        ? _readField(userProfile, ['apellidos', 'lastName', 'apellido'])
        : _readField(_extractUserMap(userData), ['apellidos', 'lastName', 'apellido']);
    final fullName = [nombres, apellidos].where((p) => p.trim().isNotEmpty).join(' ').trim();
    if (fullName.isNotEmpty) {
      return fullName;
    }
    return _getUsername();
  }

  String _getUsername() {
    final fromProfile = _readField(userProfile, ['usuario', 'username']);
    if (fromProfile.isNotEmpty) {
      return fromProfile;
    }
    return _readField(_extractUserMap(userData), ['usuario', 'username']);
  }

  String _getEmail() {
    final fromProfile = _readField(userProfile, ['correo', 'email']);
    if (fromProfile.isNotEmpty) {
      return fromProfile;
    }
    return _readField(_extractUserMap(userData), ['correo', 'email']);
  }

  String _getRole() {
    final fromProfile = _readField(userProfile, ['rol', 'role']);
    if (fromProfile.isNotEmpty) {
      return fromProfile;
    }
    return _readField(_extractUserMap(userData), ['rol', 'role']);
  }

  Future<void> _loadUserData() async {
    try {
      final data = await _authService.getUserData();
      final storedUser = _extractUserMap(data);
      String? username = _readField(storedUser, ['usuario', 'username']);
      if (username.isEmpty) {
        username = await _authService.getUsername();
      }
      print('[Perfil] Username usado para perfil: $username');
      if (username != null) {
        final profile = await _authService.getProfile(username);
        print('[Perfil] Respuesta del backend para perfil: $profile');
        if (mounted) {
          setState(() {
            userData = data;
            userProfile = profile;
            auditCount = 0; // Ya no se consulta el conteo de auditorías
            isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print('[Perfil] Error al cargar datos de usuario: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    // Mostrar diálogo de confirmación
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _authService.logout();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayName = _getDisplayName();
    final username = _getUsername();
    final email = _getEmail();
    final role = _getRole();
    final cedula = _readField(userProfile, ['cedula']);
    final telefonoCel = _readField(userProfile, ['telefonoCel', 'telefono_cel', 'telefonoCelular']);
    final telefonoCasa = _readField(userProfile, ['telefonoCasa', 'telefono_casa']);
    final direccion = _readField(userProfile, ['direccion', 'direccionDom', 'direccion_dom']);
    final tipoPersona = _readField(userProfile, ['tipoPersona', 'tipo_persona']);
    final estado = _readField(userProfile, ['estado']);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : (userData == null && userProfile == null)
          ? const Center(
              child: Text('No hay información de usuario disponible'),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // Header con foto de perfil
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF004B63),
                          const Color(0xFF004B63).withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        // Foto de perfil
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                          child: Text(
                            _getInitials(),
                            style: const TextStyle(
                              fontSize: 32,
                              color: Color(0xFF004B63),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Nombre completo
                        Text(
                          displayName.isNotEmpty ? displayName : 'Usuario',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),

                        // Usuario
                        Text(
                          username.isNotEmpty ? '@$username' : '@usuario',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Rol Técnico
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: _getRoleColor(),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getRoleIcon(),
                                color: Colors.white,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _authService.getRoleName(
                                  role,
                                ),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Información del usuario
                  _buildInfoCard(
                    title: 'Información Personal',
                    icon: Icons.person,
                    items: [
                      _buildInfoItem(
                        icon: Icons.account_circle,
                        label: 'Usuario',
                        value: username.isNotEmpty ? username : 'No disponible',
                      ),
                      _buildInfoItem(
                        icon: Icons.email,
                        label: 'Correo Electrónico',
                        value: email.isNotEmpty ? email : 'No disponible',
                      ),
                      _buildInfoItem(
                        icon: Icons.badge,
                        label: 'Rol del Sistema',
                        value: _authService.getRoleName(
                          role,
                        ),
                      ),
                      if (cedula.isNotEmpty)
                        _buildInfoItem(
                          icon: Icons.credit_card,
                          label: 'Cédula',
                          value: cedula,
                        ),
                      if (telefonoCel.isNotEmpty)
                        _buildInfoItem(
                          icon: Icons.phone_android,
                          label: 'Teléfono celular',
                          value: telefonoCel,
                        ),
                      if (telefonoCasa.isNotEmpty)
                        _buildInfoItem(
                          icon: Icons.phone,
                          label: 'Teléfono casa',
                          value: telefonoCasa,
                        ),
                      if (direccion.isNotEmpty)
                        _buildInfoItem(
                          icon: Icons.home,
                          label: 'Dirección',
                          value: direccion,
                        ),
                      if (tipoPersona.isNotEmpty)
                        _buildInfoItem(
                          icon: Icons.person_outline,
                          label: 'Tipo de persona',
                          value: tipoPersona,
                        ),
                      if (estado.isNotEmpty)
                        _buildInfoItem(
                          icon: Icons.verified_user,
                          label: 'Estado',
                          value: estado,
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Estadísticas (ejemplo)
                  _buildInfoCard(
                    title: 'Estadísticas',
                    icon: Icons.analytics,
                    items: [
                      _buildInfoItem(
                        icon: Icons.assignment,
                        label: 'Auditorías Realizadas',
                        value: auditCount.toString(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Botón de cerrar sesión
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _logout,
                      icon: const Icon(Icons.logout),
                      label: const Text('Cerrar Sesión'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  String _getInitials() {
    final name = _getDisplayName().trim();
    if (name.isEmpty) {
      final username = _getUsername();
      if (username.isNotEmpty) {
        return username[0].toUpperCase();
      }
      return '?';
    }
    final parts = name.split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts.first[0].toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  Color _getRoleColor() {
    final role = _getRole().toUpperCase();
    if (role == 'TECHNICIAN' || role == 'OPERADOR') {
      return Colors.green;
    }
    return Colors.grey;
  }

  IconData _getRoleIcon() {
    final role = _getRole().toUpperCase();
    if (role == 'TECHNICIAN' || role == 'OPERADOR') {
      return Icons.engineering;
    }
    return Icons.person;
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> items,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF004B63).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: const Color(0xFF004B63), size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF004B63),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...items,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: Colors.grey[600], size: 18),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
