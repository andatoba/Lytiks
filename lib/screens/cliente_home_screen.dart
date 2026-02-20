import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/auth_service.dart';
import '../services/client_service.dart';
import '../services/hacienda_service.dart';
import '../services/lote_service.dart';
import 'sigatoka_audit_screen.dart';
import 'moko_audit_screen.dart';
import 'audit_screen.dart';

class ClienteHomeScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  
  const ClienteHomeScreen({super.key, required this.userData});

  @override
  State<ClienteHomeScreen> createState() => _ClienteHomeScreenState();
}

class _ClienteHomeScreenState extends State<ClienteHomeScreen> {
  final AuthService _authService = AuthService();
  final ClientService _clientService = ClientService();
  final HaciendaService _haciendaService = HaciendaService();
  final LoteService _loteService = LoteService();
  
  bool _isLoading = true;
  Map<String, dynamic>? _clientData;
  List<Map<String, dynamic>> _haciendas = [];
  List<Map<String, dynamic>> _lotes = [];
  List<Map<String, dynamic>> _evaluaciones = [];
  
  // Colores para cada tipo de evaluación
  static const Color colorSigatoka = Colors.amber; // Amarillo
  static const Color colorMoko = Colors.green;     // Verde
  static const Color colorAuditoria = Colors.blue; // Azul
  
