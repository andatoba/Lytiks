import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/offline_storage_service.dart';
import '../services/plan_seguimiento_moko_service.dart';

class FaseDetalleScreen extends StatefulWidget {
  final Map<String, dynamic> fase;
  final Map<String, dynamic>? ejecucion;
  final int focoId;
  final PlanSeguimientoMokoService service;
  final bool embedded;
  final String? observacionesOverride;

  const FaseDetalleScreen({
    super.key,
    required this.fase,
    this.ejecucion,
    required this.focoId,
    required this.service,
    this.embedded = false,
    this.observacionesOverride,
  });

  @override
  State<FaseDetalleScreen> createState() => _FaseDetalleScreenState();
}

class _FaseDetalleScreenState extends State<FaseDetalleScreen> {
  final OfflineStorageService _offlineStorage = OfflineStorageService();

  List<Map<String, dynamic>> _tareas = [];
  Map<int, bool> _tareasCompletadas = {};
  Map<int, TextEditingController> _dosisControllers = {};
  Map<int, String> _dosisEditadas = {};
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void dispose() {
    for (final controller in _dosisControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _cargarTareas();
  }

  Future<void> _cargarTareas() async {
    try {
      if (widget.ejecucion != null) {
        final ejecucionId = widget.ejecucion!['id'];
        final tareas = await widget.service.getTareasEjecucion(ejecucionId);

        setState(() {
          _tareas = tareas;
          for (var tarea in tareas) {
            final tareaId = tarea['id'];
            _tareasCompletadas[tareaId] = tarea['completado'] ?? false;

            // Inicializar controlador de dosis
            final dosisInicial =
                tarea['itemTarea']?['dosis'] ?? tarea['dosis'] ?? '';
            _dosisControllers[tareaId] =
                TextEditingController(text: dosisInicial);
            _dosisEditadas[tareaId] = dosisInicial;
          }
          _isLoading = false;
        });
      } else {
        final tareas = widget.fase['tareas'] ?? [];
        setState(() {
          _tareas = List<Map<String, dynamic>>.from(tareas);
          for (var tarea in _tareas) {
            final tareaId = tarea['id'];
            _tareasCompletadas[tareaId] = false;

            // Inicializar controlador de dosis
            final dosisInicial =
                tarea['itemTarea']?['dosis'] ?? tarea['dosis'] ?? '';
            _dosisControllers[tareaId] =
                TextEditingController(text: dosisInicial);
            _dosisEditadas[tareaId] = dosisInicial;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error al cargar tareas: $e');
      final tareas = widget.fase['tareas'] ?? [];
      setState(() {
        _tareas = List<Map<String, dynamic>>.from(tareas);
        for (var tarea in _tareas) {
          final tareaId = tarea['id'];
          _tareasCompletadas[tareaId] = false;

          // Inicializar controlador de dosis
          final dosisInicial =
              tarea['itemTarea']?['dosis'] ?? tarea['dosis'] ?? '';
          _dosisControllers[tareaId] =
              TextEditingController(text: dosisInicial);
          _dosisEditadas[tareaId] = dosisInicial;
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _guardarYFinalizar() async {
    setState(() => _isSaving = true);

    final tareasCompletadas = _tareasCompletadas.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    // TODO: Implementar guardado de dosis editadas en el backend
    // final dosisEditadas = <String, dynamic>{};
    // for (final entry in _dosisEditadas.entries) {
    //   dosisEditadas[entry.key.toString()] = entry.value;
    // }

    bool shouldPop = false;

    try {
      if (widget.ejecucion != null) {
        final ejecucionId = widget.ejecucion!['id'];

        await widget.service.actualizarTareas(ejecucionId, tareasCompletadas);

        // TODO: Descomentar cuando se implemente en el backend
        // if (dosisEditadas.isNotEmpty) {
        //   await widget.service.actualizarDosisEditadas(ejecucionId, dosisEditadas);
        // }

        await widget.service.finalizarRevision(ejecucionId);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Revisión guardada exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
        shouldPop = true;
      } else {
        throw Exception('Ejecución no disponible para guardar en línea');
      }
    } catch (e) {
      await _guardarPlanOffline(tareasCompletadas);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Guardado offline. Se sincronizará cuando haya conexión.',
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
      shouldPop = true;
    } finally {
      if (mounted && !shouldPop) {
        setState(() => _isSaving = false);
      }
    }

    if (mounted && shouldPop) {
      Navigator.pop(context, true);
    }
  }

  Future<void> _guardarPlanOffline(List<int> tareasCompletadas) async {
    int? ejecucionPlanId;
    final rawEjecucionId = widget.ejecucion?['id'];
    if (rawEjecucionId is int) {
      ejecucionPlanId = rawEjecucionId;
    } else if (rawEjecucionId != null) {
      ejecucionPlanId = int.tryParse(rawEjecucionId.toString());
    }

    int planSeguimientoId = 0;
    final rawPlanId =
        widget.ejecucion?['planSeguimiento']?['id'] ?? widget.fase['id'];
    if (rawPlanId is int) {
      planSeguimientoId = rawPlanId;
    } else if (rawPlanId != null) {
      planSeguimientoId = int.tryParse(rawPlanId.toString()) ?? 0;
    }

    await _offlineStorage.savePendingPlanMokoUpdate(
      focoId: widget.focoId,
      planSeguimientoId: planSeguimientoId,
      ejecucionPlanId: ejecucionPlanId,
      tareasCompletadas: tareasCompletadas,
      observaciones: null,
      finalizar: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final nombre = _limpiarTexto(widget.fase['nombre'] ?? 'Fase');
    final detalle = _limpiarTexto(widget.fase['detalle']?.toString() ?? '');

    final body = _buildBody(detalle);

    if (widget.embedded) {
      return Container(
        color: Colors.grey[100],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: body),
            _buildActionButton(),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A365D),
        title: Text(
          nombre,
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: body,
      bottomNavigationBar: _buildActionButton(),
    );
  }

  Widget _buildBody(String detalle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(detalle),
        _buildObservacionesSummary(),
        const Divider(height: 1),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildTareasList(),
        ),
      ],
    );
  }

  Widget _buildObservacionesSummary() {
    final raw =
        widget.observacionesOverride ?? widget.ejecucion?['observaciones'];
    if (raw == null) return const SizedBox.shrink();

    final rawText = raw.toString().trim();
    if (rawText.isEmpty) return const SizedBox.shrink();

    Map<String, dynamic>? data;
    try {
      final decoded = jsonDecode(rawText);
      if (decoded is Map<String, dynamic>) {
        data = decoded;
      }
    } catch (_) {}

    final title = _limpiarTexto(
      data?['fase']?.toString() ?? 'Productos y dosis',
    );
    final actividad = _limpiarTexto(data?['actividad']?.toString() ?? '');
    final children = <Widget>[];

    if (actividad.isNotEmpty) {
      children.add(
        Text(
          'Actividad: $actividad',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
      children.add(const SizedBox(height: 8));
    }

    void addProductos(List<dynamic> productos) {
      for (final item in productos) {
        if (item is! Map) continue;
        final producto = _limpiarTexto(item['producto']?.toString() ?? '');
        final dosis = _limpiarTexto(item['dosis']?.toString() ?? '');
        if (producto.isEmpty && dosis.isEmpty) continue;
        final detalle = dosis.isNotEmpty ? ' - $dosis' : '';
        children.add(
          Text(
            '- $producto$detalle',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        );
      }
      if (productos.isNotEmpty) {
        children.add(const SizedBox(height: 8));
      }
    }

    if (data?['productos'] is List) {
      addProductos(List<dynamic>.from(data!['productos']));
    }

    if (data?['vacios'] is List) {
      final vacios = List<dynamic>.from(data!['vacios']);
      for (final vacio in vacios) {
        if (vacio is! Map) continue;
        final nombre = _limpiarTexto(vacio['vacio']?.toString() ?? '');
        if (nombre.isNotEmpty) {
          children.add(
            Text(
              nombre,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          );
        }
        final productos = vacio['productos'];
        if (productos is List) {
          addProductos(List<dynamic>.from(productos));
        }
      }
    }

    if (data?['ciclos'] is List) {
      final ciclos = List<dynamic>.from(data!['ciclos']);
      for (final ciclo in ciclos) {
        if (ciclo is! Map) continue;
        final nombre = _limpiarTexto(ciclo['ciclo']?.toString() ?? '');
        final descripcion =
            _limpiarTexto(ciclo['descripcion']?.toString() ?? '');
        if (nombre.isNotEmpty) {
          final label =
              descripcion.isNotEmpty ? '$nombre - $descripcion' : nombre;
          children.add(
            Text(
              label,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          );
        }
        final productos = ciclo['productos'];
        if (productos is List) {
          addProductos(List<dynamic>.from(productos));
        }
      }
    }

    if (children.isEmpty) {
      children.add(
        Text(
          _limpiarTexto(rawText),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
     );
  }

  Widget _buildHeader(String detalle) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DETALLE DE EJECUCIÓN',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (detalle.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              detalle,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isSaving ? null : _guardarYFinalizar,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A365D),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _isSaving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'FINALIZAR REVISIÓN',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildTareasList() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Text(
            'TAREAS REQUERIDAS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        ..._tareas.map((tarea) {
          final tareaId = tarea['id'] ?? tarea['itemTarea']?['id'];
          final nombre = _limpiarTexto(
            tarea['itemTarea']?['nombre'] ?? tarea['nombre'] ?? '',
          );
          final dosisOriginal = _limpiarTexto(
            tarea['itemTarea']?['dosis'] ?? tarea['dosis'] ?? '',
          );
          final completado = _tareasCompletadas[tareaId] ?? false;

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: completado,
                        onChanged: (value) {
                          setState(() {
                            _tareasCompletadas[tareaId] = value ?? false;
                          });
                        },
                        activeColor: const Color(0xFF1A365D),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nombre,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                decoration: completado
                                    ? TextDecoration.lineThrough
                                    : null,
                                color:
                                    completado ? Colors.grey : Colors.black87,
                              ),
                            ),
                            if (dosisOriginal.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Text(
                                    'Dosis: ',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _dosisControllers[tareaId],
                                      style: const TextStyle(fontSize: 12),
                                      decoration: InputDecoration(
                                        isDense: true,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 8),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        hintText: dosisOriginal,
                                        hintStyle:
                                            TextStyle(color: Colors.grey[400]),
                                      ),
                                      onChanged: (value) {
                                        _dosisEditadas[tareaId] = value.trim();
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  /// Limpia caracteres mal codificados en los textos
  String _limpiarTexto(String texto) {
    if (texto.isEmpty) return texto;

    var limpio = texto;
    if (limpio.contains('Ã') || limpio.contains('Â')) {
      try {
        limpio = utf8.decode(latin1.encode(limpio));
      } catch (_) {}
    }

    return limpio
        .replaceAll('Ã³', 'ó')
        .replaceAll('Ã¡', 'á')
        .replaceAll('Ã©', 'é')
        .replaceAll('Ã­', 'í')
        .replaceAll('Ãº', 'ú')
        .replaceAll('Ã±', 'ñ')
        .replaceAll('Ã', 'Í')
        .replaceAll('ÃN', 'IÓN')
        .replaceAll('INYECCIÃ"N', 'INYECCIÓN')
        .replaceAll('ACELERACIÃ"N', 'ACELERACIÓN')
        .replaceAll('APLICACIÃ"N', 'APLICACIÓN')
        .replaceAll('COMPOSICIÃ"N', 'COMPOSICIÓN')
        .replaceAll('REDUCCIÃ"N', 'REDUCCIÓN')
        .replaceAll('ELIMINACIÃ"N', 'ELIMINACIÓN')
        .replaceAll('ACTIVACIÃ"N', 'ACTIVACIÓN')
        .replaceAll('Ã"N', 'ÓN')
        .replaceAll('Ã ', 'Á')
        .replaceAll('RÃ¡PIDA', 'RÁPIDA')
        .replaceAll('rÃ¡pida', 'rápida')
        .replaceAll('BIOLÃ³GICA', 'BIOLÓGICA')
        .replaceAll('biolÃ³gica', 'biológica')
        .replaceAll('PATÃ³GENO', 'PATÓGENO')
        .replaceAll('patÃ³geno', 'patógeno');
  }
}
