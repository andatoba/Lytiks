import 'package:flutter/material.dart';
import '../services/sync_service.dart';
import 'audit_screen.dart';
import 'moko_audit_screen.dart';
import 'sigatoka_audit_screen.dart';
import 'audit_consultation_screen.dart';
import 'client_info_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  int _pendingCount = 0;
  final SyncService _syncService = SyncService();
  bool _isSyncing = false;

  final List<String> _titles = ['Inicio', 'Perfil'];

  @override
  void initState() {
    super.initState();
    _updatePendingCount();
  }

  Future<void> _updatePendingCount() async {
    final count = await _syncService.getPendingCount();
    if (mounted) {
      setState(() {
        _pendingCount = count;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        backgroundColor: const Color(0xFF004B63),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ClientInfoScreen(),
                ),
              );
            },
            tooltip: 'Información del Cliente',
          ),
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.cloud_upload_outlined),
                // Indicador de datos pendientes
                if (_pendingCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                      child: Text(
                        '$_pendingCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: _isSyncing ? null : () => _syncData(),
            tooltip: _pendingCount > 0
                ? 'Sincronizar Datos ($_pendingCount pendientes)'
                : 'No hay datos pendientes',
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          InicioTab(onSyncData: _syncData, onUpdateCount: _updatePendingCount),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: const Color(0xFF004B63),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outlined),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }

  void _syncData() async {
    if (_isSyncing) return;

    setState(() {
      _isSyncing = true;
    });

    try {
      // Verificar conexión a internet primero
      final hasConnection = await _syncService.hasInternetConnection();

      if (!hasConnection) {
        _showNoConnectionDialog();
        return;
      }

      // Mostrar diálogo de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF004B63)),
              ),
              const SizedBox(height: 16),
              const Text('Sincronizando datos...'),
              const SizedBox(height: 8),
              Text(
                'Subiendo $_pendingCount elementos pendientes',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );

      // Ejecutar sincronización
      final result = await _syncService.syncAllData();

      // Cerrar diálogo de carga
      if (mounted) Navigator.of(context).pop();

      // Actualizar contador
      await _updatePendingCount();

      // Mostrar resultado
      if (mounted) {
        if (result.success) {
          _showSyncSuccessDialog(result);
        } else {
          _showSyncErrorDialog(result);
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Cerrar diálogo de carga si está abierto
        _showSyncErrorDialog(null, error: e.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSyncing = false;
        });
      }
    }
  }

  void _showSyncSuccessDialog(result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 28),
            const SizedBox(width: 8),
            const Text('Sincronización Exitosa'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Se sincronizaron ${result.syncedItems} elementos correctamente.',
            ),
            const SizedBox(height: 16),
            const Text(
              'Detalles:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildSyncSummaryItem(
              'Elementos sincronizados',
              '${result.syncedItems}',
              Icons.cloud_done,
            ),
            if (result.failedItems > 0)
              _buildSyncSummaryItem(
                'Elementos fallidos',
                '${result.failedItems}',
                Icons.error,
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Aceptar',
              style: TextStyle(color: Color(0xFF004B63)),
            ),
          ),
        ],
      ),
    );
  }

  void _showSyncErrorDialog(result, {String? error}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.error, color: Colors.red, size: 28),
            const SizedBox(width: 8),
            const Text('Error de Sincronización'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              error ?? result?.message ?? 'No se pudo sincronizar los datos.',
            ),
            const SizedBox(height: 8),
            Text(
              'Verifique su conexión a internet e intente nuevamente.',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _syncData(); // Reintentar
            },
            child: const Text(
              'Reintentar',
              style: TextStyle(color: Color(0xFF004B63)),
            ),
          ),
        ],
      ),
    );
  }

  void _showNoConnectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.wifi_off, color: Colors.orange, size: 28),
            const SizedBox(width: 8),
            const Text('Sin Conexión'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('No hay conexión a internet disponible.'),
            const SizedBox(height: 8),
            Text(
              'Los datos se mantendrán guardados localmente hasta que tenga conexión.',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Entendido',
              style: TextStyle(color: Color(0xFF004B63)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncSummaryItem(String title, String count, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF004B63)),
          const SizedBox(width: 8),
          Expanded(child: Text(title)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF004B63).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF004B63),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Inicio Tab
class InicioTab extends StatelessWidget {
  final VoidCallback onSyncData;
  final VoidCallback onUpdateCount;

  const InicioTab({
    super.key,
    required this.onSyncData,
    required this.onUpdateCount,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tarjeta de bienvenida
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF004B63), Color(0xFF0066A3)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF004B63).withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.asset(
                    'assets/images/logo1.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '¡Bienvenido a Lytiks! 👋',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Tu asistente inteligente para el agro',
                        style: TextStyle(fontSize: 14, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Tu Resumen de Hoy
          const Row(
            children: [
              Icon(Icons.calendar_today, color: Color(0xFF004B63), size: 20),
              SizedBox(width: 8),
              Text(
                'Tu Resumen de Hoy',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF004B63),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Grid de estadísticas
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.3,
            children: [
              _buildStatCard(
                '12',
                'Fincas Activas',
                Icons.agriculture,
                const Color(0xFF4CAF50),
              ),
              _buildStatCard(
                '8',
                'Auditorías Hoy',
                Icons.assignment_turned_in,
                const Color(0xFF2196F3),
              ),
              _buildStatCard(
                '850 Ha',
                'Hectáreas',
                Icons.landscape,
                const Color(0xFF00BCD4),
              ),
              _buildStatCard(
                '94%',
                'Productividad',
                Icons.trending_up,
                const Color(0xFF9C27B0),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ¿Qué Necesitas Hacer?
          const Row(
            children: [
              Icon(Icons.flash_on, color: Color(0xFF004B63), size: 20),
              SizedBox(width: 8),
              Text(
                '¿Qué Necesitas Hacer?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF004B63),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Botones de acción
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  context,
                  icon: Icons.eco,
                  title: 'Evaluación de Cultivos',
                  color: const Color(0xFF4CAF50),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AuditScreen(),
                      ),
                    ).then((_) => onUpdateCount());
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  context,
                  icon: Icons.security,
                  title: 'Auditoría MOKO',
                  color: const Color(0xFFFF5722),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const MokoAuditScreen(clientData: null),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Segunda fila de botones
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  context,
                  icon: Icons.search,
                  title: 'Consulta de Auditorías',
                  color: const Color(0xFF9C27B0),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AuditConsultationScreen(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  context,
                  icon: Icons.biotech,
                  title: 'Control Sigatoka',
                  color: const Color(0xFF388E3C),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const SigatokaAuditScreen(clientData: null),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Botón de sincronización
          SizedBox(
            width: double.infinity,
            child: _buildActionButton(
              context,
              icon: Icons.cloud_sync,
              title: '☁️ Sincronizar Todo',
              color: const Color(0xFF00BCD4),
              onTap: onSyncData,
              isFullWidth: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String number,
    String label,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            number,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
    bool isFullWidth = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: isFullWidth
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: color, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: color, size: 32),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF004B63),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
