import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/offline_storage_service.dart';
import '../services/plan_seguimiento_moko_service.dart';
import 'fase_detalle_screen.dart';

class Fase1Screen extends StatefulWidget {
  final Map<String, dynamic> fase;
  final Map<String, dynamic>? ejecucion;
  final int focoId;
  final PlanSeguimientoMokoService service;

  const Fase1Screen({
    super.key,
    required this.fase,
    this.ejecucion,
    required this.focoId,
    required this.service,
  });

  @override
  State<Fase1Screen> createState() => _Fase1ScreenState();
}

class _Fase1ScreenState extends State<Fase1Screen> {
  String? _observacionesOverride;

  @override
  void initState() {
    super.initState();
    _observacionesOverride = widget.ejecucion?['observaciones']?.toString();
  }

  void _actualizarObservaciones(String observaciones) {
    setState(() {
      _observacionesOverride = observaciones;
    });
  }

  @override
  Widget build(BuildContext context) {
    int? parseInt(dynamic value) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }

    final planSeguimientoId = parseInt(widget.fase['id']) ?? 0;
    final ejecucionPlanId = parseInt(widget.ejecucion?['id']);

    return DefaultTabController(
      length: 1,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: const Color(0xFFC62828),
          foregroundColor: Colors.white,
          elevation: 0,
          title: Text('Fase 1 - ${widget.fase['nombre'] ?? ''}'),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Detalles'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            FaseDetalleScreen(
              fase: widget.fase,
              ejecucion: widget.ejecucion,
              focoId: widget.focoId,
              service: widget.service,
              observacionesOverride: _observacionesOverride,
              embedded: true,
            ),
          ],
        ),
      ),
    );
  }
}

// Script integrado para Fase 1
class Fase1ScriptPage extends StatefulWidget {
  final PlanSeguimientoMokoService service;
  final int focoId;
  final int planSeguimientoId;
  final int? ejecucionPlanId;
  final ValueChanged<String>? onSavedObservaciones;

  const Fase1ScriptPage({
    super.key,
    required this.service,
    required this.focoId,
    required this.planSeguimientoId,
    this.ejecucionPlanId,
    this.onSavedObservaciones,
  });

  @override
  State<Fase1ScriptPage> createState() => _Fase1ScriptPageState();
}

class _Fase1ScriptPageState extends State<Fase1ScriptPage> {
  final _formKey = GlobalKey<FormState>();
  final OfflineStorageService _offlineStorage = OfflineStorageService();

  String? _actividad;
  bool _isSaving = false;

  // Configuración de actividades -> productos y dosis por defecto
  final Map<String, List<Map<String, String>>> _config = {
    'INYECCIÓN CON GLIFOSATO': [
      {'producto': 'GLIFOSATO', 'dosis': '50CC / UNIDAD BIOLÓGICA'},
    ],
    'ACELERACIÓN DE DESCOMPOSICIÓN DEGRADEX + SAFERSOIL': [
      {'producto': 'DEGRADEX', 'dosis': '2 LT'},
      {'producto': 'SAFERSOIL', 'dosis': '200 GR'},
    ],
  };

  // Controladores de dosis (se recrean según la actividad seleccionada)
  List<TextEditingController> _dosisControllers = [];

  void _initControllersForActividad(String actividad) {
    for (final c in _dosisControllers) {
      c.dispose();
    }
    final items = _config[actividad] ?? [];
    _dosisControllers = items
        .map((i) => TextEditingController(text: i['dosis'] ?? ''))
        .toList();
  }

  int? _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  Future<int?> _resolveEjecucionPlanId() async {
    final existing = widget.ejecucionPlanId;
    if (existing != null && existing > 0) {
      return existing;
    }

    try {
      await widget.service.inicializarPlan(widget.focoId);
      final estado = await widget.service.getEstadoPlan(widget.focoId);
      final ejecuciones = estado['ejecuciones'] as List<dynamic>? ?? [];
      for (final ejecucion in ejecuciones) {
        final planId = _parseInt(ejecucion['planSeguimiento']?['id']);
        if (planId == widget.planSeguimientoId) {
          return _parseInt(ejecucion['id']);
        }
      }
    } catch (_) {}

    return null;
  }

  void _volverADetalles() {
    final controller = DefaultTabController.of(context);
    controller?.animateTo(0);
  }

  Future<void> _guardarScript(Map<String, dynamic> payload) async {
    if (_isSaving) return;

    setState(() => _isSaving = true);

    final observaciones = jsonEncode(payload);

    try {
      final ejecucionPlanId = await _resolveEjecucionPlanId();
      if (ejecucionPlanId == null) {
        throw Exception('Sin ejecución disponible');
      }

      await widget.service.actualizarObservaciones(
        ejecucionPlanId,
        observaciones: observaciones,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Datos guardados correctamente')),
        );
      }
    } catch (e) {
      await _offlineStorage.savePendingPlanMokoUpdate(
        focoId: widget.focoId,
        planSeguimientoId: widget.planSeguimientoId,
        ejecucionPlanId: widget.ejecucionPlanId,
        tareasCompletadas: const [],
        observaciones: observaciones,
        finalizar: false,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Guardado offline. Se sincronizará luego.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } finally {
      widget.onSavedObservaciones?.call(observaciones);
      if (mounted) {
        setState(() => _isSaving = false);
      }
      _volverADetalles();
    }
  }

  @override
  void dispose() {
    for (final c in _dosisControllers) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final actividades = _config.keys.toList();

    final productos =
        _actividad != null ? _config[_actividad!]! : <Map<String, String>>[];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _actividad,
              decoration: const InputDecoration(labelText: 'Actividad'),
              items: actividades
                  .map((a) => DropdownMenuItem(value: a, child: Text(a)))
                  .toList(),
              onChanged: (v) {
                if (v == null) return;
                setState(() {
                  _actividad = v;
                  _initControllersForActividad(v);
                });
              },
              validator: (v) => v == null ? 'Seleccione una actividad' : null,
            ),
            const SizedBox(height: 20),
            if (_actividad != null)
              Expanded(
                child: ListView.builder(
                  itemCount: productos.length,
                  itemBuilder: (context, i) {
                    final producto = productos[i]['producto'] ?? '';
                    final controller = _dosisControllers.length > i
                        ? _dosisControllers[i]
                        : TextEditingController();
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Producto',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              producto,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: controller,
                              decoration: const InputDecoration(
                                labelText: 'Dosis (editable)',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.text,
                              validator: (v) => (v == null || v.isEmpty)
                                  ? 'Ingrese la dosis para el producto'
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ElevatedButton(
              onPressed: _isSaving
                  ? null
                  : () {
                      if (!(_formKey.currentState?.validate() ?? false)) {
                        return;
                      }
                      if (_actividad == null) {
                        return;
                      }

                      final productosPayload = <Map<String, String>>[];
                      for (var i = 0; i < productos.length; i++) {
                        final producto = productos[i]['producto'] ?? '';
                        final dosis = _dosisControllers.length > i
                            ? _dosisControllers[i].text.trim()
                            : '';
                        productosPayload.add({
                          'producto': producto,
                          'dosis': dosis,
                        });
                      }

                      final payload = {
                        'fase': 'LABORES EN FOCOS',
                        'actividad': _actividad,
                        'focoId': widget.focoId,
                        'planSeguimientoId': widget.planSeguimientoId,
                        'productos': productosPayload,
                        'fecha': DateTime.now().toIso8601String(),
                      };

                      _guardarScript(payload);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A365D),
                foregroundColor: Colors.white,
              ),
              child: _isSaving
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
