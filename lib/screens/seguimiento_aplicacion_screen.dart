import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/registro_moko_service.dart';

class SeguimientoAplicacionScreen extends StatefulWidget {
  final Map<String, dynamic> producto;
  final Map<String, dynamic>? clientData;
  final int? aplicacionId;

  const SeguimientoAplicacionScreen({
    super.key,
    required this.producto,
    this.clientData,
    this.aplicacionId,
  });

  @override
  State<SeguimientoAplicacionScreen> createState() => _SeguimientoAplicacionScreenState();
}

class _SeguimientoAplicacionScreenState extends State<SeguimientoAplicacionScreen> {
  final RegistroMokoService _service = RegistroMokoService();
  bool _isLoading = true;
  Map<String, dynamic>? _seguimientoData;
  DateTime _selectedDate = DateTime.now();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadSeguimientoData();
  }

  Future<void> _loadSeguimientoData() async {
    try {
      if (widget.aplicacionId != null) {
        // Cargar datos reales del backend
        final data = await _service.getSeguimiento(widget.aplicacionId!);
        setState(() {
          _seguimientoData = data;
          _isLoading = false;
        });
      } else {
        // Si no hay aplicacionId, mostrar error
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error: No se proporcionó ID de aplicación'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Error cargando seguimiento: $e');
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar seguimiento: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seguimiento'),
        backgroundColor: const Color(0xFF0F7B3C),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildResumenCard(),
                  const SizedBox(height: 20),
                  _buildHistorialSection(),
                  const SizedBox(height: 20),
                  _buildAccionesSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildResumenCard() {
    if (_seguimientoData == null) return const SizedBox.shrink();
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: [Color(0xFF0F7B3C), Color(0xFF15A045)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumen',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Plan: ${_seguimientoData!['plan']}',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Progreso: ${_seguimientoData!['progreso']} / ${_seguimientoData!['total']} • Cumplimiento: ${_seguimientoData!['cumplimiento']}%',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: _seguimientoData!['progreso'] / _seguimientoData!['total'],
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistorialSection() {
    if (_seguimientoData == null) return const SizedBox.shrink();
    
    List<dynamic> aplicaciones = _seguimientoData!['aplicaciones'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Historial y Próximas',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 12),
        ...aplicaciones.map((aplicacion) => _buildAplicacionCard(aplicacion)).toList(),
      ],
    );
  }

  Widget _buildAplicacionCard(Map<String, dynamic> aplicacion) {
    Color statusColor;
    IconData statusIcon;
    
    switch (aplicacion['estado']) {
      case 'completada':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'proxima':
        statusColor = Colors.orange;
        statusIcon = Icons.schedule;
        break;
      case 'programada':
        statusColor = Colors.blue;
        statusIcon = Icons.event;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(statusIcon, color: statusColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Aplicación #${aplicacion['numeroAplicacion'] ?? aplicacion['numero'] ?? 'N/A'}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (aplicacion['estado'] == 'proxima')
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Recordatorio activado',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Fecha: ${_formatearFecha(aplicacion['fechaProgramada'] ?? aplicacion['fecha'])}'),
            Text('Dosis: ${aplicacion['dosisAplicada'] ?? aplicacion['dosis'] ?? 'N/A'}'),
            if ((aplicacion['lote'] ?? '').isNotEmpty)
              Text('Lote: ${aplicacion['lote']}'),
            if ((aplicacion['horaRecordatorio'] ?? aplicacion['recordatorio'] ?? '').isNotEmpty)
              Text('Recordatorio: ${aplicacion['horaRecordatorio'] ?? aplicacion['recordatorio']}'),
          ],
        ),
      ),
    );
  }

  Widget _buildAccionesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _tomarFoto,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Agregar evidencia'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F7B3C),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _reprogramar,
                icon: const Icon(Icons.schedule),
                label: const Text('Reprogramar'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF0F7B3C),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _tomarFoto() async {
    try {
      final XFile? foto = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 80,
      );

      if (foto != null) {
        // Aquí podrías subir la foto al servidor
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Evidencia capturada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al capturar evidencia: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _reprogramar() async {
    final DateTime? nuevaFecha = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (nuevaFecha != null) {
      final TimeOfDay? nuevaHora = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (nuevaHora != null) {
        setState(() {
          _selectedDate = DateTime(
            nuevaFecha.year,
            nuevaFecha.month,
            nuevaFecha.day,
            nuevaHora.hour,
            nuevaHora.minute,
          );
        });

        // Aquí podrías actualizar la fecha en el servidor
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Aplicación reprogramada para ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year} a las ${nuevaHora.format(context)}',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  String _formatearFecha(dynamic fecha) {
    if (fecha == null) return 'N/A';
    
    try {
      DateTime dateTime;
      if (fecha is String) {
        // Si es ISO string
        if (fecha.contains('T')) {
          dateTime = DateTime.parse(fecha);
        } else {
          // Si es formato dd/mm/yyyy
          return fecha;
        }
      } else {
        dateTime = fecha as DateTime;
      }
      
      return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
    } catch (e) {
      return fecha.toString();
    }
  }
}