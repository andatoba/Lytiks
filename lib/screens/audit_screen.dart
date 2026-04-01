import 'dart:convert';
import 'dart:async' as dart_async;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/audit_service.dart';
import '../services/auth_service.dart';
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

class _AuditScreenState extends State<AuditScreen> with WidgetsBindingObserver {
  static const String _draftKey = 'audit_screen_draft';
  final OfflineStorageService _offlineStorageCampo = OfflineStorageService();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _loteController = TextEditingController();
  final TextEditingController _seleccionTotalPlantasController =
      TextEditingController();
  final TextEditingController _seleccionMalSeleccionadasController =
      TextEditingController();
  final TextEditingController _seleccionObservacionController =
      TextEditingController();
  final FocusNode _nombreFocusNode = FocusNode();
  final AuditService _auditService = AuditService();
  final AuthService _authService = AuthService();
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

  // Variables para sección COSECHA personalizada
  final List<int> _cosechaEdades = [9, 10, 11, 12, 13];
  final List<int> _cosechaCalibraciones = [
    38,
    39,
    40,
    41,
    42,
    43,
    44,
    45,
    46,
    47,
    48,
    49,
    50
  ];
  final List<String> _coloresCinta = const [
    'Azul',
    'Blanco',
    'Amarillo',
    'Morado',
    'Rojo',
    'Cafe',
    'Negro',
    'Verde',
    'Gris',
  ];
  final Map<int, Map<int, TextEditingController>> _cosechaControllers = {};
  final Map<int, String?> _cosechaColorCinta = {};
  double _cosechaPorcentajeBajoGrado = 0;
  double _cosechaPorcentajeSobreGrado = 0;
  double _cosechaScore = 100;
  bool _cosechaExpanded = false;
  String? _cosechaPhotoPath;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeDatabase();

    if (widget.clientData != null) {
      _selectedClient = widget.clientData;
      _nombreController.text = _formatClientName(widget.clientData!);
      _loteController.text = _formatFincaName(widget.clientData!);
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

    // Inicializar controladores de grilla COSECHA
    for (var edad in _cosechaEdades) {
      _cosechaControllers[edad] = {};
      _cosechaColorCinta[edad] = null;
      for (var cal in _cosechaCalibraciones) {
        _cosechaControllers[edad]![cal] = TextEditingController();
        _cosechaControllers[edad]![cal]!.addListener(_recalcularCosecha);
      }
    }
    _restaurarBorrador();
  }

