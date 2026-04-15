import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/moko_muestras_service.dart';

class AgrotecbanMokoMuestraFormScreen extends StatefulWidget {
  final Map<String, dynamic>? clientData;
  final String tipoMuestra;
  final String titulo;

  const AgrotecbanMokoMuestraFormScreen({
    super.key,
    this.clientData,
    required this.tipoMuestra,
    required this.titulo,
  });

  @override
  State<AgrotecbanMokoMuestraFormScreen> createState() =>
      _AgrotecbanMokoMuestraFormScreenState();
}

class _AgrotecbanMokoMuestraFormScreenState
    extends State<AgrotecbanMokoMuestraFormScreen> {
  final MokoMuestrasService _service = MokoMuestrasService();
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _busquedaController = TextEditingController();
  final TextEditingController _resultadoController = TextEditingController();
  final List<_MuestraDraft> _muestras = [];
  List<Map<String, dynamic>> _muestrasGuardadas = [];
  bool _guardando = false;
  bool _cargando = false;
  String? _documentoPath;

  @override
  void initState() {
    super.initState();
    _muestras.add(_MuestraDraft(numero: 1));
    _cargarMuestras();
  }

  @override
  void dispose() {
    _busquedaController.dispose();
    _resultadoController.dispose();
    for (final muestra in _muestras) {
      muestra.dispose();
    }
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

  String get _lote =>
      widget.clientData?['lote']?.toString().trim().isNotEmpty == true
          ? widget.clientData!['lote'].toString().trim()
          : 'Sin lote';

  Future<void> _cargarMuestras() async {
    final clienteId = _clienteId;
    if (clienteId == null) {
      return;
    }

    setState(() {
      _cargando = true;
    });

    try {
      final muestras = await _service.getMuestrasByCliente(
        clienteId: clienteId,
        lote: _lote,
        tipo: widget.tipoMuestra,
        query: _busquedaController.text.trim(),
      );
      if (!mounted) return;
      setState(() {
        _muestrasGuardadas = muestras;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar muestras: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _cargando = false;
        });
      }
    }
  }

  void _agregarOtraMuestra() {
    if (_muestras.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solo se permiten hasta 5 muestras.')),
      );
      return;
    }
    setState(() {
      _muestras.add(_MuestraDraft(numero: _muestras.length + 1));
    });
  }

  Future<void> _tomarFoto(_MuestraDraft muestra) async {
    final foto = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    if (foto == null || !mounted) {
      return;
    }
    setState(() {
      muestra.fotoPath = foto.path;
    });
  }

  Future<void> _guardarMuestras() async {
    final clienteId = _clienteId;
    if (clienteId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo determinar el cliente.')),
      );
      return;
    }

    for (final muestra in _muestras) {
      if (muestra.codigoController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Complete el codigo de la muestra ${muestra.numero}.')),
        );
        return;
      }
    }

    setState(() {
      _guardando = true;
    });

    try {
      for (final muestra in _muestras) {
        if (muestra.guardada) {
          continue;
        }
        await _service.registrarMuestra(
          clienteId: clienteId,
          haciendaId: _haciendaId,
          loteId: _loteId,
          lote: _lote,
          tipoMuestra: widget.tipoMuestra,
          muestraNumero: muestra.numero,
          codigo: muestra.codigoController.text.trim(),
          descripcion: muestra.descripcionController.text.trim(),
          fotoPath: muestra.fotoPath,
        );
        muestra.guardada = true;
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Muestras guardadas correctamente.')),
      );
      await _cargarMuestras();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar muestras: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _guardando = false;
        });
      }
    }
  }

  Future<void> _subirResultado(Map<String, dynamic> muestra) async {
    final muestraId = _toInt(muestra['id']);
    if (muestraId == null) {
      return;
    }
    _resultadoController.text =
        muestra['resultadoLaboratorio']?.toString() ?? '';
    _documentoPath = null;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Resultado laboratorio - ${muestra['codigo'] ?? ''}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _resultadoController,
                    minLines: 3,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'Resultado / analisis',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final result = await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'txt'],
                      );
                      if (result == null || result.files.single.path == null) {
                        return;
                      }
                      setModalState(() {
                        _documentoPath = result.files.single.path;
                      });
                    },
                    icon: const Icon(Icons.upload_file),
                    label: Text(
                      _documentoPath == null
                          ? 'Subir documento'
                          : _documentoPath!.split('/').last,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        try {
                          await _service.cargarResultadoLaboratorio(
                            muestraId: muestraId,
                            resultadoLaboratorio:
                                _resultadoController.text.trim(),
                            documentoPath: _documentoPath,
                          );
                          if (!mounted) return;
                          Navigator.pop(context);
                          ScaffoldMessenger.of(this.context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Resultado de laboratorio guardado correctamente.',
                              ),
                            ),
                          );
                          await _cargarMuestras();
                        } catch (e) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(this.context).showSnackBar(
                            SnackBar(content: Text('Error al subir resultado: $e')),
                          );
                        }
                      },
                      child: const Text('Guardar resultado'),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF00695C),
        foregroundColor: Colors.white,
        title: Text(widget.titulo),
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
                  Text('Lote: $_lote',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    'Puede registrar hasta 5 muestras. Agregue otra solo si la tomo.',
                    style: TextStyle(color: Colors.grey[700], fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          ..._muestras.map(_buildMuestraCard),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _muestras.length >= 5 ? null : _agregarOtraMuestra,
            icon: const Icon(Icons.add),
            label: const Text('Agregar otra muestra'),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _guardando ? null : _guardarMuestras,
            icon: _guardando
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.cloud_upload_outlined),
            label: Text(_guardando ? 'Guardando...' : 'Guardar muestras'),
          ),
          const SizedBox(height: 24),
          const Text(
            'Buscar muestras registradas',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _busquedaController,
                  decoration: const InputDecoration(
                    hintText: 'Buscar por codigo o descripcion',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: _cargarMuestras,
                icon: const Icon(Icons.search),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_cargando) const LinearProgressIndicator(),
          if (!_cargando && _muestrasGuardadas.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('No hay muestras registradas para este cliente/lote.'),
            ),
          ..._muestrasGuardadas.map((muestra) {
            final documento = muestra['documentoLaboratorioNombre']?.toString() ?? '';
            return Card(
              child: ListTile(
                title: Text(
                  'Muestra ${muestra['muestraNumero'] ?? ''} - ${muestra['codigo'] ?? ''}',
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(muestra['descripcion']?.toString() ?? 'Sin descripcion'),
                    const SizedBox(height: 4),
                    Text('Lote: ${muestra['lote'] ?? ''}'),
                    if (documento.isNotEmpty) Text('Documento: $documento'),
                    if ((muestra['resultadoLaboratorio']?.toString() ?? '').isNotEmpty)
                      Text(
                        'Analisis: ${muestra['resultadoLaboratorio']}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.upload_file),
                  onPressed: () => _subirResultado(muestra),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMuestraCard(_MuestraDraft muestra) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        initiallyExpanded: true,
        title: Text('Muestra N° ${muestra.numero}'),
        subtitle: Text(
          muestra.guardada
              ? 'Guardada en servidor'
              : 'Pendiente por guardar',
        ),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFDADADA)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Lote: $_lote',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: muestra.codigoController,
            decoration: const InputDecoration(
              labelText: 'Codigo',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: muestra.descripcionController,
            minLines: 2,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Descripcion',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => _tomarFoto(muestra),
            icon: const Icon(Icons.camera_alt_outlined),
            label: Text(
              muestra.fotoPath == null ? 'Tomar foto' : 'Cambiar foto',
            ),
          ),
          if (muestra.fotoPath != null) ...[
            const SizedBox(height: 6),
            Text(
              'Foto: ${muestra.fotoPath!.split('/').last}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}

class _MuestraDraft {
  final int numero;
  final TextEditingController codigoController = TextEditingController();
  final TextEditingController descripcionController = TextEditingController();
  String? fotoPath;
  bool guardada = false;

  _MuestraDraft({required this.numero});

  void dispose() {
    codigoController.dispose();
    descripcionController.dispose();
  }
}
