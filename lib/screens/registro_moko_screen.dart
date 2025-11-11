import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import '../services/registro_moko_service.dart';
import 'contencion_screen.dart';

class RegistroMokoScreen extends StatefulWidget {
  final Map<String, dynamic>? clientData;

  const RegistroMokoScreen({super.key, this.clientData});

  @override
  State<RegistroMokoScreen> createState() => _RegistroMokoScreenState();
}

class _RegistroMokoScreenState extends State<RegistroMokoScreen> {
  // Servicios
  final RegistroMokoService _registroMokoService = RegistroMokoService();

  // Controllers
  final TextEditingController _plantasAfectadasController =
      TextEditingController();
  final TextEditingController _observacionesController =
      TextEditingController();

  // Variables del formulario
  int? numeroFoco;
  String? gpsCoordinates;
  DateTime fechaDeteccion = DateTime.now();
  Map<String, dynamic>? sintomaSeleccionado;
  String? severidadAutomatica;
  File? fotoTomada;
  String? metodoComprobacion;

  // Listas para dropdowns
  List<Map<String, dynamic>> sintomas = [];
  List<String> metodosComprobacion = [
    'visual',
    'laboratorio',
    'prueba rapida',
    'sospecha',
  ];

  // Estado de carga
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      print('REGISTRO_MOKO_SCREEN: Iniciando carga de datos...');
      
      // Obtener número de foco secuencial
      print('REGISTRO_MOKO_SCREEN: Obteniendo número de foco...');
      numeroFoco = await _registroMokoService.getNextFocoNumber();
      print('REGISTRO_MOKO_SCREEN: Número de foco obtenido: $numeroFoco');

      // Cargar síntomas desde la base de datos
      print('REGISTRO_MOKO_SCREEN: Cargando síntomas...');
      sintomas = await _registroMokoService.getSintomas();
      print('REGISTRO_MOKO_SCREEN: Síntomas cargados: ${sintomas.length} elementos');
      print('REGISTRO_MOKO_SCREEN: Primer síntoma: ${sintomas.isNotEmpty ? sintomas.first : 'Lista vacía'}');

      // Obtener coordenadas GPS del cliente
      if (widget.clientData != null) {
        print('REGISTRO_MOKO_SCREEN: Obteniendo GPS para cliente: ${widget.clientData!['nombre']}');
        gpsCoordinates = await _getClientGPS();
        print('REGISTRO_MOKO_SCREEN: GPS obtenido: $gpsCoordinates');
      }

