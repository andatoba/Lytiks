import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/moko_capacitaciones_service.dart';

class AgrotecbanMokoCapacitacionScreen extends StatefulWidget {
  final Map<String, dynamic>? clientData;

  const AgrotecbanMokoCapacitacionScreen({
    super.key,
    this.clientData,
  });

  @override
  State<AgrotecbanMokoCapacitacionScreen> createState() =>
      _AgrotecbanMokoCapacitacionScreenState();
}

class _AgrotecbanMokoCapacitacionScreenState
    extends State<AgrotecbanMokoCapacitacionScreen> {
  final MokoCapacitacionesService _service = MokoCapacitacionesService();
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _temaController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _participantesController = TextEditingController();
  final List<String> _fotos = [];
  List<Map<String, dynamic>> _capacitaciones = [];
  int _totalCapacitaciones = 0;
  bool _guardando = false;
  bool _cargando = false;

  @override
  void initState() {
    super.initState();
    _cargarCapacitaciones();
  }

  @override
  void dispose() {
    _temaController.dispose();
    _descripcionController.dispose();
    _participantesController.dispose();
    super.dispose();
  }

  int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  int? get _clienteId =>
      _toInt(widget.clientData?['clienteId']) ?? _toInt(widget.clientData?['id']);
  int? get _haciendaId => _toInt(widget.clientData?['haciendaId']);
  int? get _loteId => _toInt(widget.clientData?['loteId']);
  String get _hacienda => widget.clientData?['hacienda']?.toString() ?? '';
  String get _lote => widget.clientData?['lote']?.toString() ?? 'Sin lote';

  Future<void> _cargarCapacitaciones() async {
    final clienteId = _clienteId;
    if (clienteId == null) return;

    setState(() {
      _cargando = true;
    });

    try {
      final capacitaciones = await _service.getCapacitacionesByCliente(
        clienteId: clienteId,
        hacienda: _hacienda,
        lote: _lote,
      );
      final total = await _service.countCapacitacionesByCliente(
        clienteId: clienteId,
        hacienda: _hacienda,
        lote: _lote,
      );
      if (!mounted) return;
      setState(() {
        _capacitaciones = capacitaciones;
        _totalCapacitaciones = total;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar capacitaciones: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _cargando = false;
        });
      }
    }
  }

  Future<void> _tomarFoto() async {
    final foto = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    if (foto == null || !mounted) return;
    setState(() {
      _fotos.add(foto.path);
    });
  }

  Future<void> _guardar() async {
    final clienteId = _clienteId;
    if (clienteId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo determinar el cliente.')),
      );
      return;
    }
    if (_temaController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingrese el tema de la capacitación.')),
      );
      return;
    }

    setState(() {
      _guardando = true;
    });

    try {
      await _service.registrarCapacitacion(
        clienteId: clienteId,
        haciendaId: _haciendaId,
        loteId: _loteId,
        hacienda: _hacienda,
        lote: _lote,
        tema: _temaController.text.trim(),
        descripcion: _descripcionController.text.trim(),
        participantes: int.tryParse(_participantesController.text.trim()) ?? 0,
        fotos: _fotos,
      );
      _temaController.clear();
      _descripcionController.clear();
      _participantesController.clear();
      _fotos.clear();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Capacitación guardada correctamente.')),
      );
      await _cargarCapacitaciones();
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar capacitación: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _guardando = false;
        });
      }
    }
  }

  List<String> _parseFotos(dynamic raw) {
    if (raw is List) {
      return raw.map((e) => e.toString()).toList();
    }
    if (raw is String && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          return decoded.map((e) => e.toString()).toList();
        }
      } catch (_) {}
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF6A1B9A),
        foregroundColor: Colors.white,
        title: const Text('Capacitación Moko'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Finca: ${_hacienda.isEmpty ? 'Sin finca' : _hacienda}'),
                  const SizedBox(height: 4),
                  Text('Lote: $_lote'),
                  const SizedBox(height: 8),
                  Text(
                    'Capacitaciones registradas en esta finca/lote: $_totalCapacitaciones',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _temaController,
            decoration: const InputDecoration(
              labelText: 'Tema',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descripcionController,
            minLines: 2,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Descripción',
              hintText: 'Algo pequeño de lo que se habló',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _participantesController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Participantes',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _tomarFoto,
            icon: const Icon(Icons.camera_alt_outlined),
            label: const Text('Agregar foto'),
          ),
          if (_fotos.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _fotos.map((foto) {
                return Chip(
                  label: Text(foto.split('/').last),
                  onDeleted: () {
                    setState(() {
                      _fotos.remove(foto);
                    });
                  },
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _guardando ? null : _guardar,
            icon: _guardando
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
            label: Text(_guardando ? 'Guardando...' : 'Guardar capacitación'),
          ),
          const SizedBox(height: 24),
          if (_cargando) const LinearProgressIndicator(),
          const Text(
            'Capacitaciones registradas',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          if (!_cargando && _capacitaciones.isEmpty)
            const Text('No hay capacitaciones registradas todavía.'),
          ..._capacitaciones.map((capacitacion) {
            final fotos = _parseFotos(capacitacion['fotosJson']);
            return Card(
              child: ListTile(
                title: Text(capacitacion['tema']?.toString() ?? 'Sin tema'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(capacitacion['descripcion']?.toString() ?? ''),
                    const SizedBox(height: 4),
                    Text('Participantes: ${capacitacion['participantes'] ?? 0}'),
                    Text('Fotos: ${fotos.length}'),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
