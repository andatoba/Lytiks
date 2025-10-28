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
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final data = await _authService.getUserData();
      if (mounted) {
        setState(() {
          userData = data;
          isLoading = false;
        });
      }
    } catch (e) {
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
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : userData == null
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
                          '${userData!['firstName']} ${userData!['lastName']}',
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
                          '@${userData!['username']}',
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
                                _authService.getRoleName(userData!['role']),
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
                        value: userData!['username'],
                      ),
                      _buildInfoItem(
                        icon: Icons.email,
                        label: 'Correo Electrónico',
                        value: userData!['email'] ?? 'No disponible',
                      ),
                      _buildInfoItem(
                        icon: Icons.badge,
                        label: 'Rol del Sistema',
                        value: _authService.getRoleName(userData!['role']),
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
                        value: '12', // Esto debería venir del backend
                      ),
                      _buildInfoItem(
                        icon: Icons.calendar_today,
                        label: 'Último Acceso',
                        value: 'Hoy',
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
    if (userData != null) {
      final firstName = userData!['firstName'] as String;
      final lastName = userData!['lastName'] as String;
      return '${firstName[0]}${lastName[0]}';
    }
    return '?';
  }

  Color _getRoleColor() {
    if (userData != null) {
      final role = userData!['role'] as String;
      if (role == 'TECHNICIAN') {
        return Colors.green;
      }
    }
    return Colors.grey;
  }

  IconData _getRoleIcon() {
    if (userData != null) {
      final role = userData!['role'] as String;
      if (role == 'TECHNICIAN') {
        return Icons.engineering;
      }
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