      print('REGISTRO_MOKO_SCREEN: Datos cargados exitosamente, cambiando estado a no loading...');
      setState(() {
        _isLoading = false;
      });
      print('REGISTRO_MOKO_SCREEN: Estado actualizado, _isLoading = $_isLoading');
    } catch (e) {
      print('REGISTRO_MOKO_SCREEN: ERROR en _initializeData: $e');
      setState(() {
        _isLoading = false;
      });
      _showError('Error al inicializar datos: $e');
    }
  }

  Future<String?> _getClientGPS() async {
    try {
      // Si el cliente tiene coordenadas guardadas, usarlas
      if (widget.clientData!['latitud'] != null &&
          widget.clientData!['longitud'] != null) {
        return '${widget.clientData!['latitud']}, ${widget.clientData!['longitud']}';
      }

      // Si no, obtener ubicación actual
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition();
        return '${position.latitude}, ${position.longitude}';
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    print('REGISTRO_MOKO_SCREEN: build() ejecutándose, _isLoading = $_isLoading');
    print('REGISTRO_MOKO_SCREEN: sintomas.length = ${sintomas.length}');
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFFE53E3E),
        title: const Text(
          'Registro de Nuevo Foco',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildFormulario(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildFormulario() {
    print('REGISTRO_MOKO_SCREEN: _buildFormulario() ejecutándose');
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildNumeroFoco(),
          const SizedBox(height: 16),
          _buildGPS(),
          const SizedBox(height: 16),
          _buildPlantasAfectadas(),
          const SizedBox(height: 16),
          _buildFechaDeteccion(),
          const SizedBox(height: 16),
          _buildSintomasObservados(),
          const SizedBox(height: 16),
          _buildSeveridad(),
          const SizedBox(height: 16),
          _buildFoto(),
          const SizedBox(height: 16),
          _buildMetodoComprobacion(),
          const SizedBox(height: 16),
          _buildObservaciones(),
          const SizedBox(height: 100), // Espacio para el botón flotante
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE53E3E), Color(0xFFB91C1C)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.add_location_alt, color: Colors.white, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nuevo Foco de Moko',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (widget.clientData != null)
                  Text(
                    'Cliente: ${widget.clientData!['nombre']}',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumeroFoco() {
    return _buildCard(
      title: 'Número de Foco',
      icon: Icons.numbers,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue[200]!),
        ),
        child: Text(
          'Foco #${numeroFoco ?? 'Cargando...'}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
      ),
    );
  }

  Widget _buildGPS() {
    return _buildCard(
      title: 'Coordenadas GPS',
      icon: Icons.location_on,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green[200]!),
        ),
        child: Row(
          children: [
            Icon(Icons.gps_fixed, color: Colors.green[600]),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                gpsCoordinates ?? 'No disponible',
                style: TextStyle(fontSize: 16, color: Colors.green[700]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlantasAfectadas() {
    return _buildCard(
      title: 'Plantas Afectadas (10m redonda)',
      icon: Icons.eco,
      child: TextField(
        controller: _plantasAfectadasController,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          hintText: 'Número de plantas afectadas',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.eco_outlined),
        ),
      ),
    );
  }

  Widget _buildFechaDeteccion() {
    return _buildCard(
      title: 'Fecha de Detección',
      icon: Icons.calendar_today,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.orange[200]!),
        ),
        child: Row(
          children: [
            Icon(Icons.access_time, color: Colors.orange[600]),
            const SizedBox(width: 8),
            Text(
              '${fechaDeteccion.day}/${fechaDeteccion.month}/${fechaDeteccion.year}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.orange[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSintomasObservados() {
    return _buildCard(
      title: 'Síntomas Observados',
      icon: Icons.visibility,
      child: DropdownButtonFormField<Map<String, dynamic>>(
        value: sintomaSeleccionado,
        decoration: const InputDecoration(
          hintText: 'Seleccione un síntoma',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.medical_services),
        ),
        items: sintomas.map((sintoma) {
          return DropdownMenuItem<Map<String, dynamic>>(
            value: sintoma,
            child: Text(sintoma['sintomaObservable'] ?? sintoma['sintoma_observable'] ?? ''),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            sintomaSeleccionado = value;
            severidadAutomatica = value?['severidad'];
          });
        },
      ),
    );
  }

  Widget _buildSeveridad() {
    return _buildCard(
      title: 'Severidad',
      icon: Icons.warning,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _getSeveridadColor().withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _getSeveridadColor()),
        ),
        child: Row(
          children: [
            Icon(_getSeveridadIcon(), color: _getSeveridadColor()),
            const SizedBox(width: 8),
            Text(
              severidadAutomatica ?? 'Seleccione un síntoma primero',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _getSeveridadColor(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoto() {
    return _buildCard(
      title: 'Foto del Foco',
      icon: Icons.camera_alt,
      child: Column(
        children: [
          if (fotoTomada != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                fotoTomada!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 12),
          ],
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _tomarFoto,
              icon: const Icon(Icons.camera_alt),
              label: Text(fotoTomada == null ? 'Tomar Foto' : 'Cambiar Foto'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetodoComprobacion() {
    return _buildCard(
      title: 'Método de Comprobación',
      icon: Icons.science,
      child: DropdownButtonFormField<String>(
        value: metodoComprobacion,
        decoration: const InputDecoration(
          hintText: 'Seleccione método',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.biotech),
        ),
        items: metodosComprobacion.map((metodo) {
          return DropdownMenuItem<String>(
            value: metodo,
            child: Text(metodo.toUpperCase()),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            metodoComprobacion = value;
          });
        },
      ),
    );
  }

  Widget _buildObservaciones() {
    return _buildCard(
      title: 'Observaciones',
      icon: Icons.notes,
      child: TextField(
        controller: _observacionesController,
        maxLines: 4,
        decoration: const InputDecoration(
          hintText: 'Ingrese observaciones adicionales...',
          border: OutlineInputBorder(),
          alignLabelWithHint: true,
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              Icon(icon, color: const Color(0xFFE53E3E), size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE53E3E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _isSaving ? null : _guardarRegistro,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE53E3E),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _isSaving
              ? const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    SizedBox(width: 12),
                    Text('Guardando...'),
                  ],
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.save),
                    SizedBox(width: 8),
                    Text(
                      'Guardar Registro',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Color _getSeveridadColor() {
    switch (severidadAutomatica?.toLowerCase()) {
      case 'bajo':
        return Colors.green;
      case 'medio':
        return Colors.orange;
      case 'alto':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getSeveridadIcon() {
    switch (severidadAutomatica?.toLowerCase()) {
      case 'bajo':
        return Icons.check_circle;
      case 'medio':
        return Icons.warning;
      case 'alto':
        return Icons.dangerous;
      default:
        return Icons.help_outline;
    }
  }

  Future<void> _tomarFoto() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
      );

      if (pickedFile != null) {
        setState(() {
          fotoTomada = File(pickedFile.path);
        });
      }
    } catch (e) {
      _showError('Error al tomar foto: $e');
    }
  }

  Future<void> _guardarRegistro() async {
    if (!_validarFormulario()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      // Preparar datos para guardar
      Map<String, dynamic> registroData = {
        'numeroFoco': numeroFoco,
        'clienteId': widget.clientData?['id'],
        'gpsCoordinates': gpsCoordinates,
        'plantasAfectadas': int.tryParse(_plantasAfectadasController.text) ?? 0,
        'fechaDeteccion': fechaDeteccion.toIso8601String(),
        'sintomaId': sintomaSeleccionado?['id'],
        'severidad': severidadAutomatica,
        'metodoComprobacion': metodoComprobacion,
        'observaciones': _observacionesController.text,
      };

  // Guardar en la base de datos
  await _registroMokoService.guardarRegistro(registroData, fotoTomada);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registro guardado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );

        // Navegar a la pantalla de Contención
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ContencionScreen(clientData: widget.clientData),
          ),
        );
      }
    } catch (e) {
      _showError('Error al guardar registro: $e');
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  bool _validarFormulario() {
    if (widget.clientData == null) {
      _showError('Debe seleccionar un cliente primero');
      return false;
    }

    if (_plantasAfectadasController.text.isEmpty) {
      _showError('Debe ingresar el número de plantas afectadas');
      return false;
    }

    if (sintomaSeleccionado == null) {
      _showError('Debe seleccionar un síntoma');
      return false;
    }

    if (metodoComprobacion == null) {
      _showError('Debe seleccionar un método de comprobación');
      return false;
    }

    return true;
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    _plantasAfectadasController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }
}
