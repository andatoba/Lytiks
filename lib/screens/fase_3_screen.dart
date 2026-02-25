import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/offline_storage_service.dart';
import '../services/plan_seguimiento_moko_service.dart';
import 'fase_detalle_screen.dart';

class Fase3Screen extends StatefulWidget {
  final Map<String, dynamic> fase;
  final Map<String, dynamic>? ejecucion;
  final int focoId;
  final PlanSeguimientoMokoService service;

  const Fase3Screen({
    super.key,
    required this.fase,
    this.ejecucion,
    required this.focoId,
    required this.service,
  });

  @override
  State<Fase3Screen> createState() => _Fase3ScreenState();
}

class _Fase3ScreenState extends State<Fase3Screen> {
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
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: const Color(0xFF1A365D),
          foregroundColor: Colors.white,
          elevation: 0,
          title: Text('Fase 3 - ${widget.fase['nombre'] ?? ''}'),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Detalles'),
              Tab(text: 'Script'),
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
            Fase3ScriptPage(
              service: widget.service,
              focoId: widget.focoId,
              planSeguimientoId: planSeguimientoId,
              ejecucionPlanId: ejecucionPlanId,
              onSavedObservaciones: _actualizarObservaciones,
            ),
          ],
        ),
      ),
    );
  }
}

// Script integrado para Fase 3
class Fase3ScriptPage extends StatefulWidget {
  final PlanSeguimientoMokoService service;
  final int focoId;
  final int planSeguimientoId;
  final int? ejecucionPlanId;
  final ValueChanged<String>? onSavedObservaciones;

  const Fase3ScriptPage({
    super.key,
    required this.service,
    required this.focoId,
    required this.planSeguimientoId,
    this.ejecucionPlanId,
    this.onSavedObservaciones,
  });

  @override
  State<Fase3ScriptPage> createState() => _Fase3ScriptPageState();
}

class _Fase3ScriptPageState extends State<Fase3ScriptPage> {
  final _formKey = GlobalKey<FormState>();
  final OfflineStorageService _offlineStorage = OfflineStorageService();

  String? _actividad;
  bool _isSaving = false;

  // Configuración de actividades -> ciclos -> productos y dosis por defecto
  final Map<String, List<Map<String, dynamic>>> _config = {
    'ACTIVACIÓN SAR': [
      {
        'ciclo': 'CICLO 1',
        'productos': [
          {'producto': 'Armorux', 'dosis': '1L'},
          {'producto': 'Aminoalexin', 'dosis': '0.5'},
        ]
      },
      {
        'ciclo': 'CICLO 2',
        'productos': [
          {'producto': 'SINERJET CU', 'dosis': '0.5'},
          {'producto': 'Aminoalexin', 'dosis': '0.5'},
        ]
      },
      {
        'ciclo': 'CICLO 3',
        'productos': [
          {'producto': 'Armorux', 'dosis': '1L'},
          {'producto': 'Aminoalexin', 'dosis': '0.5'},
        ]
      },
    ],
  };

  // Controladores de dosis organizados por ciclo
  Map<String, List<TextEditingController>> _dosisControllers = {};

  void _initControllersForActividad(String actividad) {
    // limpiar anteriores
    _dosisControllers.forEach((_, controllers) {
      controllers.forEach((c) => c.dispose());
    });
    _dosisControllers.clear();

    final ciclos = _config[actividad] ?? [];
    for (var ciclo in ciclos) {
      final productos = ciclo['productos'] as List<Map<String, String>>;
      _dosisControllers[ciclo['ciclo']] = productos
          .map((p) => TextEditingController(text: p['dosis'] ?? ''))
          .toList();
    }
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
    _dosisControllers.forEach((_, controllers) {
      controllers.forEach((c) => c.dispose());
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final actividades = _config.keys.toList();
    final ciclos = _actividad != null ? _config[_actividad!]! : [];

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
                  itemCount: ciclos.length,
                  itemBuilder: (context, cicloIndex) {
                    final ciclo = ciclos[cicloIndex];
                    final nombreCiclo = ciclo['ciclo'];
                    final productos =
                        ciclo['productos'] as List<Map<String, String>>;
                    final controllers = _dosisControllers[nombreCiclo] ?? [];

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nombreCiclo,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            ...productos.asMap().entries.map((entry) {
                              final i = entry.key;
                              final producto = entry.value;
                              final controller = controllers.length > i
                                  ? controllers[i]
                                  : TextEditingController();

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Producto',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            producto['producto'] ?? '',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      flex: 1,
                                      child: TextFormField(
                                        controller: controller,
                                        decoration: const InputDecoration(
                                          labelText: 'Dosis',
                                          border: OutlineInputBorder(),
                                          isDense: true,
                                        ),
                                        keyboardType: TextInputType.text,
                                        validator: (v) =>
                                            (v == null || v.isEmpty)
                                                ? 'Ingrese dosis'
                                                : null,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
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

                      final ciclosData = _config[_actividad!] ?? [];
                      final ciclosPayload = <Map<String, dynamic>>[];

                      for (final ciclo in ciclosData) {
                        final nombreCiclo = ciclo['ciclo']?.toString() ?? '';
                        final productos =
                            ciclo['productos'] as List<Map<String, String>>;
                        final controllers =
                            _dosisControllers[nombreCiclo] ?? [];
                        final productosPayload = <Map<String, String>>[];

                        for (var i = 0; i < productos.length; i++) {
                          productosPayload.add({
                            'producto': productos[i]['producto'] ?? '',
                            'dosis': i < controllers.length
                                ? controllers[i].text.trim()
                                : '',
                          });
                        }

                        ciclosPayload.add({
                          'ciclo': nombreCiclo,
                          'productos': productosPayload,
                        });
                      }

                      final payload = {
                        'fase': 'ACTIVACIÓN SAR',
                        'actividad': _actividad,
                        'focoId': widget.focoId,
                        'planSeguimientoId': widget.planSeguimientoId,
                        'ciclos': ciclosPayload,
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