  Future<void> _loadStoredClient() async {
    final stored = await _clientService.getSelectedClient();
    if (!mounted || stored == null || _selectedClient != null) {
      return;
    }
    setState(() {
      _selectedClient = stored;
      _nombreController.text = _formatClientName(stored);
      if (_loteController.text.trim().isEmpty) {
        _loteController.text = _formatFincaName(stored);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _guardarBorrador();
    _detenerTrackingUbicacion();
    _searchDebounce?.cancel();
    _nombreController.dispose();
    _loteController.dispose();
    _seleccionTotalPlantasController.dispose();
    _seleccionMalSeleccionadasController.dispose();
    _seleccionObservacionController.dispose();
    _nombreFocusNode.dispose();
    for (var edadMap in _cosechaControllers.values) {
      for (var ctrl in edadMap.values) {
        ctrl.dispose();
      }
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      _guardarBorrador();
    }
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

      // Iniciar timer para capturar cada 1 minuto
      _locationTimer = dart_async.Timer.periodic(
        const Duration(minutes: 1),
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

      debugPrint(
          '📍 Ubicación capturada: ${position.latitude}, ${position.longitude} (Total: ${_trayectoUbicaciones.length})');
    } catch (e) {
      debugPrint('❌ Error al capturar ubicación: $e');
    }
  }

  /// Detiene el tracking de ubicación
  void _detenerTrackingUbicacion() {
    _locationTimer?.cancel();
    _locationTimer = null;
    _isTrackingLocation = false;
    debugPrint(
        '⏹️ Tracking de ubicación detenido. Total puntos: ${_trayectoUbicaciones.length}');
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
      AuditItem('ATRASO DE LABOR E MAL IDENTIFICACION', 25),
      AuditItem('RETOLDEO', 15),
      AuditItem('CIRUGIA, SE ENCUENTRAN MELLIZOS', 15),
      AuditItem('FALTA DE PROTECTORES Y/O MAL COLOCADO', 20),
      AuditItem('SACUDIR BRACTEAS 2DA SUBIDA Y 3RA SUBIDA AL RACIMO', 25),
    ],
    'SELECCION': [
      AuditItem('MALA DISTRIBUCION Y/O DEJA PLANTAS SIN SELECTAR', 20),
      AuditItem('MALA SELECCION DE HIJOS', 20),
      AuditItem('DOBLE EN EXCESO', 20),
      AuditItem('MAL CANCELADOS', 20),
      AuditItem('NO GENERA DOBLES PERIFERICOS', 20),
    ],
    'DESHOJE FITOSANITARIO': [
      AuditItem('TEJIDO NECROTICO SIN CORTAR', 35),
      AuditItem('ELIMINAN TEJIDO VERDE Y/O CON ESTRIAS', 35),
      AuditItem('LA LONGITUD DE LA PALANCA NO ES LA CORRECTA', 30),
    ],
    'DESHOJE NORMAL': [
      AuditItem('HOJA TOCANDO RACIMO Y/O HOJA PUENTE SIN CORTAR', 35),
      AuditItem('ELIMINA HOJAS VERDES', 35),
      AuditItem('DEJA HOJA BAJERA', 30),
    ],
    'DESVIO DE HIJOS': [
      AuditItem('SIN DESVIAR', 50),
      AuditItem('HIJOS MALTRATADOS', 50),
    ],
    'APUNTALAMIENTO CON ZUNCHO': [
      AuditItem('ZUNCHO FLOJO Y/O MAL ANGULO MAL COLOCADO', 30),
      AuditItem(
        'MATAS CAIDAS MAYOR A 5% DEL ENFUNDE PROMEDIO SEMANAL DEL LOTE',
        30,
      ),
      AuditItem(
        'UTILIZA ESTAQUILLA PARA MEJORAR ANGULO DENTRO DE LA PLANTACION Y CABLE VIA',
        20,
      ),
      AuditItem(
          'AMARRE EN HIJOS Y/O EN PLANTAS CON RACIMOS +9 SEM O RESIEMBRAS', 20),
    ],
    'APUNTALAMIENTO CON PUNTAL': [
      AuditItem('PUNTAL FLOJO Y/O MAL ANGULO', 25),
      AuditItem(
        'MATAS CAIDAS MAYOR A 5% DEL ENFUNDE PROMEDIO SEMANAL DEL LOTE',
        25,
      ),
      AuditItem('UN PUNTAL', 20),
      AuditItem('PUNTAL ROZANDO RACIMO Y/O DAÑA PARTE BASAL DE LA HOJA', 15),
      AuditItem('PUNTAL PODRIDO', 15),
    ],
    'MANEJO DE AGUAS (RIEGO)': [
      AuditItem('CUMPLIMIENTO DE TURNOS DE RIEGO', 20),
      AuditItem('SE OBSERVAN TRIANGULOS SECOS', 20),
      AuditItem('SE OBSERVAN FUGAS', 20),
      AuditItem('FALTA DE ASPERSORES', 20),
      AuditItem('PRESION INADECUADA, NO HAY TRASLAPE (BAJA)', 20),
    ],
    'MANEJO DE AGUAS (DRENAJE)': [
      AuditItem('AGUAS RETENIDAS', 35),
      AuditItem('CANALES SUCIOS', 35),
      AuditItem('ENCHARCAMIENTO POR FALTA DE DRENAJE', 30),
    ],
    'FERTILIZACION': [
      AuditItem('MAL APLICADO Y/O MALA DISTRIBUCION', 35),
      AuditItem('APLICA SIN CAPACIDAD DE CAMPO', 35),
      AuditItem('SE APLICA CON CORONA SUCIA Y/O MATERIAL VERDE', 30),
    ],
    'CONTROL DE MALEZA': [
      AuditItem('MAL CONTROL', 35),
      AuditItem('MALA COBERTURA', 35),
      AuditItem('CANALES CON MALEZA EN DESCONTROL', 30),
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF00903E),
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
                  .take(2)
                  .map((entry) => _buildAuditSection(entry.key, entry.value))
                  .toList(),
              _buildCosechaSection(),
              ..._auditSections.entries
                  .skip(2)
                  .map((entry) => _buildAuditSection(entry.key, entry.value))
                  .toList(),
              const SizedBox(height: 8),
              _buildFinalScoreCard(),
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
                      if (_loteController.text.trim().isEmpty) {
                        _loteController.text = _formatFincaName(client);
                      }
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
                        labelText: 'Nombre, Apellido o Cédula',
                        hintText: _isClienteMode
                            ? 'Cliente autenticado'
                            : 'Ingrese nombre, apellido o cédula',
                        prefixIcon: Icon(
                          Icons.person,
                          color: _isClienteMode ? Colors.grey : null,
                        ),
                        border: const OutlineInputBorder(),
                        filled: _isClienteMode,
                        fillColor: _isClienteMode
                            ? Colors.grey.withOpacity(0.1)
                            : null,
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
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1),
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
                                  nombre.isEmpty
                                      ? 'Cliente sin nombre'
                                      : nombre,
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

  bool _isLikelyCedula(String value) {
    if (value.isEmpty) {
      return false;
    }
    return RegExp(r'^[0-9]+$').hasMatch(value);
  }

  Future<void> _fetchClientSuggestions(String query) async {
    try {
      if (_isLikelyCedula(query)) {
        final client = await _clientService.searchClientByCedula(query);
        if (!mounted || query != _lastQuery) {
          return;
        }
        setState(() {
          _clientSuggestions = client == null ? [] : [client];
        });
        return;
      }

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
    if (!mounted) {
      return;
    }

    if (_clientSuggestions.length == 1) {
      final client = _clientSuggestions.first;
      setState(() {
        _selectedClient = client;
        _clientSuggestions = [];
        if (_loteController.text.trim().isEmpty) {
          _loteController.text = _formatFincaName(client);
        }
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
          TextField(
            controller: _loteController,
            decoration: const InputDecoration(
              labelText: 'Lote de la evaluación',
              hintText: 'Ingrese lote',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.agriculture),
            ),
          ),
          const SizedBox(height: 16),
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
          children: [
            if (sectionName == 'SELECCION') ...[
              _buildSeleccionCriteriaCard(),
              const SizedBox(height: 12),
            ],
            ...items.map((item) => _buildAuditItem(item, sectionName)),
          ],
        ),
      ),
    );
  }

  Widget _buildAuditItem(AuditItem item, String sectionName) {
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
                    DropdownMenuItem(
                        value: 'Muy buena', child: Text('Muy buena (90-100%)')),
                    DropdownMenuItem(
                        value: 'Buena', child: Text('Buena (70-89%)')),
                    DropdownMenuItem(
                        value: 'Regular', child: Text('Regular (50-69%)')),
                    DropdownMenuItem(
                        value: 'Mala', child: Text('Mala (0-49%)')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      item.rating = value;
                      if (value != null) {
                        item.calculatedScore =
                            _calculateItemScore(item.maxScore, value);
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

  int _calculateItemScore(int maxScore, String rating) {
    switch (rating) {
      case 'Muy buena':
        return maxScore;
      case 'Buena':
        return (maxScore * 0.80).round();
      case 'Regular':
        return (maxScore * 0.60).round();
      case 'Mala':
        return 0;
    }
    return 0;
  }

  void _recalcularCosecha() {
    int total = 0;
    int bajoGrado = 0;
    int sobreGrado = 0;
    for (var edad in _cosechaEdades) {
      for (var cal in _cosechaCalibraciones) {
        final val =
            int.tryParse(_cosechaControllers[edad]![cal]!.text.trim()) ?? 0;
        total += val;
        if (cal <= 43) bajoGrado += val;
        if (cal >= 48) sobreGrado += val;
      }
    }
    setState(() {
      if (total > 0) {
        _cosechaPorcentajeBajoGrado = (bajoGrado / total) * 100;
        _cosechaPorcentajeSobreGrado = (sobreGrado / total) * 100;
      } else {
        _cosechaPorcentajeBajoGrado = 0;
        _cosechaPorcentajeSobreGrado = 0;
      }
      final double sumaDesviacion =
          _cosechaPorcentajeBajoGrado + _cosechaPorcentajeSobreGrado;

      if (sumaDesviacion <= 6.0) {
        _cosechaScore = 100;
      } else if (sumaDesviacion < 8.0) {
        _cosechaScore = 85;
      } else if (sumaDesviacion <= 9.0) {
        _cosechaScore = 70;
      } else {
        _cosechaScore = 0;
      }
    });
  }

  double _getSectionScore(String sectionName) {
    final items = _auditSections[sectionName];
    if (items == null) return 0;
    int scored = 0;
    int maxTotal = 0;
    for (var item in items) {
      maxTotal += item.maxScore;
      if (item.calculatedScore != null) scored += item.calculatedScore!;
    }
    if (maxTotal == 0) return 0;
    return (scored / maxTotal) * 100;
  }

  double _getGroupScore(List<String> sectionNames) {
    double total = 0;
    int count = 0;
    for (var name in sectionNames) {
      if (_auditSections.containsKey(name)) {
        total += _getSectionScore(name);
        count++;
      }
    }
    return count > 0 ? total / count : 0;
  }

  double _calculateFinalWeightedScore() {
    final bool enfundeEvaluado = _hasAnyRatedItem('ENFUNDE');
    final bool cosechaEvaluada = _hasCosechaData();

    final List<String> group1 = [
      'DESHOJE FITOSANITARIO',
      'DESHOJE NORMAL',
      'DESVIO DE HIJOS',
      'APUNTALAMIENTO CON ZUNCHO',
      'APUNTALAMIENTO CON PUNTAL',
    ];
    final List<String> group2 = [
      'MANEJO DE AGUAS (RIEGO)',
      'MANEJO DE AGUAS (DRENAJE)',
      'FERTILIZACION',
      'CONTROL DE MALEZA',
    ];

    final bool group1Evaluado = _hasAnyRatedItemInSections(group1);
    final bool group2Evaluado = _hasAnyRatedItemInSections(group2);

    final double enfundeScore = _getSectionScore('ENFUNDE');
    final double cosechaScore = _cosechaScore;
    final double group1Score = _getGroupScore(group1);
    final double group2Score = _getGroupScore(group2);

    final double rawWeighted = (enfundeScore * 0.15) +
        (cosechaScore * 0.35) +
        (group1Score * 0.25) +
        (group2Score * 0.25);

    if (!_isBasicMode) {
      return rawWeighted;
    }

    double usedWeight = 0;
    if (enfundeEvaluado) usedWeight += 0.15;
    if (cosechaEvaluada) usedWeight += 0.35;
    if (group1Evaluado) usedWeight += 0.25;
    if (group2Evaluado) usedWeight += 0.25;

    if (usedWeight == 0) {
      return 0;
    }

    return (rawWeighted / usedWeight).clamp(0, 100);
  }

  bool _hasAnyRatedItem(String sectionName) {
    final items = _auditSections[sectionName];
    if (items == null) return false;
    for (final item in items) {
      if (item.rating != null) {
        return true;
      }
    }
    return false;
  }

  bool _hasAnyRatedItemInSections(List<String> sectionNames) {
    for (final section in sectionNames) {
      if (_hasAnyRatedItem(section)) {
        return true;
      }
    }
    return false;
  }

  bool _hasCosechaData() {
    for (var edad in _cosechaEdades) {
      for (var cal in _cosechaCalibraciones) {
        final val =
            int.tryParse(_cosechaControllers[edad]![cal]!.text.trim()) ?? 0;
        if (val > 0) {
          return true;
        }
      }
    }
    return false;
  }

  Color _scoreColor(double score) {
    if (score >= 90) return Colors.green;
    if (score >= 70) return Colors.blue;
    if (score >= 50) return Colors.orange;
    return Colors.red;
  }

  String _scoreLabel(double score) {
    if (score >= 90) return 'Muy buena';
    if (score >= 70) return 'Buena';
    if (score >= 50) return 'Regular';
    return 'Mala';
  }

  Widget _buildFinalScoreCard() {
    final double enfundeScore = _getSectionScore('ENFUNDE');
    final List<String> group1 = [
      'DESHOJE FITOSANITARIO',
      'DESHOJE NORMAL',
      'DESVIO DE HIJOS',
      'APUNTALAMIENTO CON ZUNCHO',
      'APUNTALAMIENTO CON PUNTAL'
    ];
    final List<String> group2 = [
      'MANEJO DE AGUAS (RIEGO)',
      'MANEJO DE AGUAS (DRENAJE)',
      'FERTILIZACION',
      'CONTROL DE MALEZA'
    ];
    final double group1Score = _getGroupScore(group1);
    final double group2Score = _getGroupScore(group2);
    final double finalScore = _calculateFinalWeightedScore();
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF004B63),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('CALIFICACIÓN FINAL',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 1)),
          const SizedBox(height: 16),
          _buildScoreRow('Enfunde (15%)', enfundeScore),
          _buildScoreRow('Cosecha (35%)', _cosechaScore),
          _buildScoreRow('Labores de campo (25%)', group1Score),
          _buildScoreRow('Manejo agronómico (25%)', group2Score),
          const Divider(color: Colors.white38, height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('TOTAL',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${finalScore.toStringAsFixed(1)}%',
                      style: TextStyle(
                          color: _scoreColor(finalScore),
                          fontWeight: FontWeight.bold,
                          fontSize: 28)),
                  Text(_scoreLabel(finalScore),
                      style: TextStyle(
                          color: _scoreColor(finalScore),
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreRow(String label, double score) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 13)),
          Text('${score.toStringAsFixed(1)}%',
              style: TextStyle(
                  color: _scoreColor(score),
                  fontWeight: FontWeight.w600,
                  fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildCosechaSection() {
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
              offset: const Offset(0, 2))
        ],
        border: Border.all(
            color:
                _cosechaExpanded ? const Color(0xFF004B63) : Colors.grey[300]!,
            width: _cosechaExpanded ? 2 : 1),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: false,
          onExpansionChanged: (v) => setState(() => _cosechaExpanded = v),
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color:
                  _cosechaExpanded ? const Color(0xFF004B63) : Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
                _cosechaExpanded ? Icons.check_circle : Icons.expand_more,
                color: _cosechaExpanded ? Colors.white : Colors.grey[600]),
          ),
          title: Text('COSECHA',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _cosechaExpanded
                      ? const Color(0xFF004B63)
                      : Colors.black87)),
          subtitle: Text(
            'Calificación: ${_cosechaScore.toStringAsFixed(0)}/100  |  Bajo grado: ${_cosechaPorcentajeBajoGrado.toStringAsFixed(1)}%  Sobre grado: ${_cosechaPorcentajeSobreGrado.toStringAsFixed(1)}%',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          children: [
            const Text(
                'Ingrese cantidad de racimos por semana de edad y calibración:',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Wrap(spacing: 12, runSpacing: 4, children: [
              _buildCosechaLegend('Bajo grado ≤43', Colors.red[700]!),
              _buildCosechaLegend('Normal 44-47', Colors.green[700]!),
              _buildCosechaLegend('Sobre grado ≥48', Colors.orange[700]!),
            ]),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                children: [
                  // Header
                  Row(children: [
                    _cosechaHeaderCell('Sem.', const Color(0xFF004B63)),
                    _cosechaHeaderCell('Cinta', const Color(0xFF00903E),
                        width: 108),
                    ..._cosechaCalibraciones.map((cal) {
                      Color c = cal <= 43
                          ? Colors.red[700]!
                          : cal >= 48
                              ? Colors.orange[700]!
                              : Colors.green[700]!;
                      return _cosechaHeaderCell('$cal', c);
                    }),
                    _cosechaHeaderCell('Total', const Color(0xFF004B63)),
                  ]),
                  // Data rows
                  ..._cosechaEdades.map((edad) {
                    int rowTotal = _cosechaCalibraciones.fold(
                        0,
                        (s, cal) =>
                            s +
                            (int.tryParse(_cosechaControllers[edad]![cal]!
                                    .text
                                    .trim()) ??
                                0));
                    return Row(children: [
                      SizedBox(
                          width: 48,
                          height: 40,
                          child: Container(
                              color: const Color(0xFF004B63).withOpacity(0.12),
                              alignment: Alignment.center,
                              child: Text('$edad',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold)))),
                      SizedBox(
                        width: 108,
                        height: 40,
                        child: Container(
                          color: Colors.green[50],
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          alignment: Alignment.center,
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _cosechaColorCinta[edad],
                              hint: const Text('Color',
                                  style: TextStyle(fontSize: 12)),
                              isExpanded: true,
                              items: _coloresCinta
                                  .map(
                                    (color) => DropdownMenuItem<String>(
                                      value: color,
                                      child: Text(
                                        color,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _cosechaColorCinta[edad] = value;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                      ..._cosechaCalibraciones.map((cal) {
                        Color bg = cal <= 43
                            ? Colors.red[50]!
                            : cal >= 48
                                ? Colors.orange[50]!
                                : Colors.green[50]!;
                        return SizedBox(
                            width: 48,
                            height: 40,
                            child: Container(
                                color: bg,
                                padding: const EdgeInsets.all(2),
                                child: TextField(
                                  controller: _cosechaControllers[edad]![cal],
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 12),
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      isDense: true,
                                      hintText: '0',
                                      hintStyle: TextStyle(
                                          fontSize: 11, color: Colors.grey)),
                                )));
                      }),
                      SizedBox(
                          width: 52,
                          height: 40,
                          child: Container(
                              color: Colors.grey[100],
                              alignment: Alignment.center,
                              child: Text('$rowTotal',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold)))),
                    ]);
                  }),
                  // Totals row
                  Row(children: [
                    _cosechaHeaderCell('Total', const Color(0xFF004B63)),
                    _cosechaHeaderCell('', Colors.green[100]!, width: 108),
                    ..._cosechaCalibraciones.map((cal) {
                      int colTotal = _cosechaEdades.fold(
                          0,
                          (s, edad) =>
                              s +
                              (int.tryParse(_cosechaControllers[edad]![cal]!
                                      .text
                                      .trim()) ??
                                  0));
                      Color bg = cal <= 43
                          ? Colors.red[100]!
                          : cal >= 48
                              ? Colors.orange[100]!
                              : Colors.green[100]!;
                      return SizedBox(
                          width: 48,
                          height: 36,
                          child: Container(
                              color: bg,
                              alignment: Alignment.center,
                              child: Text('$colTotal',
                                  style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold))));
                    }),
                    Builder(builder: (ctx) {
                      int grand = 0;
                      for (var e in _cosechaEdades)
                        for (var c in _cosechaCalibraciones) {
                          grand += int.tryParse(
                                  _cosechaControllers[e]![c]!.text.trim()) ??
                              0;
                        }
                      return SizedBox(
                          width: 52,
                          height: 36,
                          child: Container(
                              color: Colors.grey[300],
                              alignment: Alignment.center,
                              child: Text('$grand',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold))));
                    }),
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8)),
              child: Column(children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('% Bajo grado (≤43):',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      Text('${_cosechaPorcentajeBajoGrado.toStringAsFixed(1)}%',
                          style: TextStyle(
                              color: Colors.red[700],
                              fontWeight: FontWeight.bold,
                              fontSize: 15)),
                    ]),
                const SizedBox(height: 6),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('% Sobre grado (≥48):',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      Text(
                          '${_cosechaPorcentajeSobreGrado.toStringAsFixed(1)}%',
                          style: TextStyle(
                              color: Colors.orange[700],
                              fontWeight: FontWeight.bold,
                              fontSize: 15)),
                    ]),
                const SizedBox(height: 6),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Suma (% bajo + % sobre):',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      Text(
                        '${(_cosechaPorcentajeBajoGrado + _cosechaPorcentajeSobreGrado).toStringAsFixed(1)}%',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ]),
                const Divider(height: 16),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Calificación COSECHA:',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                      Text('${_cosechaScore.toStringAsFixed(0)}/100',
                          style: TextStyle(
                              color: _scoreColor(_cosechaScore),
                              fontWeight: FontWeight.bold,
                              fontSize: 18)),
                    ]),
              ]),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _cosechaPhotoPath != null
                        ? 'Foto de cosecha adjunta'
                        : 'Adjunte una foto de la matriz de cosecha',
                    style: TextStyle(
                      color: _cosechaPhotoPath != null
                          ? Colors.green[700]
                          : Colors.grey[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _takeCosechaPhoto,
                  icon: const Icon(Icons.camera_alt, size: 16),
                  label: Text(
                    _cosechaPhotoPath != null ? 'Cambiar foto' : 'Tomar foto',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _cosechaPhotoPath != null
                        ? Colors.green
                        : const Color(0xFF004B63),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _cosechaHeaderCell(String text, Color color, {double width = 48}) {
    return SizedBox(
        width: width,
        height: 36,
        child: Container(
            color: color,
            alignment: Alignment.center,
            child: Text(text,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center)));
  }

  Widget _buildCosechaLegend(String label, Color color) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 12, height: 12, color: color),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(fontSize: 11)),
    ]);
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveAuditResults,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00903E),
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

  Future<void> _takeCosechaPhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
      );
      if (photo != null) {
        setState(() {
          _cosechaPhotoPath = photo.path;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto de cosecha capturada exitosamente'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al tomar la foto de cosecha: $e')),
      );
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
            content: Text(
                'Debe completar todas las evaluaciones ($completedItems/$totalItems)'),
          ),
        );
        return;
      }
    }

    final String loteEvaluacion = _loteController.text.trim();
    if (loteEvaluacion.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe ingresar el lote de la evaluación'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
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
          content: Text(
              'Debe tomar foto para todas las evaluaciones. Faltan: $preview$suffix'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    if (_hasCosechaData() && _cosechaPhotoPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe tomar una foto para la matriz de cosecha'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final String fincaCliente = _formatFincaName(_selectedClient!);
    final String hacienda = fincaCliente.isNotEmpty
        ? fincaCliente
        : (_selectedClient!['hacienda']?.toString().isNotEmpty == true
            ? _selectedClient!['hacienda'].toString()
            : 'No especificada');
    final String cultivo = _selectedCrop;
    final String tipoAuditoria = _isBasicMode ? 'Básica' : 'Completa';
    final String clienteNombre =
        '${_selectedClient!['nombre']} ${_selectedClient!['apellidos']}';
    final String cedulaCliente = _selectedClient!['cedula'] as String;
    final String fechaAuditoria = DateTime.now().toIso8601String();

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
    auditData['Hacienda'] = hacienda;
    auditData['Cultivo'] = cultivo;
    auditData['TipoAuditoria'] = tipoAuditoria;
    auditData['Lote'] = loteEvaluacion;
    auditData['SeleccionResumen'] = {
      'totalPlantas':
          int.tryParse(_seleccionTotalPlantasController.text.trim()) ?? 0,
      'plantasMalSeleccionadas':
          int.tryParse(_seleccionMalSeleccionadasController.text.trim()) ?? 0,
      'porcentajeMalSeleccionadas': _seleccionPorcentaje,
      'observacion': _seleccionObservacionController.text.trim(),
    };
    auditData['CosechaResumen'] = {
      'porcentajeBajoGrado': _cosechaPorcentajeBajoGrado,
      'porcentajeSobreGrado': _cosechaPorcentajeSobreGrado,
      'sumaPorcentajes':
          _cosechaPorcentajeBajoGrado + _cosechaPorcentajeSobreGrado,
      'calificacion': _cosechaScore,
      'photoPath': _cosechaPhotoPath,
      'colorCintaPorSemana': {
        for (final edad in _cosechaEdades)
          edad.toString(): _cosechaColorCinta[edad],
      },
    };

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

    final int tecnicoId = await _authService.getUserId() ?? 1;
    final String observacionesGenerales =
        'Auditoría ${_isBasicMode ? 'básica' : 'completa'} de $_selectedCrop - Lote: $loteEvaluacion';

    bool savedToBackend = false;
    try {
      final scores =
          await AuditService.buildBackendScoresFromAuditMap(auditData);
      final result = await _auditService.createAuditBackend(
        hacienda: hacienda,
        cultivo: cultivo,
        fecha: fechaAuditoria,
        tecnicoId: tecnicoId,
        estado: 'COMPLETADA',
        observaciones: observacionesGenerales,
        scores: scores,
        cedulaCliente: cedulaCliente,
        trayectoUbicaciones: _trayectoUbicaciones,
        evaluaciones: auditData,
      );
      savedToBackend = result['success'] == true;
    } catch (_) {
      savedToBackend = false;
    }

    if (!savedToBackend) {
      await _offlineStorageCampo.savePendingAudit(
        cedulaCliente: cedulaCliente,
        clientId: clientId,
        categoryId: categoryId,
        auditDate: fechaAuditoria,
        status: 'COMPLETADA',
        auditData: [auditData],
        observations: observacionesGenerales,
        trayectoUbicaciones: _trayectoUbicaciones,
        inicioEvaluacion: _inicioEvaluacion?.toIso8601String(),
        finEvaluacion: DateTime.now().toIso8601String(),
      );
    }

    // Detener tracking después de guardar
    _detenerTrackingUbicacion();

    // Calcular puntuación solo sobre los ítems completados
    final double percentage = _calculateFinalWeightedScore();

    final String mensaje = '''
    Auditoría guardada exitosamente:

    Cliente: $clienteNombre
    Cédula: $cedulaCliente
    Finca: $hacienda
    Lote: $loteEvaluacion
    Cultivo: ${cultivo.toUpperCase()}
    Tipo: $tipoAuditoria

    ───────────────────────────────
    PUNTUACIÓN FINAL: ${percentage.toStringAsFixed(1)}%
    ───────────────────────────────
    Elementos evaluados: $completedItems/$totalItems

    ${savedToBackend ? 'Los datos se guardaron en el backend.' : 'Los datos se guardaron localmente y se sincronizarán cuando haya conexión.'}
    ''';

    await _limpiarBorrador();

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

  double get _seleccionPorcentaje {
    final total =
        int.tryParse(_seleccionTotalPlantasController.text.trim()) ?? 0;
    final mal =
        int.tryParse(_seleccionMalSeleccionadasController.text.trim()) ?? 0;
    if (total <= 0) {
      return 0;
    }
    return (mal / total) * 100;
  }

  Widget _buildSeleccionCriteriaCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF004B63).withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF004B63).withOpacity(0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Criterio de selección',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF004B63),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _seleccionTotalPlantasController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: '# total de plantas',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _seleccionMalSeleccionadasController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: '# mal selectadas',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _seleccionObservacionController,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Observación',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 10),
          Text(
            'Porcentaje: ${_seleccionPorcentaje.toStringAsFixed(1)}%  (# mal selectadas / # total de plantas)',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF004B63),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _guardarBorrador() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final draft = <String, dynamic>{
        'selectedClient': _selectedClient,
        'nombre': _nombreController.text,
        'lote': _loteController.text,
        'isBasicMode': _isBasicMode,
        'selectedCrop': _selectedCrop,
        'expandedSections': _expandedSections,
        'seleccionTotalPlantas': _seleccionTotalPlantasController.text,
        'seleccionMalSeleccionadas': _seleccionMalSeleccionadasController.text,
        'seleccionObservacion': _seleccionObservacionController.text,
        'cosechaPhotoPath': _cosechaPhotoPath,
        'cosechaColorCinta': {
          for (final edad in _cosechaEdades)
            edad.toString(): _cosechaColorCinta[edad],
        },
        'auditSections': {
          for (final entry in _auditSections.entries)
            entry.key: entry.value
                .map(
                  (item) => {
                    'rating': item.rating,
                    'calculatedScore': item.calculatedScore,
                    'photoPath': item.photoPath,
                    'observaciones': item.observaciones,
                  },
                )
                .toList(),
        },
        'cosechaValues': {
          for (final edad in _cosechaEdades)
            edad.toString(): {
              for (final cal in _cosechaCalibraciones)
                cal.toString(): _cosechaControllers[edad]![cal]!.text,
            },
        },
      };
      await prefs.setString(_draftKey, jsonEncode(draft));
    } catch (_) {}
  }

  Future<void> _restaurarBorrador() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_draftKey);
      if (raw == null || raw.isEmpty || !mounted) {
        return;
      }

      final draft = jsonDecode(raw) as Map<String, dynamic>;
      setState(() {
        final selectedClientRaw = draft['selectedClient'];
        if (_selectedClient == null && selectedClientRaw is Map) {
          _selectedClient = Map<String, dynamic>.from(selectedClientRaw);
        }
        _nombreController.text =
            draft['nombre']?.toString() ?? _nombreController.text;
        _loteController.text = draft['lote']?.toString() ?? '';
        _isBasicMode = draft['isBasicMode'] as bool? ?? _isBasicMode;
        _selectedCrop = draft['selectedCrop']?.toString() ?? _selectedCrop;
        _seleccionTotalPlantasController.text =
            draft['seleccionTotalPlantas']?.toString() ?? '';
        _seleccionMalSeleccionadasController.text =
            draft['seleccionMalSeleccionadas']?.toString() ?? '';
        _seleccionObservacionController.text =
            draft['seleccionObservacion']?.toString() ?? '';
        _cosechaPhotoPath = draft['cosechaPhotoPath']?.toString();

        final expandedSections = draft['expandedSections'];
        if (expandedSections is Map) {
          _expandedSections
            ..clear()
            ..addAll(
              expandedSections.map(
                (key, value) => MapEntry(key.toString(), value == true),
              ),
            );
        }

        final auditSections = draft['auditSections'];
        if (auditSections is Map) {
          for (final entry in _auditSections.entries) {
            final savedItems = auditSections[entry.key];
            if (savedItems is List) {
              for (int i = 0;
                  i < entry.value.length && i < savedItems.length;
                  i++) {
                final savedItem =
                    Map<String, dynamic>.from(savedItems[i] as Map);
                entry.value[i].rating = savedItem['rating']?.toString();
                entry.value[i].calculatedScore = int.tryParse(
                    (savedItem['calculatedScore'] ?? '').toString());
                entry.value[i].photoPath = savedItem['photoPath']?.toString();
                entry.value[i].observaciones =
                    savedItem['observaciones']?.toString();
              }
            }
          }
        }

        final cosechaValues = draft['cosechaValues'];
        if (cosechaValues is Map) {
          for (final edad in _cosechaEdades) {
            final row = cosechaValues[edad.toString()];
            if (row is Map) {
              for (final cal in _cosechaCalibraciones) {
                _cosechaControllers[edad]![cal]!.text =
                    row[cal.toString()]?.toString() ?? '';
              }
            }
          }
        }

        final colorCinta = draft['cosechaColorCinta'];
        if (colorCinta is Map) {
          for (final edad in _cosechaEdades) {
            _cosechaColorCinta[edad] = colorCinta[edad.toString()]?.toString();
          }
        }
      });

      _recalcularCosecha();
    } catch (_) {}
  }

  Future<void> _limpiarBorrador() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_draftKey);
    } catch (_) {}
  }
}
