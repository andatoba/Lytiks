import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_tracking_service.dart';

class LocationTrackingScreen extends StatefulWidget {
  const LocationTrackingScreen({super.key});

  @override
  State<LocationTrackingScreen> createState() => _LocationTrackingScreenState();
}

class _LocationTrackingScreenState extends State<LocationTrackingScreen> {
  final LocationTrackingService _trackingService = LocationTrackingService();
  final TextEditingController _matrixLatController = TextEditingController();
  final TextEditingController _matrixLngController = TextEditingController();
  
  bool _isLoading = false;
  Map<String, double>? _matrixCoords;
  Position? _currentPosition;
  List<Map<String, dynamic>> _locationHistory = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    // Cargar coordenadas de la matriz
    _matrixCoords = await _trackingService.getMatrixCoordinates();
    if (_matrixCoords != null) {
      _matrixLatController.text = _matrixCoords!['latitude'].toString();
      _matrixLngController.text = _matrixCoords!['longitude'].toString();
    }

    // Cargar ubicación actual
    try {
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      debugPrint('Error obteniendo ubicación actual: $e');
    }

    // Cargar historial
    _locationHistory = await _trackingService.getLocationHistory(limit: 20);

    setState(() => _isLoading = false);
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = position;
        _matrixLatController.text = position.latitude.toString();
        _matrixLngController.text = position.longitude.toString();
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ubicación actual obtenida'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveMatrixCoordinates() async {
    if (_matrixLatController.text.isEmpty || _matrixLngController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, ingrese las coordenadas'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final latitude = double.parse(_matrixLatController.text);
      final longitude = double.parse(_matrixLngController.text);

      await _trackingService.setMatrixCoordinates(
        latitude: latitude,
        longitude: longitude,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Coordenadas de matriz guardadas'),
            backgroundColor: Colors.green,
          ),
        );
      }

      await _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: Coordenadas inválidas'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _forceSyncNow() async {
    setState(() => _isLoading = true);
    await _trackingService.forceSyncNow();
    await _loadData();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sincronización completada'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seguimiento de Ubicación'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Actualizar',
          ),
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: _forceSyncNow,
            tooltip: 'Sincronizar ahora',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Estado del seguimiento
                  _buildTrackingStatusCard(),
                  const SizedBox(height: 16),

                  // Configuración de coordenadas de matriz
                  _buildMatrixCoordinatesCard(),
                  const SizedBox(height: 16),

                  // Ubicación actual
                  _buildCurrentLocationCard(),
                  const SizedBox(height: 16),

                  // Historial de ubicaciones
                  _buildLocationHistoryCard(),
                ],
              ),
            ),
    );
  }

  Widget _buildTrackingStatusCard() {
    final isTracking = _trackingService.isTracking;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isTracking ? Icons.location_on : Icons.location_off,
                  color: isTracking ? Colors.green : Colors.grey,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Estado del Seguimiento',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isTracking 
                            ? '✅ Activo (cada 5 min, 8AM-4PM)'
                            : '⏸️ Inactivo',
                        style: TextStyle(
                          color: isTracking ? Colors.green : Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              '📍 El seguimiento automático captura tu ubicación cada 5 minutos entre las 8:00 AM y 4:00 PM.',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              '💾 Las ubicaciones se guardan localmente y se sincronizan automáticamente cuando hay conexión.',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatrixCoordinatesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.home_work, color: Color(0xFF004B63)),
                const SizedBox(width: 8),
                Text(
                  'Coordenadas de Matriz',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Configura las coordenadas del punto de partida (oficina/matriz):',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _matrixLatController,
              decoration: const InputDecoration(
                labelText: 'Latitud',
                prefixIcon: Icon(Icons.location_on),
                hintText: 'Ej: -2.1894',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _matrixLngController,
              decoration: const InputDecoration(
                labelText: 'Longitud',
                prefixIcon: Icon(Icons.location_on),
                hintText: 'Ej: -79.8890',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _getCurrentLocation,
                    icon: const Icon(Icons.my_location),
                    label: const Text('Usar Ubicación Actual'),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _saveMatrixCoordinates,
                  icon: const Icon(Icons.save),
                  label: const Text('Guardar'),
                ),
              ],
            ),
            if (_matrixCoords != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Guardado: ${_matrixCoords!['latitude']!.toStringAsFixed(6)}, ${_matrixCoords!['longitude']!.toStringAsFixed(6)}',
                        style: const TextStyle(fontSize: 12, color: Colors.green),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentLocationCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.my_location, color: Color(0xFF004B63)),
                const SizedBox(width: 8),
                Text(
                  'Ubicación Actual',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_currentPosition != null) ...[
              _buildInfoRow('Latitud:', _currentPosition!.latitude.toStringAsFixed(6)),
              _buildInfoRow('Longitud:', _currentPosition!.longitude.toStringAsFixed(6)),
              _buildInfoRow('Precisión:', '${_currentPosition!.accuracy.toStringAsFixed(1)} m'),
            ] else ...[
              const Text(
                'No disponible',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLocationHistoryCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.history, color: Color(0xFF004B63)),
                    const SizedBox(width: 8),
                    Text(
                      'Historial Reciente',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                Chip(
                  label: Text('${_locationHistory.length}'),
                  backgroundColor: Colors.blue.shade100,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_locationHistory.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'No hay registros aún',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _locationHistory.length > 10 ? 10 : _locationHistory.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final location = _locationHistory[index];
                  final isSynced = location['is_synced'] == 1;
                  final timestamp = DateTime.parse(location['timestamp']);
                  
                  return ListTile(
                    dense: true,
                    leading: Icon(
                      isSynced ? Icons.cloud_done : Icons.cloud_off,
                      color: isSynced ? Colors.green : Colors.orange,
                    ),
                    title: Text(
                      '${location['latitude']}, ${location['longitude']}',
                      style: const TextStyle(fontSize: 13),
                    ),
                    subtitle: Text(
                      _formatTimestamp(timestamp),
                      style: const TextStyle(fontSize: 11),
                    ),
                    trailing: Text(
                      isSynced ? 'Sincronizado' : 'Pendiente',
                      style: TextStyle(
                        fontSize: 11,
                        color: isSynced ? Colors.green : Colors.orange,
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Hace un momento';
    } else if (difference.inHours < 1) {
      return 'Hace ${difference.inMinutes} min';
    } else if (difference.inDays < 1) {
      return 'Hace ${difference.inHours} horas';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }

  @override
  void dispose() {
    _matrixLatController.dispose();
    _matrixLngController.dispose();
    super.dispose();
  }
}
