import 'package:flutter/material.dart';
import 'usuarios_screen.dart';
import 'auditorias_screen.dart';
import 'reportes_screen.dart';
import 'clientes_screen.dart';
import 'productos_screen.dart';

class DashboardScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const DashboardScreen({super.key, this.userData});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  String _userRole = '';
  String _userName = '';
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  
  void _loadUserData() {
    if (widget.userData != null) {
      final user = widget.userData!['user'];
      _userRole = user?['rol']?.toString().toUpperCase() ?? '';
      _userName = '${user?['nombres'] ?? ''} ${user?['apellidos'] ?? ''}'.trim();
      
      // Validar que sea ADMIN
      if (_userRole != 'ADMIN') {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushReplacementNamed('/login');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Acceso denegado. Solo administradores pueden acceder.'),
              backgroundColor: Colors.red,
            ),
          );
        });
      }
    }
  }
  
  final List<Widget> _screens = [
    const DashboardHomeScreen(),
    const AuditoriasScreen(),
    const ClientesScreen(),
    const ProductosScreen(),
    const ReportesScreen(),
    const UsuariosScreen(),
  ];

  final List<NavigationRailDestination> _destinations = [
    const NavigationRailDestination(
      icon: Icon(Icons.dashboard_outlined),
      selectedIcon: Icon(Icons.dashboard),
      label: Text('Dashboard'),
    ),
    const NavigationRailDestination(
      icon: Icon(Icons.assignment_outlined),
      selectedIcon: Icon(Icons.assignment),
      label: Text('Auditorías'),
    ),
    const NavigationRailDestination(
      icon: Icon(Icons.people_outline),
      selectedIcon: Icon(Icons.people),
      label: Text('Clientes'),
    ),
    const NavigationRailDestination(
      icon: Icon(Icons.inventory_outlined),
      selectedIcon: Icon(Icons.inventory),
      label: Text('Productos'),
    ),
    const NavigationRailDestination(
      icon: Icon(Icons.bar_chart_outlined),
      selectedIcon: Icon(Icons.bar_chart),
      label: Text('Reportes'),
    ),
    const NavigationRailDestination(
      icon: Icon(Icons.admin_panel_settings_outlined),
      selectedIcon: Icon(Icons.admin_panel_settings),
      label: Text('Usuarios'),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar de navegación
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            extended: MediaQuery.of(context).size.width > 1200,
            leading: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Image.asset(
                    'assets/images/logo1.png',
                    width: 48,
                    height: 48,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.agriculture, size: 48, color: Color(0xFF2563EB));
                    },
                  ),
                ),
                if (_userName.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      _userName,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Chip(
                    label: Text(
                      'ADMIN',
                      style: TextStyle(fontSize: 10, color: Colors.white),
                    ),
                    backgroundColor: Color(0xFF2563EB),
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ],
              ],
            ),
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed('/login');
                    },
                    tooltip: 'Cerrar Sesión',
                  ),
                ),
              ),
            ),
            destinations: _destinations,
            backgroundColor: const Color(0xFF1E293B),
            selectedIconTheme: const IconThemeData(color: Color(0xFF2563EB)),
            unselectedIconTheme: const IconThemeData(color: Colors.white70),
            selectedLabelTextStyle: const TextStyle(color: Color(0xFF2563EB)),
            unselectedLabelTextStyle: const TextStyle(color: Colors.white70),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          // Contenido principal
          Expanded(
            child: Container(
              color: const Color(0xFFF8FAFC),
              child: _screens[_selectedIndex],
            ),
          ),
        ],
      ),
    );
  }
}

// Pantalla principal del Dashboard
class DashboardHomeScreen extends StatelessWidget {
  const DashboardHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dashboard',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bienvenido al Portal de Gestión Lytiks',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          
          // Tarjetas de estadísticas
          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 4 : 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.5,
            children: [
              _buildStatCard(
                'Auditorías Moko',
                '48',
                Icons.security,
                const Color(0xFFFF5722),
              ),
              _buildStatCard(
                'Auditorías Sigatoka',
                '32',
                Icons.biotech,
                const Color(0xFF4CAF50),
              ),
              _buildStatCard(
                'Clientes Activos',
                '125',
                Icons.people,
                const Color(0xFF2563EB),
              ),
              _buildStatCard(
                'Productos',
                '24',
                Icons.inventory,
                const Color(0xFF9C27B0),
              ),
            ],
          ),
          const SizedBox(height: 32),
          
          // Actividad reciente
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Actividad Reciente',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildActivityItem(
                    'Nueva auditoría Moko registrada',
                    'Hace 2 horas',
                    Icons.add_circle_outline,
                    const Color(0xFFFF5722),
                  ),
                  const Divider(),
                  _buildActivityItem(
                    'Cliente actualizado: Finca El Paraíso',
                    'Hace 5 horas',
                    Icons.edit,
                    const Color(0xFF2563EB),
                  ),
                  const Divider(),
                  _buildActivityItem(
                    'Reporte generado: Análisis Mensual',
                    'Hace 1 día',
                    Icons.description,
                    const Color(0xFF9C27B0),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(String title, String time, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
