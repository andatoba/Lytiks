import 'dart:async' as dart_async;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import '../services/offline_storage_service.dart';
import '../services/client_service.dart';

class AuditItem {
  final String name;
  final int maxScore;
  String? rating;
  int? calculatedScore;
  String? photoPath;
  String? observaciones;
  bool isLocked;

  AuditItem(this.name, this.maxScore) : isLocked = false;
}

class AuditScreen extends StatefulWidget {
  final Map<String, dynamic>? clientData;

  const AuditScreen({super.key, this.clientData});

  @override
  State<AuditScreen> createState() => _AuditScreenState();
}

class _AuditScreenState extends State<AuditScreen> {
  final OfflineStorageService _offlineStorageCampo = OfflineStorageService();
  final TextEditingController _nombreController = TextEditingController();
  final FocusNode _nombreFocusNode = FocusNode();
  final ClientService _clientService = ClientService();
  final ImagePicker _picker = ImagePicker();

  Map<String, dynamic>? _selectedClient;
  List<Map<String, dynamic>> _clientSuggestions = [];
  dart_async.Timer? _searchDebounce;
  String _lastQuery = '';
  bool _isBasicMode = true;
  String _selectedCrop = 'banano';
  
  // Estado de expansión de las secciones (todas colapsadas por defecto)
  final Map<String, bool> _expandedSections = {};

  // Variables para tracking de ubicación/trayecto
  List<Map<String, dynamic>> _trayectoUbicaciones = [];
  dart_async.Timer? _locationTimer;
  bool _isTrackingLocation = false;
  DateTime? _inicioEvaluacion;
  
  // Modo cliente: bloquea búsqueda de cliente y seguimiento de ubicación
  bool _isClienteMode = false;

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
    
    if (widget.clientData != null) {
      _selectedClient = widget.clientData;
      _nombreController.text = _formatClientName(widget.clientData!);
      _clientService.saveSelectedClient(widget.clientData!);
      
      // Verificar si es modo cliente (usuario con rol CLIENTE)
      _isClienteMode = widget.clientData!['isCliente'] == true;
    } else {
      _loadStoredClient();
    }
    
