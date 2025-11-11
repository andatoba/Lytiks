import 'package:flutter/material.dart';
import '../services/registro_moko_service.dart';
import 'seguimiento_aplicacion_screen.dart';

class GuardarAplicacionScreen extends StatefulWidget {
  final Map<String, dynamic>? clientData;
  final Map<String, dynamic> producto;

  const GuardarAplicacionScreen({
    super.key,
    required this.clientData,
    required this.producto,
  });

  @override
  State<GuardarAplicacionScreen> createState() => _GuardarAplicacionScreenState();
}

class _GuardarAplicacionScreenState extends State<GuardarAplicacionScreen> {
  final RegistroMokoService _service = RegistroMokoService();
  final TextEditingController _loteController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _dosisController = TextEditingController();
  
  DateTime _fechaInicio = DateTime.now();
  int _frecuenciaDias = 7;
  int _repeticiones = 4;
  String _recordatorioHora = '08:00';
  bool _isSaving = false;
  int? _aplicacionId;

  @override
  void initState() {
    super.initState();
    // Pre-llenar dosis con la sugerida del producto
    _dosisController.text = widget.producto['dosisSugerida'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurar Aplicación'),
        backgroundColor: const Color(0xFFE53E3E),
      ),
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductoInfo(),
            const SizedBox(height: 16),
            _buildPlanInfo(),
            const SizedBox(height: 16),
            _buildLoteArea(),
            const SizedBox(height: 16),
            _buildDosisYMezcla(),
            const SizedBox(height: 16),
            _buildCalendario(),
            const SizedBox(height: 24),
            _buildGuardarButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildProductoInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.producto['nombre'] ?? '',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Presentación: ${widget.producto['presentacion'] ?? ''}'),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Plan Moko',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Cliente: ${widget.clientData?['nombre'] ?? ''}'),
            Text('Finca: ${widget.clientData?['nombreFinca'] ?? ''}'),
          ],
        ),
      ),
    );
  }

  Widget _buildLoteArea() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Lote y Área',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _loteController,
              decoration: const InputDecoration(
                labelText: 'Lote',
                hintText: 'Ej: Lote A',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _areaController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Área (hectáreas)',
                hintText: 'Ej: 6.5',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDosisYMezcla() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dosis y Mezcla',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _dosisController,
              decoration: const InputDecoration(
                labelText: 'Dosis por hectárea',
                hintText: 'Ej: 1.0 L en 400 L agua',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendario() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Calendario',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ListTile(
              title: const Text('Fecha de inicio'),
              subtitle: Text('${_fechaInicio.day}/${_fechaInicio.month}/${_fechaInicio.year}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final fecha = await showDatePicker(
                  context: context,
                  initialDate: _fechaInicio,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (fecha != null) {
                  setState(() {
                    _fechaInicio = fecha;
                  });
                }
              },
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text('Frecuencia: Cada $_frecuenciaDias días'),
                ),
                IconButton(
                  onPressed: _frecuenciaDias > 1 ? () {
                    setState(() {
                      _frecuenciaDias--;
                    });
                  } : null,
                  icon: const Icon(Icons.remove),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _frecuenciaDias++;
                    });
                  },
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text('Repeticiones: $_repeticiones'),
                ),
                IconButton(
                  onPressed: _repeticiones > 1 ? () {
                    setState(() {
                      _repeticiones--;
                    });
                  } : null,
                  icon: const Icon(Icons.remove),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _repeticiones++;
                    });
                  },
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ListTile(
              title: const Text('Recordatorio'),
              subtitle: Text('$_recordatorioHora'),
              trailing: const Icon(Icons.access_time),
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay(
                    hour: int.parse(_recordatorioHora.split(':')[0]),
                    minute: int.parse(_recordatorioHora.split(':')[1]),
                  ),
                );
                if (time != null) {
                  setState(() {
                    _recordatorioHora = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuardarButton() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isSaving ? null : _guardarAplicacion,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F9D58),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: _isSaving
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    'Guardar en Plan',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              // TODO: Agregar otra aplicación
            },
            child: const Text('Agregar otra aplicación'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SeguimientoAplicacionScreen(
                    producto: widget.producto,
                    clientData: widget.clientData,
                    aplicacionId: _aplicacionId,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53E3E),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              'Ver Seguimiento',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _guardarAplicacion() async {
    if (!_validarFormulario()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final aplicacionData = {
        'clienteId': widget.clientData?['id'],
        'productoId': widget.producto['id'],
        'productoNombre': widget.producto['nombre'],
        'plan': 'Moko',
        'lote': _loteController.text,
        'areaHectareas': double.tryParse(_areaController.text) ?? 0.0,
        'dosis': _dosisController.text,
        'fechaInicio': _fechaInicio.toIso8601String(),
        'frecuenciaDias': _frecuenciaDias,
        'repeticiones': _repeticiones,
        'recordatorioHora': _recordatorioHora,
      };

      final response = await _service.postAplicacion(aplicacionData);
      _aplicacionId = response['id'];

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aplicación guardada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar aplicación: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  bool _validarFormulario() {
    if (_loteController.text.isEmpty) {
      _showError('Debe ingresar el lote');
      return false;
    }
    if (_areaController.text.isEmpty) {
      _showError('Debe ingresar el área');
      return false;
    }
    if (_dosisController.text.isEmpty) {
      _showError('Debe ingresar la dosis');
      return false;
    }
    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  void dispose() {
    _loteController.dispose();
    _areaController.dispose();
    _dosisController.dispose();
    super.dispose();
  }
}