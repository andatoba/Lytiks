import 'package:flutter/material.dart';
import 'dart:async' as dart_async;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/sync_service.dart';
import '../services/client_service.dart';
import 'audit_screen.dart';
import 'moko_audit_screen.dart';
import 'sigatoka_audit_screen.dart';
import 'audit_consultation_screen.dart';
import 'client_info_screen.dart';
import 'profile_screen.dart';
import 'location_tracking_screen.dart';

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
  dart_async.StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  
  // Estadísticas del backend
  int _totalClients = 0;
  int _activeClients = 0;
  int _todayAudits = 0;
  double _totalHectareas = 0.0;
  bool _isLoadingStats = true;

  final List<String> _titles = ['Inicio', 'Perfil'];

  @override
  void initState() {
    super.initState();
    _updatePendingCount();
    _loadStats();
    _startConnectivityListener();
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  Future<void> _updatePendingCount() async {
    final count = await _syncService.getPendingCount();
    if (mounted) {
      setState(() {
        _pendingCount = count;
      });
    }
  }

  Future<void> _loadStats() async {
    try {
      // Cargar estadísticas de clientes
      final clientsResponse = await http.get(
        Uri.parse('http://5.161.198.89:8081/api/clients/stats'),
        headers: {'Content-Type': 'application/json'},
      );
      
      // Cargar estadísticas de auditorías
      final auditsResponse = await http.get(
        Uri.parse('http://5.161.198.89:8081/api/audits/stats'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (clientsResponse.statusCode == 200 && auditsResponse.statusCode == 200) {
        final clientsData = jsonDecode(clientsResponse.body);
        final auditsData = jsonDecode(auditsResponse.body);
        
        if (mounted) {
          setState(() {
            _totalClients = clientsData['totalClients'] ?? 0;
            _activeClients = clientsData['activeClients'] ?? 0;
            _totalHectareas = (clientsData['totalHectareas'] ?? 0.0).toDouble();
            _todayAudits = auditsData['todayAudits'] ?? 0;
            _isLoadingStats = false;
          });
        }
      }
    } catch (e) {
      print('Error al cargar estadísticas: $e');
      if (mounted) {
        setState(() {
          _isLoadingStats = false;
        });
      }
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
          InicioTab(
            onSyncData: _syncData,
            onUpdateCount: _updatePendingCount,
            activeClients: _activeClients,
            todayAudits: _todayAudits,
            totalHectareas: _totalHectareas,
            isLoadingStats: _isLoadingStats,
          ),
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

  void _syncData({bool showDialogs = true}) async {
    if (_isSyncing) return;

    setState(() {
      _isSyncing = true;
    });

    try {
      // Verificar conexión a internet primero
      final hasConnection = await _syncService.hasInternetConnection();

      if (!hasConnection) {
        if (showDialogs) {
          _showNoConnectionDialog();
        }
        return;
      }

      // Mostrar diálogo de carga
      if (showDialogs) {
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
      }

      // Ejecutar sincronización
      final result = await _syncService.syncAllData();

      // Cerrar diálogo de carga
      if (showDialogs && mounted) Navigator.of(context).pop();

      // Actualizar contador
      await _updatePendingCount();

      // Mostrar resultado
      if (mounted) {
        if (showDialogs) {
          if (result.success) {
            _showSyncSuccessDialog(result);
          } else {
            _showSyncErrorDialog(result);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        if (showDialogs) {
          Navigator.of(context).pop(); // Cerrar diálogo de carga si está abierto
          _showSyncErrorDialog(null, error: e.toString());
        }
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

  void _startConnectivityListener() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((result) async {
      if (result == ConnectivityResult.none) {
        return;
      }

      if (_isSyncing) {
        return;
      }

      final pending = await _syncService.getPendingCount();
      if (pending <= 0) {
        return;
      }

      if (!mounted) {
        return;
      }

      await _syncData(showDialogs: false);
    });
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
class InicioTab extends StatefulWidget {
  final VoidCallback onSyncData;
  final VoidCallback onUpdateCount;
  final int activeClients;
  final int todayAudits;
  final double totalHectareas;
  final bool isLoadingStats;

  const InicioTab({
    super.key,
    required this.onSyncData,
    required this.onUpdateCount,
    required this.activeClients,
    required this.todayAudits,
    required this.totalHectareas,
    required this.isLoadingStats,
  });

  @override
  State<InicioTab> createState() => _InicioTabState();
}

class _InicioTabState extends State<InicioTab> {
  final ClientService _clientService = ClientService();
  final TextEditingController _clienteController = TextEditingController();
  final FocusNode _clienteFocusNode = FocusNode();
  List<Map<String, dynamic>> _clientSuggestions = [];
  dart_async.Timer? _searchDebounce;
  String _lastQuery = '';
  Map<String, dynamic>? _selectedClient;

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _clienteController.dispose();
    _clienteFocusNode.dispose();
    super.dispose();
  }

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
                widget.isLoadingStats ? '...' : '${widget.activeClients}',
                'Fincas Activas',
                Icons.agriculture,
                const Color(0xFF4CAF50),
              ),
              _buildStatCard(
                widget.isLoadingStats ? '...' : '${widget.todayAudits}',
                'Auditorías Hoy',
                Icons.assignment_turned_in,
                const Color(0xFF2196F3),
              ),
              _buildStatCard(
                widget.isLoadingStats
                    ? '...'
                    : '${widget.totalHectareas.toStringAsFixed(0)} Ha',
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

          _buildClientSearchSection(),

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
                        builder: (context) => AuditScreen(clientData: _selectedClient),
                      ),
                    ).then((_) => widget.onUpdateCount());
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
                        builder: (context) => MokoAuditScreen(
                          clientData: _selectedClient,
                        ),
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
                        builder: (context) => SigatokaAuditScreen(
                          clientData: _selectedClient,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Tercera fila: Seguimiento de ubicación
          SizedBox(
            width: double.infinity,
            child: _buildActionButton(
              context,
              icon: Icons.location_on,
              title: '📍 Seguimiento de Ubicación',
              color: const Color(0xFFE91E63),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LocationTrackingScreen(),
                  ),
                );
              },
              isFullWidth: true,
            ),
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
              onTap: widget.onSyncData,
              isFullWidth: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClientSearchSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF004B63)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person_search,
                color: const Color(0xFF004B63),
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'Seleccionar Cliente',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF004B63),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Este cliente se usará para auditorías de Moko, Sigatoka y Cultivos.',
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 12),
          RawAutocomplete<Map<String, dynamic>>(
            textEditingController: _clienteController,
            focusNode: _clienteFocusNode,
            displayStringForOption: _formatClientName,
            optionsBuilder: (TextEditingValue value) {
              final query = value.text.trim();
              if (query.length < 2 || query != _lastQuery) {
                return const Iterable<Map<String, dynamic>>.empty();
              }
              return _clientSuggestions;
            },
            onSelected: (client) {
              if (!mounted) {
                return;
              }
              setState(() {
                _selectedClient = client;
                _clientSuggestions = [];
              });
            },
            fieldViewBuilder: (
              BuildContext context,
              TextEditingController controller,
              FocusNode focusNode,
              VoidCallback onFieldSubmitted,
            ) {
              return TextField(
                controller: controller,
                focusNode: focusNode,
                keyboardType: TextInputType.text,
                onChanged: _onNameChanged,
                decoration: InputDecoration(
                  labelText: 'Nombre y Apellido del Cliente',
                  hintText: 'Ingrese nombre y apellido',
                  prefixIcon: const Icon(Icons.person),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: _triggerSearch,
                  ),
                ),
              );
            },
            optionsViewBuilder: (
              BuildContext context,
              AutocompleteOnSelected<Map<String, dynamic>> onSelected,
              Iterable<Map<String, dynamic>> options,
            ) {
              final optionList = options.toList();
              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  elevation: 4.0,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 240),
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: optionList.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final client = optionList[index];
                        final nombre = _formatClientName(client);
                        final cedula = client['cedula']?.toString() ?? '';
                        final finca = _formatFincaName(client);
                        final subtitleParts = <String>[];
                        if (cedula.isNotEmpty) {
                          subtitleParts.add('Cédula: $cedula');
                        }
                        if (finca.isNotEmpty) {
                          subtitleParts.add('Finca: $finca');
                        }
                        return ListTile(
                          title: Text(nombre.isEmpty ? 'Cliente sin nombre' : nombre),
                          subtitle: subtitleParts.isEmpty
                              ? null
                              : Text(subtitleParts.join(' | ')),
                          onTap: () => onSelected(client),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
          if (_selectedClient != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green.shade600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cliente: ${_selectedClient!['nombre'] ?? ''} ${_selectedClient!['apellidos'] ?? ''}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        if (_selectedClient!['cedula'] != null &&
                            _selectedClient!['cedula'].toString().isNotEmpty)
                          Text(
                            'Cédula: ${_selectedClient!['cedula']}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        if (_formatFincaName(_selectedClient!).isNotEmpty)
                          Text(
                            'Finca: ${_formatFincaName(_selectedClient!)}',
                            style: const TextStyle(fontSize: 12),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Puede cambiarlo al ingresar a cada módulo.',
              style: TextStyle(fontSize: 11, color: Colors.black54),
            ),
          ],
        ],
      ),
    );
  }

  String _formatClientName(Map<String, dynamic> client) {
    final nombre = client['nombre']?.toString() ?? '';
    final apellidos = client['apellidos']?.toString() ?? '';
    return '$nombre $apellidos'.trim();
  }

  String _formatFincaName(Map<String, dynamic> client) {
    return (client['fincaNombre'] ?? client['nombreFinca'] ?? '').toString();
  }

  void _onNameChanged(String value) {
    final query = value.trim();
    _searchDebounce?.cancel();
    final queryChanged = query != _lastQuery;
    _lastQuery = query;

    if (_selectedClient != null) {
      final selectedName = _formatClientName(_selectedClient!).toLowerCase();
      if (selectedName != query.toLowerCase()) {
        setState(() {
          _selectedClient = null;
        });
      }
    }

    if (query.length < 2) {
      if (_clientSuggestions.isNotEmpty) {
        setState(() {
          _clientSuggestions = [];
        });
      }
      return;
    }

    if (queryChanged && _clientSuggestions.isNotEmpty) {
      setState(() {
        _clientSuggestions = [];
      });
    }

    _searchDebounce = dart_async.Timer(
      const Duration(milliseconds: 350),
      () => _fetchClientSuggestions(query),
    );
  }

  Future<void> _fetchClientSuggestions(String query) async {
    try {
      final clients = await _clientService.searchClientsByName(query);
      if (!mounted || query != _lastQuery) {
        return;
      }
      setState(() {
        _clientSuggestions = clients;
      });
    } catch (e) {
      if (!mounted || query != _lastQuery) {
        return;
      }
      setState(() {
        _clientSuggestions = [];
      });
    }
  }

  Future<void> _triggerSearch() async {
    final query = _clienteController.text.trim();
    _lastQuery = query;
    if (query.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingrese al menos 2 letras para buscar'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    await _fetchClientSuggestions(query);
    if (mounted) {
      _clienteFocusNode.requestFocus();
    }
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
