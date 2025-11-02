
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/client_service.dart';

class ClientInfoScreen extends StatefulWidget {
  final Map<String, dynamic>? clientData;
  const ClientInfoScreen({Key? key, this.clientData}) : super(key: key);

  @override
  State<ClientInfoScreen> createState() => _ClientInfoScreenState();
}

class _ClientInfoScreenState extends State<ClientInfoScreen> {
  int? _clienteId;
  @override
  void initState() {
    super.initState();
    _obtenerUbicacion();
  }

  Future<void> _obtenerUbicacion() async {
    LocationPermission permission;
    bool serviceEnabled;
    try {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Por favor activa los servicios de ubicación en tu dispositivo.'), backgroundColor: Colors.orange),
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
              const SnackBar(content: Text('Permiso de ubicación denegado.'), backgroundColor: Colors.red),
            );
          }
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Permiso de ubicación denegado permanentemente. Ve a configuración para activarlo.'), backgroundColor: Colors.red),
          );
        }
        return;
      }
      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      if (mounted) {
        setState(() {
          _currentPosition = pos;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al obtener ubicación: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
  final ClientService _clientService = ClientService();
  bool _hasInternet = true;
  bool _isSaving = false;
  bool _isLoadingLocation = false;
  Position? _currentPosition;
  void _enviarSmsExitoso() {
    // Aquí puedes integrar tu lógica real de SMS
    final telefono = _telefonoController.text.trim();
    if (telefono.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('SMS enviado a $telefono: "¡Tus datos han sido guardados exitosamente!"'), backgroundColor: Colors.blue),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo enviar SMS: teléfono no registrado'), backgroundColor: Colors.orange),
      );
    }
  }
  // ...existing code...
  final _cedulaController = TextEditingController();
  final _nombreController = TextEditingController();
  final _apellidosController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _emailController = TextEditingController();
  final _direccionController = TextEditingController();
  final _parroquiaController = TextEditingController();
  final _fincaNombreController = TextEditingController();
  final _fincaHectareasController = TextEditingController();
  final _cultivosPrincipalesController = TextEditingController();
  // ...existing code...
  final _observacionesController = TextEditingController();
  final _tecnicoAsignadoIdController = TextEditingController();

  @override
  void dispose() {
    _cedulaController.dispose();
    _nombreController.dispose();
    _apellidosController.dispose();
    _telefonoController.dispose();
    _emailController.dispose();
    _direccionController.dispose();
    _parroquiaController.dispose();
    _fincaNombreController.dispose();
    _fincaHectareasController.dispose();
    _cultivosPrincipalesController.dispose();
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
        backgroundColor: const Color(0xFF004B63),
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
                        initialCenter: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                        initialZoom: 16.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.lytiks.app',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                              width: 60,
                              height: 60,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF004B63),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 3),
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
            ]
            else ...[
              const Text('Ubicación no disponible', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 20),
            ],
            // El formulario de cliente inicia aquí
            _buildTextField(controller: _cedulaController, label: 'Cédula', icon: Icons.badge, required: true, keyboardType: TextInputType.number, suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () async {
                        final cedula = _cedulaController.text.trim();
                        if (cedula.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Ingrese una cédula para buscar.')),
                          );
                          return;
                        }
                        setState(() { _isLoadingLocation = true; });
                        final result = await _clientService.searchClientByCedula(cedula);
                        setState(() { _isLoadingLocation = false; });
                        if (result['found'] == true && result['client'] != null) {
                          final client = result['client'];
                          _clienteId = client['id'];
                          _nombreController.text = client['nombre'] ?? '';
                          _apellidosController.text = client['apellidos'] ?? '';
                          _telefonoController.text = client['telefono'] ?? '';
                          _emailController.text = client['email'] ?? '';
                          _direccionController.text = client['direccion'] ?? '';
                          _parroquiaController.text = client['parroquia'] ?? '';
                          _fincaNombreController.text = client['fincaNombre'] ?? '';
                          _fincaHectareasController.text = client['fincaHectareas']?.toString() ?? '';
                          _cultivosPrincipalesController.text = client['cultivosPrincipales'] ?? '';
                          _observacionesController.text = client['observaciones'] ?? '';
                          _tecnicoAsignadoIdController.text = client['tecnicoAsignadoId']?.toString() ?? '';
                          if (client['geolocalizacionLat'] != null && client['geolocalizacionLng'] != null) {
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
                          setState(() {});
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Cliente encontrado y cargado.'), backgroundColor: Colors.green),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(result['message'] ?? 'Cliente no encontrado.'), backgroundColor: Colors.orange),
                          );
                        }
                      },
                    ),),
            _buildTextField(controller: _nombreController, label: 'Nombre', icon: Icons.person, required: true),
            const SizedBox(height: 12),
            _buildTextField(controller: _apellidosController, label: 'Apellidos', icon: Icons.person_outline, required: false),
                    // eliminado departamento
            _buildTextField(controller: _telefonoController, label: 'Teléfono', icon: Icons.phone, required: false, keyboardType: TextInputType.phone),
            const SizedBox(height: 12),
            _buildTextField(controller: _emailController, label: 'Email', icon: Icons.email, required: false, keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 12),
            _buildTextField(controller: _direccionController, label: 'Dirección', icon: Icons.location_on, required: false),
            const SizedBox(height: 12),
            _buildTextField(controller: _parroquiaController, label: 'Parroquia', icon: Icons.location_city, required: false),
            const SizedBox(height: 12),
            const SizedBox(height: 12),
            _buildTextField(controller: _fincaNombreController, label: 'Nombre de la Finca', icon: Icons.home, required: false),
            const SizedBox(height: 12),
            _buildTextField(controller: _fincaHectareasController, label: 'Hectáreas de la Finca', icon: Icons.terrain, required: false, keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            _buildTextField(controller: _cultivosPrincipalesController, label: 'Cultivos Principales', icon: Icons.agriculture, required: false),
            const SizedBox(height: 12),
            // ...existing code...
            _buildTextField(controller: _observacionesController, label: 'Observaciones', icon: Icons.notes, required: false),
            const SizedBox(height: 12),
            _buildTextField(controller: _tecnicoAsignadoIdController, label: 'ID Técnico Asignado', icon: Icons.engineering, required: false, keyboardType: TextInputType.number),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoadingLocation ? null : () async {
                      // ACTUALIZAR CLIENTE
                      setState(() { _isLoadingLocation = true; });
                      try {
                        final clientService = ClientService();
                        if (_clienteId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Primero busque y cargue un cliente por cédula.'), backgroundColor: Colors.orange),
                          );
                          return;
                        }
                        final clientData = {
                          'nombre': _nombreController.text.trim(),
                          'apellidos': _apellidosController.text.trim(),
                          'telefono': _telefonoController.text.trim(),
                          'direccion': _direccionController.text.trim(),
                          'parroquia': _parroquiaController.text.trim(),
                          'fincaNombre': _fincaNombreController.text.trim(),
                          'fincaHectareas': _fincaHectareasController.text.isNotEmpty ? double.tryParse(_fincaHectareasController.text) : null,
                          'cultivosPrincipales': _cultivosPrincipalesController.text.trim(),
                          'geolocalizacionLat': _currentPosition?.latitude,
                          'geolocalizacionLng': _currentPosition?.longitude,
                          'observaciones': _observacionesController.text.trim(),
                          'tecnicoAsignadoId': _tecnicoAsignadoIdController.text.isNotEmpty ? int.tryParse(_tecnicoAsignadoIdController.text) : null,
                        };
                        final result = await clientService.updateClient(id: _clienteId!, clientData: clientData);
                        if (result['success'] == true) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Cliente actualizado exitosamente'), backgroundColor: Colors.green),
                          );
                          // Simulación de envío de SMS
                          _enviarSmsExitoso();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(result['message'] ?? 'Error al actualizar cliente'), backgroundColor: Colors.red),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                        );
                      } finally {
                        setState(() { _isLoadingLocation = false; });
                      }
                    },
                    icon: _isLoadingLocation
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.refresh),
                    label: Text(_isLoadingLocation ? 'Actualizando...' : 'Actualizar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade600,
                            // eliminado departamento
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isSaving ? null : () {},
                    icon: _isSaving
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                        : const Icon(Icons.save),
                    label: Text(_isSaving ? 'Guardando...' : 'Guardar'),
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
}