    // Solo iniciar tracking si NO es modo cliente
    if (!_isClienteMode) {
      _iniciarTrackingUbicacion();
    }
  }

  Future<void> _loadStoredClient() async {
    final stored = await _clientService.getSelectedClient();
    if (!mounted || stored == null) {
      return;
    }
    setState(() {
      _selectedClient = stored;
      _nombreController.text = _formatClientName(stored);
    });
  }

  @override
  void dispose() {
    _detenerTrackingUbicacion(); // Detener tracking al cerrar
    _searchDebounce?.cancel();
    _nombreController.dispose();
    _nombreFocusNode.dispose();
    super.dispose();
  }

  /// Inicia el tracking de ubicación periódico
  Future<void> _iniciarTrackingUbicacion() async {
    _inicioEvaluacion = DateTime.now();
    
    try {
      // Verificar permisos
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('⚠️ Permiso de ubicación denegado');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('⚠️ Permisos de ubicación permanentemente denegados');
        return;
      }

      _isTrackingLocation = true;

      // Capturar ubicación inicial
      await _capturarUbicacion();

      // Iniciar timer para capturar cada 30 segundos
      _locationTimer = dart_async.Timer.periodic(
        const Duration(seconds: 30),
        (timer) => _capturarUbicacion(),
      );

      debugPrint('✅ Tracking de ubicación iniciado');
    } catch (e) {
      debugPrint('❌ Error al iniciar tracking: $e');
    }
  }

  /// Captura la ubicación actual y la agrega al trayecto
  Future<void> _capturarUbicacion() async {
    if (!_isTrackingLocation) return;

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _trayectoUbicaciones.add({
        'latitud': position.latitude,
        'longitud': position.longitude,
        'altitud': position.altitude,
        'precision': position.accuracy,
        'timestamp': DateTime.now().toIso8601String(),
      });

      debugPrint('📍 Ubicación capturada: ${position.latitude}, ${position.longitude} (Total: ${_trayectoUbicaciones.length})');
    } catch (e) {
      debugPrint('❌ Error al capturar ubicación: $e');
    }
  }

  /// Detiene el tracking de ubicación
  void _detenerTrackingUbicacion() {
    _locationTimer?.cancel();
    _locationTimer = null;
    _isTrackingLocation = false;
    debugPrint('⏹️ Tracking de ubicación detenido. Total puntos: ${_trayectoUbicaciones.length}');
  }

  dart_async.Future<void> _initializeDatabase() async {
    try {
      await _offlineStorageCampo.initialize();
      debugPrint('✅ Base de datos inicializada correctamente en Audit screen');
    } catch (e) {
      debugPrint('❌ Error inicializando base de datos en Audit screen: $e');
    }
  }

  // Estructura de datos para los elementos de evaluación
  final Map<String, List<AuditItem>> _auditSections = {
    'ENFUNDE': [
      AuditItem('ATRASO DE LABOR E MAL IDENTIFICACION', 20),
      AuditItem('RETOLDEO', 20),
      AuditItem('CIRUGIA, SE ENCUENTRAN MELLIZOS', 20),
      AuditItem('FALTA DE PROTECTORES Y/O MAL COLOCADO', 20),
      AuditItem('SACUDIR BRACTEAS 2DA SUBIDA Y 3RA SUBIDA AL RACIMO', 20),
    ],
    'SELECCION': [
      AuditItem('MALA DISTRIBUCION Y/O DEJA PLANTAS SIN SELECTAR', 20),
      AuditItem('MALA SELECCION DE HIJOS', 20),
      AuditItem('DOBLE EN EXCESO', 20),
      AuditItem('MAL CANCELADOS', 20),
      AuditItem('NO GENERA DOBLES PERIFERICOS', 20),
    ],
    'COSECHA': [
      AuditItem('FFE + FFI (6.01% a 7.99%)', 10),
      AuditItem('FFE + FFI (8 a 9%)', 15),
      AuditItem('FFE+FFI (>=9.01%)', 20),
      AuditItem('NO SE LLEVA PARCELA DE CALIBRACION', 15),
      AuditItem('LIBRO DE AR (LLEVA REGISTRO DIARIO DE LOTES COSECHADOS)', 20),
    ],
    'DESHOJE FITOSANITARIO': [
      AuditItem('TEJIDO NECROTICO SIN CORTAR', 40),
      AuditItem('ELIMINAN TEJIDO VERDE Y/O CON ESTRIAS', 30),
      AuditItem('LA LONGITUD DE LA PALANCA NO ES LA CORRECTA', 30),
    ],
    'DESHOJE NORMAL': [
      AuditItem('HOJA TOCANDO RACIMO Y/O HOJA PUENTE SIN CORTAR', 25),
      AuditItem('ELIMINA HOJAS VERDES', 25),
      AuditItem('DEJA HOJA BAJERA', 25),
      AuditItem('DEJAN CODOS', 25),
    ],
    'DESVIO DE HIJOS': [
      AuditItem('SIN DESVIAR', 50),
      AuditItem('HIJOS MALTRATADOS', 50),
    ],
    'APUNTALAMIENTO CON ZUNCHO': [
      AuditItem('ZUNCHO FLOJO Y/O MAL ANGULO MAL COLOCADO', 25),
      AuditItem(
        'MATAS CAIDAS MAYOR A 3% DEL ENFUNDE PROMEDIO SEMANAL DEL LOTE',
        25,
      ),
      AuditItem(
        'UTILIZA ESTAQUILLA PARA MEJORAR ANGULO DENTRO DE LA PLANTACION Y CABLE VIA',
        25,
      ),
      AuditItem('AMARRE EN HIJOS Y/O EN PLANTAS CON RACIMOS +9 SEM', 25),
    ],
    'APUNTALAMIENTO CON PUNTAL': [
      AuditItem('PUNTAL FLOJO Y/O MAL ANGULO', 20),
      AuditItem(
        'MATAS CAIDAS MAYOR A 3% DEL ENFUNDE PROMEDIO SEMANAL DEL LOTE',
        20,
      ),
      AuditItem('UN PUNTAL', 20),
      AuditItem('PUNTAL ROZANDO RACIMO Y/O DAÑA PARTE BASAL DE LA HOJA', 20),
      AuditItem('PUNTAL PODRIDO', 20),
    ],
    'MANEJO DE AGUAS (RIEGO)': [
      AuditItem('SATURACION DE AREA SIN CAPACIDAD DE CAMPO', 20),
      AuditItem('CUMPLIMIENTO DE TURNOS DE RIEGO', 20),
      AuditItem('SE OBSERVAN TRIANGULO SECOS', 15),
      AuditItem('SE OBSERVAN FUGAS', 15),
      AuditItem('FALTA DE ASPERSORES', 15),
      AuditItem(
        'Lotes con frecuencia mayor a 5 días / mala planificación de cosecha',
        15,
      ),
      AuditItem('PRESION INADECUADA (ALTA O BAJA)', 15),
    ],
    'MANEJO DE AGUAS (DRENAJE)': [
      AuditItem('AGUAS RETENIDAS', 35),
      AuditItem('CANALES SUCIOS', 35),
      AuditItem('ENCHARCAMIENTO POR FALTA DE DRENAJE', 30),
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF004B63),
        title: const Text(
          'Auditoría de Cultivos',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(),
            const SizedBox(height: 20),
            _buildClientSearchSection(),
            const SizedBox(height: 20),
            if (_selectedClient == null) ...[
              _buildClientRequiredNotice(),
            ] else ...[
              _buildConfigurationCard(),
              const SizedBox(height: 20),
              ..._auditSections.entries
                  .map((entry) => _buildAuditSection(entry.key, entry.value))
                  .toList(),
              const SizedBox(height: 20),
              _buildSaveButton(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildClientRequiredNotice() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.amber.shade700),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Seleccione un cliente para continuar con la auditoría.',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF388E3C), Color(0xFF2E7D32)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.agriculture,
              color: Color(0xFF388E3C),
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Auditoría de Cultivos',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Evaluación integral de\nprácticas agrícolas',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                SizedBox(height: 8),
                Text(
                  'Esta auditoría evalúa las prácticas agrícolas\nimplementadas en el cultivo para optimizar\nla productividad y calidad.',
                  style: TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
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
                'Buscar Cliente',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF004B63),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: RawAutocomplete<Map<String, dynamic>>(
                  textEditingController: _nombreController,
                  focusNode: _nombreFocusNode,
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
                    _clientService.saveSelectedClient(client);
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
                      onChanged: _isClienteMode ? null : _onNameChanged,
                      readOnly: _isClienteMode,
                      enabled: !_isClienteMode,
                      decoration: InputDecoration(
                        labelText: 'Nombre y Apellido del Cliente',
                        hintText: _isClienteMode ? 'Cliente autenticado' : 'Ingrese nombre y apellido',
                        prefixIcon: Icon(
                          Icons.person,
                          color: _isClienteMode ? Colors.grey : null,
                        ),
                        border: const OutlineInputBorder(),
                        filled: _isClienteMode,
                        fillColor: _isClienteMode ? Colors.grey.withOpacity(0.1) : null,
                        suffixIcon: _isClienteMode 
                          ? const Icon(Icons.lock, color: Colors.grey)
                          : IconButton(
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
                                subtitleParts.add('Cedula: $cedula');
                              }
                              if (finca.isNotEmpty) {
                                subtitleParts.add('Finca: $finca');
                              }
                              return ListTile(
                                title: Text(
                                  nombre.isEmpty ? 'Cliente sin nombre' : nombre,
                                ),
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
              ),
            ],
          ),
          if (_selectedClient != null) ...[
            const SizedBox(height: 16),
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
                        if (_selectedClient!['telefono'] != null &&
                            _selectedClient!['telefono'].toString().isNotEmpty)
                          Text(
                            'Telefono: ${_selectedClient!['telefono']}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        if (_selectedClient!['direccion'] != null &&
                            _selectedClient!['direccion'].toString().isNotEmpty)
                          Text(
                            'Direccion: ${_selectedClient!['direccion']}',
                            style: const TextStyle(fontSize: 12),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
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
        _clientService.clearSelectedClient();
      }
    }

    // Determinar si es búsqueda por cédula (numérico) o por nombre (texto)
    final isNumeric = RegExp(r'^[0-9]+$').hasMatch(query);
    final minLength = isNumeric ? 4 : 2; // 4 dígitos para cédula, 2 letras para nombre

    if (query.length < minLength) {
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
    final query = _nombreController.text.trim();
    _lastQuery = query;
    
    // Determinar si es búsqueda por cédula (numérico) o por nombre (texto)
    final isNumeric = RegExp(r'^[0-9]+$').hasMatch(query);
    final minLength = isNumeric ? 4 : 2; // 4 dígitos para cédula, 2 letras para nombre
    
    if (query.length < minLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isNumeric 
            ? 'Ingrese al menos 4 dígitos de la cédula para buscar'
            : 'Ingrese al menos 2 letras del nombre para buscar'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    await _fetchClientSuggestions(query);
    if (!mounted) {
      return;
    }

    if (_clientSuggestions.length == 1) {
      final client = _clientSuggestions.first;
      setState(() {
        _selectedClient = client;
        _clientSuggestions = [];
      });
      _clientService.saveSelectedClient(client);
      _nombreController.text = _formatClientName(client);
      _nombreFocusNode.unfocus();
      return;
    }

    _nombreFocusNode.requestFocus();
  }

  Widget _buildConfigurationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
              Icon(Icons.settings, color: const Color(0xFF388E3C), size: 24),
              const SizedBox(width: 8),
              const Text(
                'Configuración de Auditoría',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF388E3C),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (_selectedClient == null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.amber.shade600,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Para poder guardar la auditoría, debe seleccionar primero un cliente',
                      style: TextStyle(
                        color: Colors.amber.shade800,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          _buildModeSelector(),
          const SizedBox(height: 16),
          _buildCropSelector(),
        ],
      ),
    );
  }

  Widget _buildModeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tipo de Auditoría',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF004B63),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Expanded(
              child: Text(
                'Básica',
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(width: 8),
            Switch(
              value: !_isBasicMode,
              onChanged: (value) {
                setState(() {
                  _isBasicMode = !value;
                });
              },
              activeColor: const Color(0xFF004B63),
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Completa',
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCropSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tipo de Cultivo',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF004B63),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildCropOption(
                'Banano',
                'banano',
                Icons.eco,
                isSelected: _selectedCrop == 'banano',
                onTap: () => setState(() => _selectedCrop = 'banano'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildCropOption(
                'Palma',
                'palma',
                Icons.park,
                isSelected: _selectedCrop == 'palma',
                onTap: () => setState(() => _selectedCrop = 'palma'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCropOption(
    String title,
    String value,
    IconData icon, {
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF004B63).withOpacity(0.1)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF004B63) : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF004B63) : Colors.grey[600],
              size: 32,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? const Color(0xFF004B63) : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuditSection(String sectionName, List<AuditItem> items) {
    // Inicializar estado de expansión si no existe
    _expandedSections.putIfAbsent(sectionName, () => false);
    
    final isExpanded = _expandedSections[sectionName] ?? false;
    
    // Calcular puntuación total de la sección
    int totalScore = 0;
    int maxScore = 0;
    for (var item in items) {
      maxScore += item.maxScore;
      if (item.calculatedScore != null) {
        totalScore += item.calculatedScore!;
      }
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: isExpanded ? const Color(0xFF004B63) : Colors.grey[300]!,
          width: isExpanded ? 2 : 1,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: isExpanded,
          onExpansionChanged: (expanded) {
            setState(() {
              _expandedSections[sectionName] = expanded;
            });
          },
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isExpanded ? const Color(0xFF004B63) : Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isExpanded ? Icons.check_circle : Icons.expand_more,
              color: isExpanded ? Colors.white : Colors.grey[600],
            ),
          ),
          title: Text(
            sectionName,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isExpanded ? const Color(0xFF004B63) : Colors.black87,
            ),
          ),
          subtitle: totalScore > 0
              ? Text(
                  'Puntuación: $totalScore/$maxScore',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                )
              : Text(
                  'Toca para expandir',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
          children: items.map((item) => _buildAuditItem(item)).toList(),
        ),
      ),
    );
  }

  Widget _buildAuditItem(AuditItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.name,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: item.rating,
                  decoration: const InputDecoration(
                    labelText: 'Calificación',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Alto', child: Text('Alto (30)')),
                    DropdownMenuItem(value: 'Medio', child: Text('Medio (50)')),
                    DropdownMenuItem(value: 'Bajo', child: Text('Bajo (100)')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      item.rating = value;
                      if (value != null) {
                        switch (value) {
                          case 'Alto':
                            item.calculatedScore = (item.maxScore * 0.3)
                                .round();
                            break;
                          case 'Medio':
                            item.calculatedScore = (item.maxScore * 0.5)
                                .round();
                            break;
                          case 'Bajo':
                            item.calculatedScore = item.maxScore;
                            break;
                        }
                      }
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => _takePhoto(item),
                icon: const Icon(Icons.camera_alt, size: 16),
                label: Text(
                  item.photoPath != null ? 'Foto tomada' : 'Tomar foto',
                  style: const TextStyle(fontSize: 12),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: item.photoPath != null
                      ? Colors.green
                      : const Color(0xFF004B63),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Observaciones',
              hintText: 'Escriba observaciones sobre esta evaluación...',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: (value) {
              setState(() {
                item.observaciones = value.isEmpty ? null : value;
              });
            },
          ),
          if (item.calculatedScore != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF004B63).withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Puntuación: ${item.calculatedScore}/${item.maxScore}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF004B63),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveAuditResults,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF004B63),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text(
          'Guardar Auditoría',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Future<void> _takePhoto(AuditItem item) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
      );
      if (photo != null) {
        setState(() {
          item.photoPath = photo.path;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto capturada exitosamente')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al tomar la foto: $e')));
    }
  }

  Future<void> _saveAuditResults() async {
    // Verificar que haya un cliente seleccionado
    if (_selectedClient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Debe seleccionar un cliente antes de guardar la auditoría',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Validar que se hayan completado algunas evaluaciones
    int completedItems = 0;
    int totalItems = 0;

    for (var section in _auditSections.values) {
      for (var item in section) {
        totalItems++;
        if (item.rating != null) {
          completedItems++;
        }
      }
    }

    if (_isBasicMode) {
      if (completedItems == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Debe completar al menos una evaluación'),
          ),
        );
        return;
      }
    } else {
      if (completedItems < totalItems) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Debe completar todas las evaluaciones ($completedItems/$totalItems)'),
          ),
        );
        return;
      }
    }

    // Validar que haya foto en todas las evaluaciones completadas
    final List<String> missingPhotoItems = [];
    for (var section in _auditSections.values) {
      for (var item in section) {
        if (item.rating != null && item.photoPath == null) {
          missingPhotoItems.add(item.name);
        }
      }
    }

    if (missingPhotoItems.isNotEmpty) {
      final preview = missingPhotoItems.take(3).join(', ');
      final extraCount = missingPhotoItems.length - 3;
      final suffix = extraCount > 0 ? ' y $extraCount más' : '';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Debe tomar foto para todas las evaluaciones. Faltan: $preview$suffix'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

      Map<String, dynamic> auditData = {};
      for (final section in _auditSections.entries) {
        auditData[section.key] = section.value
            .map(
              (item) => {
                'name': item.name,
                'maxScore': item.maxScore,
                'rating': item.rating,
                'calculatedScore': item.calculatedScore,
                'photoPath': item.photoPath,
                'observaciones': item.observaciones,
              },
            )
            .toList();
      }

      // Validaciones adicionales
      if (_selectedClient == null) {
        throw Exception('Cliente no seleccionado');
      }

      if (!_selectedClient!.containsKey('cedula') ||
          _selectedClient!['cedula'] == null) {
        throw Exception('Cliente sin cédula válida');
      }

      final clientId = _selectedClient!['id'] as int;
      final categoryId = _selectedCrop == 'banano' ? 1 : 2;

      await _offlineStorageCampo.savePendingAudit(
        cedulaCliente: _selectedClient!['cedula'] as String,
        clientId: clientId,
        categoryId: categoryId,
        auditDate: DateTime.now().toIso8601String(),
        status: 'COMPLETADA',
        auditData: [auditData], // Convertir el mapa en una lista
        observations:
        'Auditoría ${_isBasicMode ? 'básica' : 'completa'} de $_selectedCrop',
        trayectoUbicaciones: _trayectoUbicaciones, // Agregar trayecto
        inicioEvaluacion: _inicioEvaluacion?.toIso8601String(),
        finEvaluacion: DateTime.now().toIso8601String(),
      );

      // Detener tracking después de guardar
      _detenerTrackingUbicacion();

      // Calcular puntuación solo sobre los ítems completados
      final int totalScore = _calculateTotalScore();
      final int completedMaxScore = _calculateCompletedMaxScore();
      final double percentage = completedMaxScore > 0 ? (totalScore / completedMaxScore) * 100 : 0;

      final String hacienda = _selectedClient!['hacienda'] ?? 'No especificada';
      final String cultivo = _selectedCrop;
      final String tipoAuditoria = _isBasicMode ? 'Básica' : 'Completa';
      final String clienteNombre =
          '${_selectedClient!['nombre']} ${_selectedClient!['apellidos']}';
      final String cedulaCliente = _selectedClient!['cedula'] as String;

        final String mensaje =
          '''
    Auditoría guardada exitosamente:

    Cliente: $clienteNombre
    Cédula: $cedulaCliente
    Hacienda: $hacienda
    Cultivo: ${cultivo.toUpperCase()}
    Tipo: $tipoAuditoria

    ───────────────────────────────
    PUNTUACIÓN FINAL: ${percentage.toStringAsFixed(1)}%
    ───────────────────────────────
    Elementos evaluados: $completedItems/$totalItems

    Los datos se han guardado localmente y se sincronizarán cuando haya conexión.
    ''';

      // Cerrar diálogo de carga
      Navigator.of(context).pop();

      // Mostrar diálogo de éxito
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Auditoría Guardada'),
            content: Text(mensaje),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Cerrar el diálogo
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Guardado con éxito'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: const Text('Aceptar'),
              ),
            ],
          );
        },
      );
  }

  int _calculateTotalScore() {
    int totalScore = 0;
    for (var section in _auditSections.values) {
      for (var item in section) {
        if (item.calculatedScore != null) {
          totalScore += item.calculatedScore is int
              ? item.calculatedScore as int
              : (item.calculatedScore as double).round();
        }
      }
    }
    return totalScore;
  }

  int _calculateMaxPossibleScore() {
    int maxPossibleScore = 0;
    for (var section in _auditSections.values) {
      for (var item in section) {
        maxPossibleScore += item.maxScore is int
            ? item.maxScore as int
            : (item.maxScore as double).round();
      }
    }
    return maxPossibleScore;
  }

  // Nuevo método: suma solo los maxScore de los ítems completados
  int _calculateCompletedMaxScore() {
    int completedMaxScore = 0;
    for (var section in _auditSections.values) {
      for (var item in section) {
        if (item.rating != null) {
          completedMaxScore += item.maxScore;
        }
      }
    }
    return completedMaxScore;
  }
}
