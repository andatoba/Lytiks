import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/client_service.dart';
import '../services/hacienda_service.dart';

class ClientInfoScreen extends StatefulWidget {
  final Map<String, dynamic>? clientData;
  const ClientInfoScreen({Key? key, this.clientData}) : super(key: key);

  @override
  State<ClientInfoScreen> createState() => _ClientInfoScreenState();
}

class _ClientInfoScreenState extends State<ClientInfoScreen>
    with WidgetsBindingObserver {
  static const String _draftKey = 'client_info_draft';
  final Set<int> _loadedFincaIds = <int>{};
  void _enviarSmsExitoso() {
    final telefono = _telefonoController.text.trim();
    if (telefono.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'SMS enviado a $telefono: "¡Tus datos han sido guardados exitosamente!"'),
            backgroundColor: const Color(0xFF00903E)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('No se pudo enviar SMS: teléfono no registrado'),
            backgroundColor: Colors.orange),
      );
    }
  }

  int? _clienteId;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _obtenerUbicacion();
    _restaurarBorrador();
  }

  Future<void> _obtenerUbicacion() async {
    LocationPermission permission;
    bool serviceEnabled;
    try {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Por favor activa los servicios de ubicación en tu dispositivo.'),
                backgroundColor: Colors.orange),
          );
        }
        return;
      }
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Permiso de ubicación denegado.'),
                  backgroundColor: Colors.red),
            );
          }
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Permiso de ubicación denegado permanentemente. Ve a configuración para activarlo.'),
                backgroundColor: Colors.red),
          );
        }
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      if (mounted) {
        setState(() {
          _currentPosition = pos;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error al obtener ubicación: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  final ClientService _clientService = ClientService();
  final HaciendaService _haciendaService = HaciendaService();
  bool _hasInternet = true;
  bool _isSaving = false;
  bool _isLoadingLocation = false;
  Position? _currentPosition;

  // Lista dinámica de fincas
  final List<_FincaEntry> _fincas = [_FincaEntry()];

  final _cedulaController = TextEditingController();
  final _nombreController = TextEditingController();
  final _apellidosController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _emailController = TextEditingController();
  final _direccionController = TextEditingController();
  final _parroquiaController = TextEditingController();
  final _cultivosPrincipalesController = TextEditingController();
  // ...existing code...
  final _observacionesController = TextEditingController();
  final _tecnicoAsignadoIdController = TextEditingController();

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _guardarBorrador();
    _cedulaController.dispose();
    _nombreController.dispose();
    _apellidosController.dispose();
    _telefonoController.dispose();
    _emailController.dispose();
    _direccionController.dispose();
    _parroquiaController.dispose();
    _cultivosPrincipalesController.dispose();
    for (final finca in _fincas) {
      finca.dispose();
    }
    // ...existing code...
    _observacionesController.dispose();
    _tecnicoAsignadoIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cliente'),
        backgroundColor: const Color(0xFF00903E),
        foregroundColor: Colors.white,
        actions: [
          Icon(
            _hasInternet ? Icons.wifi : Icons.wifi_off,
            color: _hasInternet ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mapa y coordenadas, solo si hay ubicación
            if (_currentPosition != null) ...[
              const Text(
                'Ubicación del Cultivo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF004B63),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 4,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    height: 250,
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: LatLng(_currentPosition!.latitude,
                            _currentPosition!.longitude),
                        initialZoom: 16.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                          userAgentPackageName: 'com.lytiks.app',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: LatLng(_currentPosition!.latitude,
                                  _currentPosition!.longitude),
                              width: 60,
                              height: 60,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF004B63),
                                  shape: BoxShape.circle,
                                  border:
                                      Border.all(color: Colors.white, width: 3),
                                ),
                                child: const Icon(
                                  Icons.agriculture,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF004B63).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Color(0xFF004B63)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Lat: ${_currentPosition!.latitude.toStringAsFixed(6)}°',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Lng: ${_currentPosition!.longitude.toStringAsFixed(6)}°',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ] else ...[
              const Text('Ubicación no disponible',
                  style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 20),
            ],
            // El formulario de cliente inicia aquí
            _buildTextField(
              controller: _cedulaController,
              label: 'Cédula',
              icon: Icons.badge,
              required: true,
              keyboardType: TextInputType.number,
              suffixIcon: IconButton(
                icon: const Icon(Icons.search),
                onPressed: () async {
                  final cedula = _cedulaController.text.trim();
                  if (cedula.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Ingrese una cédula para buscar.'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    return;
                  }

                  // Mostrar indicador de carga
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const AlertDialog(
                      content: Row(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(width: 16),
                          Text('Buscando cliente...'),
                        ],
                      ),
                    ),
                  );

                  try {
                    final client =
                        await _clientService.searchClientByCedula(cedula);

                    // Cerrar diálogo de carga
                    Navigator.of(context).pop();

                    if (client != null) {
                      setState(() {
                        _clienteId = client['id'];
                        _nombreController.text = client['nombre'] ?? '';
                        _apellidosController.text = client['apellidos'] ?? '';
                        _telefonoController.text = client['telefono'] ?? '';
                        _emailController.text = client['email'] ?? '';
                        _direccionController.text = client['direccion'] ?? '';
                        _parroquiaController.text = client['parroquia'] ?? '';
                        _cultivosPrincipalesController.text =
                            client['tipoCultivo'] ??
                                client['cultivosPrincipales'] ??
                                '';
                        _observacionesController.text =
                            client['observaciones'] ?? '';
                        _tecnicoAsignadoIdController.text =
                            client['tecnicoAsignadoId']?.toString() ?? '';

                        if (client['geolocalizacionLat'] != null &&
                            client['geolocalizacionLng'] != null) {
                          _currentPosition = Position(
                            latitude: client['geolocalizacionLat'],
                            longitude: client['geolocalizacionLng'],
                            timestamp: DateTime.now(),
                            accuracy: 0,
                            altitude: 0,
                            heading: 0,
                            speed: 0,
                            speedAccuracy: 0,
                            altitudeAccuracy: 0,
                            headingAccuracy: 0,
                          );
                        }
                      });

                      // Cargar fincas del cliente
                      _cargarFincasDelCliente(client['id']);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Cliente encontrado y cargado.'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'No se encontró ningún cliente con esta cédula'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    }
                  } catch (e) {
                    // Cerrar diálogo de carga si hay error
                    Navigator.of(context).pop();

                    String errorMessage = 'Error al buscar cliente';
                    if (e.toString().contains('Failed to fetch') ||
                        e.toString().contains('Error de conexión')) {
                      errorMessage =
                          'No se pudo conectar con el servidor. Por favor:\n'
                          '1. Verifique su conexión a internet\n'
                          '2. Compruebe que el servidor esté en línea\n'
                          '3. Intente nuevamente en unos momentos';
                    } else {
                      errorMessage = 'Error al buscar cliente: $e';
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(errorMessage),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 5),
                        action: SnackBarAction(
                          label: 'OK',
                          textColor: Colors.white,
                          onPressed: () {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          },
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
            _buildTextField(
                controller: _nombreController,
                label: 'Nombre',
                icon: Icons.person,
                required: true),
            const SizedBox(height: 12),
            _buildTextField(
                controller: _apellidosController,
                label: 'Apellidos',
                icon: Icons.person_outline,
                required: false),
            // eliminado departamento
            _buildTextField(
                controller: _telefonoController,
                label: 'Teléfono',
                icon: Icons.phone,
                required: false,
                keyboardType: TextInputType.phone),
            const SizedBox(height: 12),
            _buildTextField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email,
                required: false,
                keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 12),
            _buildTextField(
                controller: _direccionController,
                label: 'Dirección',
                icon: Icons.location_on,
                required: false),
            const SizedBox(height: 12),
            _buildTextField(
                controller: _parroquiaController,
                label: 'Parroquia',
                icon: Icons.location_city,
                required: false),
            const SizedBox(height: 12),
            const SizedBox(height: 12),
            _buildFincasSection(),
            const SizedBox(height: 12),
            _buildTextField(
                controller: _cultivosPrincipalesController,
                label: 'Cultivos Principales',
                icon: Icons.agriculture,
                required: false),
            const SizedBox(height: 12),
            // ...existing code...
            _buildTextField(
                controller: _observacionesController,
                label: 'Observaciones',
                icon: Icons.notes,
                required: false),
            const SizedBox(height: 12),
            _buildTextField(
                controller: _tecnicoAsignadoIdController,
                label: 'ID Técnico Asignado',
                icon: Icons.engineering,
                required: false,
                keyboardType: TextInputType.number),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoadingLocation
                        ? null
                        : () async {
                            // ACTUALIZAR CLIENTE
                            setState(() {
                              _isLoadingLocation = true;
                            });
                            try {
                              final clientService = ClientService();
                              if (_clienteId == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Primero busque y cargue un cliente por cédula.'),
                                      backgroundColor: Colors.orange),
                                );
                                return;
                              }
                              final clientData = {
                                'nombre': _nombreController.text.trim(),
                                'apellidos': _apellidosController.text.trim(),
                                'telefono': _telefonoController.text.trim(),
                                'email': _emailController.text.trim(),
                                'direccion': _direccionController.text.trim(),
                                'parroquia': _parroquiaController.text.trim(),
                                'fincaNombre': _fincas.isNotEmpty
                                    ? _fincas.first.nombreController.text.trim()
                                    : '',
                                'fincaHectareas': _fincas.isNotEmpty &&
                                        _fincas.first.hectareasController.text
                                            .isNotEmpty
                                    ? double.tryParse(
                                        _fincas.first.hectareasController.text)
                                    : null,
                                'cultivosPrincipales':
                                    _cultivosPrincipalesController.text.trim(),
                                'geolocalizacionLat':
                                    _currentPosition?.latitude,
                                'geolocalizacionLng':
                                    _currentPosition?.longitude,
                                'observaciones':
                                    _observacionesController.text.trim(),
                                'tecnicoAsignadoId':
                                    _tecnicoAsignadoIdController.text.isNotEmpty
                                        ? int.tryParse(
                                            _tecnicoAsignadoIdController.text)
                                        : null,
                              };
                              final result = await clientService.updateClient(
                                  id: _clienteId!, clientData: clientData);
                              if (result['success'] == true) {
                                // Guardar fincas en tabla hacienda
                                await _guardarFincasDelCliente(_clienteId!);
                                _limpiarBorrador();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(result['message'] ??
                                          'Cliente actualizado exitosamente'),
                                      backgroundColor: Colors.green),
                                );
                                _enviarSmsExitoso();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(result['message'] ??
                                          'Error al actualizar cliente'),
                                      backgroundColor: Colors.red),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('Error: $e'),
                                    backgroundColor: Colors.red),
                              );
                            } finally {
                              setState(() {
                                _isLoadingLocation = false;
                              });
                            }
                          },
                    icon: _isLoadingLocation
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.refresh),
                    label: Text(
                        _isLoadingLocation ? 'Actualizando...' : 'Actualizar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade600,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isSaving
                        ? null
                        : () async {
                            setState(() {
                              _isSaving = true;
                            });
                            try {
                              final clientData = {
                                'cedula': _cedulaController.text.trim(),
                                'nombre': _nombreController.text.trim(),
                                'apellidos': _apellidosController.text.trim(),
                                'telefono': _telefonoController.text.trim(),
                                'email': _emailController.text.trim(),
                                'direccion': _direccionController.text.trim(),
                                'parroquia': _parroquiaController.text.trim(),
                                'fincaNombre': _fincas.isNotEmpty
                                    ? _fincas.first.nombreController.text.trim()
                                    : '',
                                'fincaHectareas': _fincas.isNotEmpty &&
                                        _fincas.first.hectareasController.text
                                            .isNotEmpty
                                    ? double.tryParse(
                                        _fincas.first.hectareasController.text)
                                    : null,
                                'cultivosPrincipales':
                                    _cultivosPrincipalesController.text.trim(),
                                'geolocalizacionLat':
                                    _currentPosition?.latitude,
                                'geolocalizacionLng':
                                    _currentPosition?.longitude,
                                'observaciones':
                                    _observacionesController.text.trim(),
                                'tecnicoAsignadoId':
                                    _tecnicoAsignadoIdController.text.isNotEmpty
                                        ? int.tryParse(
                                            _tecnicoAsignadoIdController.text)
                                        : null,
                              };
                              final result =
                                  await _clientService.createClient(clientData);
                              if (result['success'] == true) {
                                // Guardar fincas adicionales en tabla hacienda
                                final newClientId = result['clientId'];
                                if (newClientId != null) {
                                  await _guardarFincasDelCliente(
                                      newClientId is int
                                          ? newClientId
                                          : int.parse(newClientId.toString()));
                                }
                                _limpiarBorrador();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(result['message'] ??
                                          'Cliente guardado exitosamente'),
                                      backgroundColor: Colors.green),
                                );
                                _enviarSmsExitoso();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(result['message'] ??
                                          'Error al guardar cliente'),
                                      backgroundColor: Colors.red),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('Error: $e'),
                                    backgroundColor: Colors.red),
                              );
                            } finally {
                              setState(() {
                                _isSaving = false;
                              });
                            }
                          },
                    icon: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white)))
                        : const Icon(Icons.save),
                    label: Text(_isSaving ? 'Guardando...' : 'Guardar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00903E),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool required,
    TextInputType? keyboardType,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label + (required ? ' *' : ''),
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(),
        suffixIcon: suffixIcon,
      ),
    );
  }

  // ── Persistencia de borrador al salir de la app ──

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _guardarBorrador();
    }
  }

  Future<void> _guardarBorrador() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final draft = {
        'cedula': _cedulaController.text,
        'nombre': _nombreController.text,
        'apellidos': _apellidosController.text,
        'telefono': _telefonoController.text,
        'email': _emailController.text,
        'direccion': _direccionController.text,
        'parroquia': _parroquiaController.text,
        'cultivosPrincipales': _cultivosPrincipalesController.text,
        'observaciones': _observacionesController.text,
        'tecnicoAsignadoId': _tecnicoAsignadoIdController.text,
        'clienteId': _clienteId,
        'fincas': _fincas
            .map((f) => {
                  'id': f.id,
                  'nombre': f.nombreController.text,
                  'hectareas': f.hectareasController.text,
                  'detalle': f.detalleController.text,
                  'lotes': f.lotes
                      .map((l) => {
                            'nombre': l.nombreController.text,
                            'codigo': l.codigoController.text,
                            'hectareas': l.hectareasController.text,
                          })
                      .toList(),
                })
            .toList(),
      };
      await prefs.setString(_draftKey, jsonEncode(draft));
    } catch (_) {}
  }

  Future<void> _restaurarBorrador() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_draftKey);
      if (raw == null || raw.isEmpty) return;
      final draft = jsonDecode(raw) as Map<String, dynamic>;

      // Si ya hay algo en los campos (viene de clientData), no sobreescribir
      if (_cedulaController.text.isNotEmpty) return;

      setState(() {
        _cedulaController.text = draft['cedula'] ?? '';
        _nombreController.text = draft['nombre'] ?? '';
        _apellidosController.text = draft['apellidos'] ?? '';
        _telefonoController.text = draft['telefono'] ?? '';
        _emailController.text = draft['email'] ?? '';
        _direccionController.text = draft['direccion'] ?? '';
        _parroquiaController.text = draft['parroquia'] ?? '';
        _cultivosPrincipalesController.text =
            draft['cultivosPrincipales'] ?? '';
        _observacionesController.text = draft['observaciones'] ?? '';
        _tecnicoAsignadoIdController.text = draft['tecnicoAsignadoId'] ?? '';
        _clienteId = draft['clienteId'];

        final fincasRaw = draft['fincas'] as List<dynamic>?;
        if (fincasRaw != null && fincasRaw.isNotEmpty) {
          for (final f in _fincas) {
            f.dispose();
          }
          _fincas.clear();
          for (final fRaw in fincasRaw) {
            final fMap = fRaw as Map<String, dynamic>;
            final lotesList = <_LoteEntry>[];
            final lotesRaw = fMap['lotes'] as List<dynamic>?;
            if (lotesRaw != null) {
              for (final lRaw in lotesRaw) {
                final lMap = lRaw as Map<String, dynamic>;
                lotesList.add(_LoteEntry(
                  nombre: lMap['nombre'] ?? '',
                  codigo: lMap['codigo'] ?? '',
                  hectareas: lMap['hectareas'] ?? '',
                ));
              }
            }
            _fincas.add(_FincaEntry(
              id: fMap['id'],
              nombre: fMap['nombre'] ?? '',
              hectareas: fMap['hectareas'] ?? '',
              detalle: fMap['detalle'] ?? '',
              lotes: lotesList,
            ));
          }
        }
      });
    } catch (_) {}
  }

  Future<void> _limpiarBorrador() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_draftKey);
    } catch (_) {}
  }

  // ── Sección dinámica de fincas ──

  Widget _buildFincasSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.home_work, color: Color(0xFF00903E)),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Fincas del Cliente',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF004B63)),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _fincas.add(_FincaEntry());
                    });
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Agregar finca'),
                  style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF00903E)),
                ),
              ],
            ),
            const Divider(),
            for (int i = 0; i < _fincas.length; i++) ...[
              _buildFincaItem(i),
              if (i < _fincas.length - 1) const Divider(height: 24),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFincaItem(int index) {
    final finca = _fincas[index];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Finca ${index + 1}',
              style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Color(0xFF004B63)),
            ),
            if (finca.id != null)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text('(guardada)',
                    style: TextStyle(fontSize: 11, color: Colors.grey[500])),
              ),
            const Spacer(),
            if (_fincas.length > 1)
              IconButton(
                icon: const Icon(Icons.delete_outline,
                    color: Colors.red, size: 20),
                onPressed: () {
                  setState(() {
                    _fincas[index].dispose();
                    _fincas.removeAt(index);
                  });
                },
                tooltip: 'Eliminar finca',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: finca.nombreController,
          decoration: const InputDecoration(
            labelText: 'Nombre de la Finca',
            prefixIcon: Icon(Icons.home),
            border: OutlineInputBorder(),
            isDense: true,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: finca.hectareasController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Hectáreas totales de la Finca',
            prefixIcon: Icon(Icons.terrain),
            border: OutlineInputBorder(),
            isDense: true,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: finca.detalleController,
          decoration: const InputDecoration(
            labelText: 'Detalle / Ubicación',
            prefixIcon: Icon(Icons.info_outline),
            border: OutlineInputBorder(),
            isDense: true,
          ),
        ),
        const SizedBox(height: 10),
        // ── Lotes de esta finca ──
        _buildLotesSection(finca),
      ],
    );
  }

  Widget _buildLotesSection(_FincaEntry finca) {
    return Container(
      margin: const EdgeInsets.only(left: 16),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.grid_view, size: 16, color: Color(0xFF00903E)),
              const SizedBox(width: 6),
              const Text('Lotes',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: Color(0xFF004B63))),
              const Spacer(),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    finca.lotes.add(_LoteEntry());
                  });
                },
                icon: const Icon(Icons.add, size: 16),
                label:
                    const Text('Agregar lote', style: TextStyle(fontSize: 12)),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF00903E),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
          if (finca.lotes.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text('Sin lotes. Toque "Agregar lote" para añadir.',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500])),
            ),
          for (int i = 0; i < finca.lotes.length; i++) ...[
            if (i > 0) const Divider(height: 16),
            _buildLoteItem(finca, i),
          ],
        ],
      ),
    );
  }

  Widget _buildLoteItem(_FincaEntry finca, int index) {
    final lote = finca.lotes[index];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Lote ${index + 1}',
                style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: Color(0xFF004B63))),
            const Spacer(),
            if (finca.lotes.length > 1)
              IconButton(
                icon: const Icon(Icons.close, color: Colors.red, size: 16),
                onPressed: () {
                  setState(() {
                    finca.lotes[index].dispose();
                    finca.lotes.removeAt(index);
                  });
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: 'Eliminar lote',
              ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextField(
                controller: lote.nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                  isDense: true,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                ),
                style: const TextStyle(fontSize: 13),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: lote.codigoController,
                decoration: const InputDecoration(
                  labelText: 'Código',
                  border: OutlineInputBorder(),
                  isDense: true,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                ),
                style: const TextStyle(fontSize: 13),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: lote.hectareasController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Ha.',
                  border: OutlineInputBorder(),
                  isDense: true,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                ),
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _cargarFincasDelCliente(dynamic clienteId) async {
    try {
      final id = clienteId is int ? clienteId : int.parse(clienteId.toString());
      final haciendas = await _haciendaService.getHaciendasByCliente(id);
      if (!mounted) return;
      setState(() {
        _loadedFincaIds
          ..clear()
          ..addAll(
            haciendas
                .map((h) => int.tryParse((h['id'] ?? '').toString()))
                .whereType<int>(),
          );
        for (final f in _fincas) {
          f.dispose();
        }
        _fincas.clear();
        if (haciendas.isEmpty) {
          _fincas.add(_FincaEntry());
        } else {
          for (final h in haciendas) {
            final lotesList = <_LoteEntry>[];
            // Parsear lotes del campo detalle (JSON)
            final detalleRaw = h['detalle']?.toString() ?? '';
            String detalleTexto = detalleRaw;
            try {
              if (detalleRaw.startsWith('{') || detalleRaw.startsWith('[')) {
                final parsed = jsonDecode(detalleRaw);
                if (parsed is Map && parsed.containsKey('lotes')) {
                  detalleTexto = parsed['descripcion']?.toString() ?? '';
                  final lotesRaw = parsed['lotes'] as List<dynamic>?;
                  if (lotesRaw != null) {
                    for (final lr in lotesRaw) {
                      final lm = lr as Map<String, dynamic>;
                      lotesList.add(_LoteEntry(
                        nombre: lm['nombre'] ?? '',
                        codigo: lm['codigo'] ?? '',
                        hectareas: lm['hectareas']?.toString() ?? '',
                      ));
                    }
                  }
                }
              }
            } catch (_) {}

            _fincas.add(_FincaEntry(
              id: h['id'],
              nombre: h['nombre']?.toString() ?? '',
              hectareas: h['hectareas']?.toString() ?? '',
              detalle: detalleTexto,
              lotes: lotesList,
            ));
          }
        }

        if (_fincas.isEmpty &&
            widget.clientData != null &&
            (widget.clientData!['nombreFinca']?.toString().isNotEmpty == true ||
                widget.clientData!['fincaNombre']?.toString().isNotEmpty ==
                    true)) {
          _fincas.add(
            _FincaEntry(
              nombre: (widget.clientData!['nombreFinca'] ??
                      widget.clientData!['fincaNombre'] ??
                      '')
                  .toString(),
              hectareas:
                  (widget.clientData!['fincaHectareas'] ?? '').toString(),
            ),
          );
        }
      });
    } catch (e) {
      debugPrint('Error cargando fincas: $e');
    }
  }

  Future<void> _guardarFincasDelCliente(int clienteId) async {
    final Set<int> fincasActuales =
        _fincas.map((finca) => finca.id).whereType<int>().toSet();

    final Set<int> fincasEliminadas =
        _loadedFincaIds.difference(fincasActuales);
    for (final fincaId in fincasEliminadas) {
      await _haciendaService.deleteHacienda(fincaId);
    }

    for (final finca in _fincas) {
      final nombre = finca.nombreController.text.trim();
      if (nombre.isEmpty) continue;
      final hectareas = double.tryParse(finca.hectareasController.text.trim());
      final detalleTexto = finca.detalleController.text.trim();

      // Serializar lotes dentro del detalle como JSON
      String? detalle;
      if (finca.lotes.isNotEmpty &&
          finca.lotes.any((l) => l.nombreController.text.trim().isNotEmpty)) {
        final lotesJson = finca.lotes
            .where((l) => l.nombreController.text.trim().isNotEmpty)
            .map((l) => {
                  'nombre': l.nombreController.text.trim(),
                  'codigo': l.codigoController.text.trim(),
                  'hectareas':
                      double.tryParse(l.hectareasController.text.trim()),
                })
            .toList();
        detalle = jsonEncode({
          'descripcion': detalleTexto,
          'lotes': lotesJson,
        });
      } else {
        detalle = detalleTexto.isNotEmpty ? detalleTexto : null;
      }

      if (finca.id != null) {
        await _haciendaService.updateHacienda(
          id: finca.id!,
          nombre: nombre,
          hectareas: hectareas,
          detalle: detalle,
        );
      } else {
        await _haciendaService.createHacienda(
          nombre: nombre,
          clienteId: clienteId,
          hectareas: hectareas,
          detalle: detalle,
        );
      }
    }

    await _cargarFincasDelCliente(clienteId);
  }
}

class _FincaEntry {
  int? id;
  final TextEditingController nombreController;
  final TextEditingController hectareasController;
  final TextEditingController detalleController;
  final List<_LoteEntry> lotes;

  _FincaEntry({
    this.id,
    String nombre = '',
    String hectareas = '',
    String detalle = '',
    List<_LoteEntry>? lotes,
  })  : nombreController = TextEditingController(text: nombre),
        hectareasController = TextEditingController(text: hectareas),
        detalleController = TextEditingController(text: detalle),
        lotes = lotes ?? [];

  void dispose() {
    nombreController.dispose();
    hectareasController.dispose();
    detalleController.dispose();
    for (final l in lotes) {
      l.dispose();
    }
  }
}

class _LoteEntry {
  final TextEditingController nombreController;
  final TextEditingController codigoController;
  final TextEditingController hectareasController;

  _LoteEntry({
    String nombre = '',
    String codigo = '',
    String hectareas = '',
  })  : nombreController = TextEditingController(text: nombre),
        codigoController = TextEditingController(text: codigo),
        hectareasController = TextEditingController(text: hectareas);

  void dispose() {
    nombreController.dispose();
    codigoController.dispose();
    hectareasController.dispose();
  }
}
