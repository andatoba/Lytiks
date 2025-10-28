import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/lytiks_utils.dart';
import '../services/client_service.dart';

class ClientInfoScreen extends StatefulWidget {
  const ClientInfoScreen({super.key});

  @override
  State<ClientInfoScreen> createState() => _ClientInfoScreenState();
}

class _ClientInfoScreenState extends State<ClientInfoScreen> {
  final ClientService _clientService = ClientService();
  Position? _currentPosition;
  bool _isLoadingLocation = false;
  bool _hasInternet = true;
  bool _isSaving = false;
  bool _isSearchingClient = false;

  // Controladores para los campos de información
  final _clienteController = TextEditingController();
  final _cedulaController = TextEditingController();
  final _propiedadController = TextEditingController();
  final _parroquiaController = TextEditingController();
  final _ubicacionController = TextEditingController();
  final _loteController = TextEditingController();
  final _muestraController = TextEditingController();

  // Información de ubicación obtenida automáticamente
  String _locationInfo = '';

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _clienteController.dispose();
    _cedulaController.dispose();
    _propiedadController.dispose();
    _parroquiaController.dispose();
    _ubicacionController.dispose();
    _loteController.dispose();
    _muestraController.dispose();
    super.dispose();
  }

  Future<void> _searchClientByCedula() async {
    final cedula = _cedulaController.text.trim();

    if (cedula.isEmpty) {
      LytiksUtils.showErrorSnackBar(
        context,
        'Por favor ingrese un número de cédula',
      );
      return;
    }

    // Validar que solo contenga números
    if (!RegExp(r'^\d+$').hasMatch(cedula)) {
      LytiksUtils.showErrorSnackBar(
        context,
        'La cédula debe contener solo números',
      );
      return;
    }

    // Validar longitud mínima
    if (cedula.length < 6) {
      LytiksUtils.showErrorSnackBar(
        context,
        'La cédula debe tener al menos 6 dígitos',
      );
      return;
    }

    setState(() {
      _isSearchingClient = true;
    });

    try {
      final result = await _clientService.searchClientByCedula(cedula);

      if (result['found'] == true && result['client'] != null) {
        final client = result['client'];

        // Autocomplete todos los campos con la información del cliente
        _clienteController.text = client['nombre'] ?? '';
        if (client['apellidos'] != null && client['apellidos'].isNotEmpty) {
          _clienteController.text =
              '${_clienteController.text} ${client['apellidos']}';
        }

        _propiedadController.text = client['fincaNombre'] ?? '';
        _parroquiaController.text = client['municipio'] ?? '';
        _ubicacionController.text = client['direccion'] ?? '';

        // Si tiene geolocalización, actualizar también
        if (client['geolocalizacionLat'] != null &&
            client['geolocalizacionLng'] != null) {
          _currentPosition = Position(
            latitude: client['geolocalizacionLat'].toDouble(),
            longitude: client['geolocalizacionLng'].toDouble(),
            timestamp: DateTime.now(),
            accuracy: 0,
            altitude: 0,
            heading: 0,
            speed: 0,
            speedAccuracy: 0,
            altitudeAccuracy: 0,
            headingAccuracy: 0,
          );

          _locationInfo =
              'Lat: ${client['geolocalizacionLat']}, Lng: ${client['geolocalizacionLng']}';
        }

        LytiksUtils.showSuccessSnackBar(
          context,
          'Cliente encontrado: ${client['nombre']} ${client['apellidos'] ?? ''}',
        );
      } else {
        LytiksUtils.showInfoSnackBar(
          context,
          'Cliente no encontrado. Puede registrar un nuevo cliente.',
        );
      }
    } catch (e) {
      LytiksUtils.showErrorSnackBar(context, 'Error al buscar cliente: $e');
    }

    setState(() {
      _isSearchingClient = false;
    });
  }

  Future<void> _checkConnectivity() async {
    try {
      final response = await http
          .get(Uri.parse('https://www.google.com'))
          .timeout(const Duration(seconds: 5));
      setState(() {
        _hasInternet = response.statusCode == 200;
      });
    } catch (e) {
      setState(() {
        _hasInternet = false;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          LytiksUtils.showErrorSnackBar(
            context,
            'Los servicios de ubicación están deshabilitados',
          );
        }
        setState(() {
          _isLoadingLocation = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            LytiksUtils.showErrorSnackBar(
              context,
              'Permisos de ubicación denegados',
            );
          }
          setState(() {
            _isLoadingLocation = false;
          });
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
        _isLoadingLocation = false;
      });

      // Si hay internet, obtener información de ubicación automáticamente
      if (_hasInternet) {
        await _getLocationInfo(position);
      }
    } catch (e) {
      setState(() {
        _isLoadingLocation = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al obtener ubicación: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _getLocationInfo(Position position) async {
    try {
      // Usar servicio de geocodificación inversa (Nominatim - OpenStreetMap)
      final url =
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=${position.latitude}&lon=${position.longitude}&zoom=18&addressdetails=1';

      final response = await http.get(
        Uri.parse(url),
        headers: {'User-Agent': 'Lytiks-App/1.0'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['address'] ?? {};

        setState(() {
          _locationInfo = data['display_name'] ?? 'Ubicación no disponible';

          // Autocompletar campos si hay información disponible
          if (address['county'] != null) {
            _parroquiaController.text = address['county'];
          }
          if (address['state'] != null || address['province'] != null) {
            _ubicacionController.text =
                address['state'] ?? address['province'] ?? '';
          }
          if (address['suburb'] != null || address['village'] != null) {
            _propiedadController.text =
                address['suburb'] ?? address['village'] ?? '';
          }
        });
      }
    } catch (e) {
      print('Error obteniendo información de ubicación: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Información del Cliente'),
        backgroundColor: const Color(0xFF004B63),
        foregroundColor: Colors.white,
        actions: [
          // Indicador de conectividad
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Icon(
                  _hasInternet ? Icons.wifi : Icons.wifi_off,
                  color: _hasInternet ? Colors.green : Colors.red,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  _hasInternet ? 'Online' : 'Offline',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Estado de conectividad
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _hasInternet
                    ? Colors.green.withOpacity(0.1)
                    : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _hasInternet ? Colors.green : Colors.orange,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _hasInternet ? Icons.cloud_done : Icons.cloud_off,
                    color: _hasInternet ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _hasInternet
                          ? 'Conectado - Los campos se completarán automáticamente'
                          : 'Sin conexión - Complete los campos manualmente',
                      style: TextStyle(
                        color: _hasInternet
                            ? Colors.green.shade700
                            : Colors.orange.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Mapa (solo si hay ubicación)
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
                        initialCenter: LatLng(
                          _currentPosition!.latitude,
                          _currentPosition!.longitude,
                        ),
                        initialZoom: 16.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.lytiks.app',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: LatLng(
                                _currentPosition!.latitude,
                                _currentPosition!.longitude,
                              ),
                              width: 60,
                              height: 60,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF004B63),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
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

              // Coordenadas
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF004B63).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
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
                    if (_locationInfo.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        _locationInfo,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],

            // Botón para obtener ubicación
            if (_currentPosition == null) ...[
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.location_off,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No hay ubicación disponible',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _isLoadingLocation
                          ? null
                          : _getCurrentLocation,
                      icon: _isLoadingLocation
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.my_location),
                      label: Text(
                        _isLoadingLocation
                            ? 'Obteniendo...'
                            : 'Obtener Ubicación',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF004B63),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Formulario de datos básicos
            const Text(
              'Información del Cliente',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF004B63),
              ),
            ),

            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Ingrese la cédula y presione el botón de búsqueda para cargar la información del cliente desde la base de datos.',
                      style: TextStyle(fontSize: 13, color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Campos del formulario
            _buildTextField(
              controller: _cedulaController,
              label: 'Número de Cédula',
              icon: Icons.badge,
              required: true,
              keyboardType: TextInputType.number,
              maxLength: 10, // Máximo 10 dígitos
              helperText: 'Ej: 12345678 (6-10 dígitos)',
              suffixIcon: IconButton(
                icon: _isSearchingClient
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.search, color: Color(0xFF004B63)),
                onPressed: _isSearchingClient ? null : _searchClientByCedula,
                tooltip: 'Buscar cliente por cédula',
              ),
            ),

            const SizedBox(height: 16),

            // Campos de solo lectura que se llenan automáticamente desde el backend
            _buildTextField(
              controller: _clienteController,
              label: 'Cliente',
              icon: Icons.person,
              required: true,
              readOnly: true,
            ),

            const SizedBox(height: 16),

            _buildTextField(
              controller: _propiedadController,
              label: 'Propiedad',
              icon: Icons.home,
              required: true,
              readOnly: true,
            ),

            const SizedBox(height: 16),

            _buildTextField(
              controller: _parroquiaController,
              label: 'Parroquia',
              icon: Icons.location_city,
              required: true,
              readOnly: true,
            ),

            const SizedBox(height: 16),

            _buildTextField(
              controller: _ubicacionController,
              label: 'Ubicación (Provincia/Estado)',
              icon: Icons.map,
              required: true,
              readOnly: true,
            ),

            const SizedBox(height: 16),

            // Campos editables específicos de la auditoría
            _buildTextField(
              controller: _loteController,
              label: 'Lote',
              icon: Icons.grid_3x3,
              required: true,
              helperText: 'Ingrese el lote específico para esta auditoría',
            ),

            const SizedBox(height: 16),

            _buildTextField(
              controller: _muestraController,
              label: 'Muestra',
              icon: Icons.science,
              required: false,
              helperText: 'Opcional: Código o nombre de la muestra',
            ),

            const SizedBox(height: 24),

            // Botones de acción
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _currentPosition == null
                        ? _getCurrentLocation
                        : null,
                    icon: _isLoadingLocation
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh),
                    label: Text(
                      _isLoadingLocation
                          ? 'Actualizando...'
                          : 'Actualizar Ubicación',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isSaving ? null : _saveClientInfo,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Icon(Icons.save),
                    label: Text(
                      _isSaving ? 'Guardando...' : 'Guardar Información',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF004B63),
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
    int? maxLength,
    String? helperText,
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: '$label${required ? ' *' : ''}',
        helperText: helperText,
        prefixIcon: Icon(
          icon,
          color: readOnly ? Colors.grey : const Color(0xFF004B63),
        ),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: readOnly ? Colors.grey : const Color(0xFF004B63),
            width: 2,
          ),
        ),
        filled: true,
        fillColor: readOnly ? Colors.grey.shade100 : Colors.grey.shade50,
        counterText: maxLength != null
            ? ''
            : null, // Oculta el contador si hay maxLength
      ),
    );
  }

  Future<void> _saveClientInfo() async {
    // Validar que se haya buscado un cliente y los campos básicos estén llenos
    if (_cedulaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingrese un número de cédula'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_clienteController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor busque el cliente por cédula primero'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_loteController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingrese el lote para la auditoría'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Preparar datos del cliente para la nueva API
      final clientData = {
        'cedula': _cedulaController.text.trim(),
        'nombre': _clienteController.text.trim(),
        'telefono':
            '', // Se puede agregar un campo para teléfono si es necesario
        'email':
            '${_cedulaController.text.trim()}@client.local', // Email temporal
        'direccion': _ubicacionController.text.trim(),
        'municipio': _parroquiaController.text.trim(),
        'departamento': '', // Se puede agregar un campo si es necesario
        'fincaNombre': _propiedadController.text.trim(),
        'cultivosPrincipales': _loteController.text
            .trim(), // Usando el campo lote como cultivos
        'tipoProductor': 'MEDIANO', // Valor por defecto
        'geolocalizacionLat': _currentPosition?.latitude,
        'geolocalizacionLng': _currentPosition?.longitude,
        'observaciones': _muestraController.text.trim(),
        'tecnicoAsignadoId': 1, // ID del técnico actual
      };

      // Crear cliente usando el servicio actualizado
      final result = await _clientService.createClient(clientData);

      if (mounted) {
        if (result['success'] == true) {
          // Mostrar resumen de la información guardada
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Información Guardada Exitosamente'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ID Cliente: ${result['clientId']}'),
                  Text('Cliente: ${_clienteController.text}'),
                  Text('Cédula: ${_cedulaController.text}'),
                  Text('Propiedad: ${_propiedadController.text}'),
                  Text('Parroquia: ${_parroquiaController.text}'),
                  Text('Ubicación: ${_ubicacionController.text}'),
                  Text('Lote: ${_loteController.text}'),
                  if (_muestraController.text.isNotEmpty)
                    Text('Muestra: ${_muestraController.text}'),
                  if (_currentPosition != null) ...[
                    const SizedBox(height: 8),
                    const Text('Coordenadas GPS:'),
                    Text(
                      '  Lat: ${_currentPosition!.latitude.toStringAsFixed(6)}°',
                    ),
                    Text(
                      '  Lng: ${_currentPosition!.longitude.toStringAsFixed(6)}°',
                    ),
                  ],
                  const SizedBox(height: 8),
                  const Text(
                    '✅ Datos guardados en el servidor',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    // Limpiar formulario para nuevo cliente
                    _clienteController.clear();
                    _cedulaController.clear();
                    _propiedadController.clear();
                    _parroquiaController.clear();
                    _ubicacionController.clear();
                    _loteController.clear();
                    _muestraController.clear();
                    _currentPosition = null;
                    _locationInfo = '';
                    setState(() {});
                    Navigator.of(context).pop();
                  },
                  child: const Text('Nuevo Cliente'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(
                      context,
                    ).pop(true); // Volver al home con resultado
                  },
                  child: const Text('Finalizar'),
                ),
              ],
            ),
          );
        } else {
          // Mostrar error si no se pudo crear el cliente
          LytiksUtils.showErrorSnackBar(
            context,
            result['message'] ?? 'Error al crear cliente',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar cliente: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
}