  // Centro del mapa por defecto (Ecuador)
  LatLng _mapCenter = const LatLng(-2.1894, -79.8891);
  double _mapZoom = 10.0;
  
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }
  
  Future<void> _cargarDatos() async {
    setState(() => _isLoading = true);
    
    try {
      // Obtener datos del cliente basado en el user_id
      final clienteId = widget.userData['user']?['clienteId'];
      
      if (clienteId != null) {
        // Buscar cliente por ID
        _clientData = await _clientService.getClientById(clienteId);
        
        if (_clientData != null) {
          final clientId = _clientData!['id'] as int;
          
          // Cargar haciendas del cliente
          _haciendas = await _haciendaService.getHaciendasByCliente(clientId);
          
          // Cargar lotes de cada hacienda
          for (var hacienda in _haciendas) {
            final haciendaId = hacienda['id'] as int;
            final lotesHacienda = await _loteService.getLotesByHacienda(haciendaId);
            _lotes.addAll(lotesHacienda);
          }
          
          // Cargar evaluaciones del cliente
          await _cargarEvaluaciones(clientId);
          
          // Centrar mapa en la primera hacienda/lote con coordenadas
          _centrarMapa();
        }
      }
    } catch (e) {
      debugPrint('Error cargando datos del cliente: $e');
    }
    
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
  
  Future<void> _cargarEvaluaciones(int clienteId) async {
    try {
      // Cargar evaluaciones Sigatoka
      final sigatokaResponse = await _clientService.getEvaluacionesSigatokaByCliente(clienteId);
      for (var eval in sigatokaResponse) {
        _evaluaciones.add({
          'tipo': 'SIGATOKA',
          'color': colorSigatoka,
          'data': eval,
          'latitud': eval['latitud'],
          'longitud': eval['longitud'],
        });
      }
      
      // Cargar evaluaciones Moko
      final mokoResponse = await _clientService.getEvaluacionesMokoByCliente(clienteId);
      for (var eval in mokoResponse) {
        // Parsear coordenadas del GPS
        final gps = eval['gpsCoordinates']?.toString() ?? '';
        double? lat, lng;
        if (gps.isNotEmpty) {
          final parts = gps.split(',');
          if (parts.length == 2) {
            lat = double.tryParse(parts[0].trim());
            lng = double.tryParse(parts[1].trim());
          }
        }
        _evaluaciones.add({
          'tipo': 'MOKO',
          'color': colorMoko,
          'data': eval,
          'latitud': lat,
          'longitud': lng,
        });
      }
      
      // Cargar auditorías de campo
      final auditoriaResponse = await _clientService.getAuditoriasByCliente(clienteId);
      for (var eval in auditoriaResponse) {
        _evaluaciones.add({
          'tipo': 'AUDITORIA',
          'color': colorAuditoria,
          'data': eval,
          'latitud': eval['latitud'],
          'longitud': eval['longitud'],
        });
      }
    } catch (e) {
      debugPrint('Error cargando evaluaciones: $e');
    }
  }
  
  void _centrarMapa() {
    // Buscar primera ubicación válida
    for (var lote in _lotes) {
      final lat = lote['latitud'] as double?;
      final lng = lote['longitud'] as double?;
      if (lat != null && lng != null) {
        _mapCenter = LatLng(lat, lng);
        _mapZoom = 14.0;
        return;
      }
    }
    
    for (var hacienda in _haciendas) {
      final lat = hacienda['latitud'] as double?;
      final lng = hacienda['longitud'] as double?;
      if (lat != null && lng != null) {
        _mapCenter = LatLng(lat, lng);
        _mapZoom = 13.0;
        return;
      }
    }
    
    for (var eval in _evaluaciones) {
      final lat = eval['latitud'] as double?;
      final lng = eval['longitud'] as double?;
      if (lat != null && lng != null) {
        _mapCenter = LatLng(lat, lng);
        _mapZoom = 14.0;
        return;
      }
    }
  }
  
  List<Marker> _construirMarcadores() {
    final markers = <Marker>[];
    
    // Agregar marcadores de lotes con coordenadas
    for (var lote in _lotes) {
      final lat = lote['latitud'] as double?;
      final lng = lote['longitud'] as double?;
      
      if (lat != null && lng != null) {
        // Determinar el color basado en las evaluaciones de ese lote
        final color = _getColorLote(lote);
        
        markers.add(
          Marker(
            point: LatLng(lat, lng),
            width: 50,
            height: 50,
            child: GestureDetector(
              onTap: () => _mostrarDetallesLote(lote),
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.agriculture,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        );
      }
    }
    
    // Agregar marcadores de evaluaciones con coordenadas
    for (var eval in _evaluaciones) {
      final lat = eval['latitud'] as double?;
      final lng = eval['longitud'] as double?;
      
      if (lat != null && lng != null) {
        markers.add(
          Marker(
            point: LatLng(lat, lng),
            width: 40,
            height: 40,
            child: GestureDetector(
              onTap: () => _mostrarDetallesEvaluacion(eval),
              child: Container(
                decoration: BoxDecoration(
                  color: eval['color'] as Color,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  _getIconByTipo(eval['tipo'] as String),
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        );
      }
    }
    
    return markers;
  }
  
  Color _getColorLote(Map<String, dynamic> lote) {
    final loteCodigo = lote['codigo']?.toString() ?? '';
    
    // Buscar evaluaciones asociadas a este lote
    bool tieneSigatoka = false;
    bool tieneMoko = false;
    bool tieneAuditoria = false;
    
    for (var eval in _evaluaciones) {
      final evaluationLote = eval['data']?['lote']?.toString() ?? 
                            eval['data']?['loteCodigo']?.toString() ?? '';
      if (evaluationLote == loteCodigo) {
        switch (eval['tipo']) {
          case 'SIGATOKA':
            tieneSigatoka = true;
            break;
          case 'MOKO':
            tieneMoko = true;
            break;
          case 'AUDITORIA':
            tieneAuditoria = true;
            break;
        }
      }
    }
    
    // Prioridad: Sigatoka > Moko > Auditoría > Gris (sin evaluaciones)
    if (tieneSigatoka) return colorSigatoka;
    if (tieneMoko) return colorMoko;
    if (tieneAuditoria) return colorAuditoria;
    return Colors.grey; // Sin evaluaciones
  }
  
  IconData _getIconByTipo(String tipo) {
    switch (tipo) {
      case 'SIGATOKA':
        return Icons.eco;
      case 'MOKO':
        return Icons.warning;
      case 'AUDITORIA':
        return Icons.assignment;
      default:
        return Icons.place;
    }
  }
  
  void _mostrarDetallesLote(Map<String, dynamic> lote) {
    final loteCodigo = lote['codigo']?.toString() ?? '';
    final evaluacionesLote = _evaluaciones.where((e) {
      final evalLote = e['data']?['lote']?.toString() ?? 
                       e['data']?['loteCodigo']?.toString() ?? '';
      return evalLote == loteCodigo;
    }).toList();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildDetallesSheet(
        'Lote: ${lote['nombre'] ?? loteCodigo}',
        lote,
        evaluacionesLote,
      ),
    );
  }
  
  void _mostrarDetallesEvaluacion(Map<String, dynamic> eval) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildEvaluacionSheet(eval),
    );
  }
  
  Widget _buildDetallesSheet(String titulo, Map<String, dynamic> lote, List<Map<String, dynamic>> evaluaciones) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Título
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF004B63).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.agriculture, color: Color(0xFF004B63)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titulo,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF004B63),
                        ),
                      ),
                      if (lote['hectareas'] != null)
                        Text(
                          '${lote['hectareas']} hectáreas',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          // Información del lote
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (lote['variedad'] != null) ...[
                  _buildInfoRow(Icons.grass, 'Variedad', lote['variedad']),
                  const SizedBox(height: 8),
                ],
                if (lote['edad'] != null) ...[
                  _buildInfoRow(Icons.calendar_today, 'Edad', lote['edad']),
                  const SizedBox(height: 8),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Evaluaciones
          if (evaluaciones.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(Icons.info_outline, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Este lote no ha sido evaluado',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          else ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.assessment, size: 20, color: Color(0xFF004B63)),
                  const SizedBox(width: 8),
                  Text(
                    'Evaluaciones (${evaluaciones.length})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF004B63),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: evaluaciones.length,
                itemBuilder: (context, index) => _buildEvaluacionCard(evaluaciones[index]),
              ),
            ),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }
  
  Widget _buildEvaluacionSheet(Map<String, dynamic> eval) {
    final tipo = eval['tipo'] as String;
    final color = eval['color'] as Color;
    final data = eval['data'] as Map<String, dynamic>;
    
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Título
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(_getIconByTipo(tipo), color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getTipoLabel(tipo),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      Text(
                        _formatFecha(data['fecha'] ?? data['fechaDeteccion']),
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          // Contenido según tipo
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildContenidoEvaluacion(tipo, data),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildContenidoEvaluacion(String tipo, Map<String, dynamic> data) {
    switch (tipo) {
      case 'SIGATOKA':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(Icons.agriculture, 'Hacienda', data['hacienda'] ?? '-'),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.person, 'Evaluador', data['evaluador'] ?? '-'),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.calendar_month, 'Semana', data['semanaEpidemiologica']?.toString() ?? '-'),
          ],
        );
      case 'MOKO':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(Icons.numbers, 'Foco #', data['numeroFoco']?.toString() ?? '-'),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.warning, 'Plantas afectadas', data['plantasAfectadas']?.toString() ?? '-'),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.agriculture, 'Lote', data['lote'] ?? '-'),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.speed, 'Severidad', data['severidad'] ?? '-'),
            if (data['observaciones'] != null) ...[
              const SizedBox(height: 8),
              _buildInfoRow(Icons.notes, 'Observaciones', data['observaciones']),
            ],
          ],
        );
      case 'AUDITORIA':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(Icons.agriculture, 'Hacienda', data['hacienda'] ?? '-'),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.eco, 'Cultivo', data['cultivo'] ?? '-'),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.pending_actions, 'Estado', data['estado'] ?? '-'),
            if (data['observaciones'] != null) ...[
              const SizedBox(height: 8),
              _buildInfoRow(Icons.notes, 'Observaciones', data['observaciones']),
            ],
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }
  
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text('$label: ', style: TextStyle(color: Colors.grey[600])),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
  
  Widget _buildEvaluacionCard(Map<String, dynamic> eval) {
    final tipo = eval['tipo'] as String;
    final color = eval['color'] as Color;
    final data = eval['data'] as Map<String, dynamic>;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(_getIconByTipo(tipo), color: color, size: 20),
        ),
        title: Text(_getTipoLabel(tipo)),
        subtitle: Text(_formatFecha(data['fecha'] ?? data['fechaDeteccion'])),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.pop(context);
          _mostrarDetallesEvaluacion(eval);
        },
      ),
    );
  }
  
  String _getTipoLabel(String tipo) {
    switch (tipo) {
      case 'SIGATOKA':
        return 'Evaluación Sigatoka';
      case 'MOKO':
        return 'Registro Moko';
      case 'AUDITORIA':
        return 'Auditoría de Campo';
      default:
        return tipo;
    }
  }
  
  String _formatFecha(dynamic fecha) {
    if (fecha == null) return '-';
    if (fecha is String) {
      try {
        final dt = DateTime.parse(fecha);
        return '${dt.day}/${dt.month}/${dt.year}';
      } catch (_) {
        return fecha;
      }
    }
    return fecha.toString();
  }
  
  void _mostrarOpcionesNuevoIngreso() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Nuevo Ingreso',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF004B63),
              ),
            ),
            const SizedBox(height: 20),
            _buildOpcionIngreso(
              'Evaluación Sigatoka',
              Icons.eco,
              colorSigatoka,
              () => _navegarNuevaEvaluacion('SIGATOKA'),
            ),
            const SizedBox(height: 12),
            _buildOpcionIngreso(
              'Registro Moko',
              Icons.warning,
              colorMoko,
              () => _navegarNuevaEvaluacion('MOKO'),
            ),
            const SizedBox(height: 12),
            _buildOpcionIngreso(
              'Auditoría de Campo',
              Icons.assignment,
              colorAuditoria,
              () => _navegarNuevaEvaluacion('AUDITORIA'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
  
  Widget _buildOpcionIngreso(String titulo, IconData icon, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: color.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 16),
              Text(
                titulo,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
              const Spacer(),
              Icon(Icons.arrow_forward_ios, size: 16, color: color),
            ],
          ),
        ),
      ),
    );
  }
  
  void _navegarNuevaEvaluacion(String tipo) {
    Navigator.pop(context); // Cerrar modal
    
    // Preparar datos del cliente
    final clientDataForEval = _clientData != null ? {
      'id': _clientData!['id'],
      'cedula': _clientData!['cedula'],
      'nombre': '${_clientData!['nombre'] ?? ''} ${_clientData!['apellidos'] ?? ''}'.trim(),
      'telefono': _clientData!['telefono'],
      'haciendas': _haciendas,
      'lotes': _lotes,
      'isCliente': true, // Marca para indicar que es un cliente autenticado
    } : null;
    
    switch (tipo) {
      case 'SIGATOKA':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SigatokaAuditScreen(clientData: clientDataForEval),
          ),
        );
        break;
      case 'MOKO':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MokoAuditScreen(clientData: clientDataForEval),
          ),
        );
        break;
      case 'AUDITORIA':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AuditScreen(clientData: clientDataForEval),
          ),
        );
        break;
    }
  }
  
  Future<void> _logout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Cultivo'),
        backgroundColor: const Color(0xFF004B63),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarDatos,
            tooltip: 'Actualizar',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // Mapa
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _mapCenter,
                    initialZoom: _mapZoom,
                    onTap: (tapPos, latLng) => _onMapTap(latLng),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.lytiks.app',
                    ),
                    MarkerLayer(markers: _construirMarcadores()),
                  ],
                ),
                // Información del cliente
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: _buildClienteInfo(),
                ),
                // Leyenda de colores
                Positioned(
                  bottom: 100,
                  left: 16,
                  child: _buildLeyenda(),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _mostrarOpcionesNuevoIngreso,
        backgroundColor: const Color(0xFF004B63),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo ingreso'),
      ),
    );
  }
  
  Widget _buildClienteInfo() {
    if (_clientData == null) return const SizedBox.shrink();
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF004B63).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.person, color: Color(0xFF004B63)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${_clientData!['nombre'] ?? ''} ${_clientData!['apellidos'] ?? ''}'.trim(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${_haciendas.length} haciendas • ${_lotes.length} lotes',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLeyenda() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Evaluaciones',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            const SizedBox(height: 8),
            _buildLeyendaItem(colorSigatoka, 'Sigatoka'),
            const SizedBox(height: 4),
            _buildLeyendaItem(colorMoko, 'Moko'),
            const SizedBox(height: 4),
            _buildLeyendaItem(colorAuditoria, 'Auditoría'),
            const SizedBox(height: 4),
            _buildLeyendaItem(Colors.grey, 'Sin evaluación'),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLeyendaItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 2,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
  
  void _onMapTap(LatLng latLng) {
    // Buscar el punto más cercano
    const threshold = 0.001; // Aproximadamente 100m
    
    // Buscar en lotes
    for (var lote in _lotes) {
      final lat = lote['latitud'] as double?;
      final lng = lote['longitud'] as double?;
      if (lat != null && lng != null) {
        if ((lat - latLng.latitude).abs() < threshold && 
            (lng - latLng.longitude).abs() < threshold) {
          _mostrarDetallesLote(lote);
          return;
        }
      }
    }
    
    // Buscar en evaluaciones
    for (var eval in _evaluaciones) {
      final lat = eval['latitud'] as double?;
      final lng = eval['longitud'] as double?;
      if (lat != null && lng != null) {
        if ((lat - latLng.latitude).abs() < threshold && 
            (lng - latLng.longitude).abs() < threshold) {
          _mostrarDetallesEvaluacion(eval);
          return;
        }
      }
    }
    
    // Si no hay ningún punto cercano, mostrar mensaje
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No hay evaluaciones en esta ubicación'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
