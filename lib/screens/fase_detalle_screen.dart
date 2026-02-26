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
  Map<int, DateTime?> _fechasAplicacion = {};
  Map<int, int> _frecuenciasDias = {};
  Map<int, int> _repeticiones = {};
  Map<int, String> _recordatorios = {};
  bool _isLoading = true;
  bool _isSaving = false;

  // Helper para convertir tareaId a int de forma segura
  int? _convertirATareaIdInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) {
      try {
        return int.parse(value);
      } catch (e) {
        print('❌ ERROR: No se pudo convertir tareaId "$value" a int: $e');
        return null;
      }
    }
    print('❌ ERROR: tareaId tiene tipo inesperado: ${value.runtimeType}');
    return null;
  }

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
    _cargarConfiguracionesGuardadas();
  }

  Future<void> _cargarTareas() async {
    try {
      if (widget.ejecucion != null) {
        final ejecucionId = widget.ejecucion!['id'];
        final tareas = await widget.service.getTareasEjecucion(ejecucionId);

        print('🐛 DEBUG: Cargando tareas con ejecución. Total: ${tareas.length}');
        setState(() {
          _tareas = tareas;
          for (var tarea in tareas) {
            final tareaIdRaw = tarea['id'] ?? tarea['itemTarea']?['id'];
            final tareaId = _convertirATareaIdInt(tareaIdRaw);
            if (tareaId == null) {
              print('⚠️ ADVERTENCIA: Tarea sin ID válido o no convertible: $tareaIdRaw (tipo: ${tareaIdRaw.runtimeType})');
              continue;
            }
            
            print('🐛 DEBUG: Tarea ID: $tareaId (tipo: ${tareaId.runtimeType}), Nombre: ${tarea['itemTarea']?['nombre'] ?? tarea['nombre']}');
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
        print('🐛 DEBUG: Cargando tareas sin ejecución. Total: ${tareas.length}');
        setState(() {
          _tareas = List<Map<String, dynamic>>.from(tareas);
          for (var tarea in _tareas) {
            final tareaIdRaw = tarea['id'] ?? tarea['itemTarea']?['id'];
            final tareaId = _convertirATareaIdInt(tareaIdRaw);
            if (tareaId == null) {
              print('⚠️ ADVERTENCIA: Tarea sin ID válido o no convertible: $tareaIdRaw (tipo: ${tareaIdRaw.runtimeType})');
              continue;
            }
            
            print('🐛 DEBUG: Tarea ID: $tareaId, Nombre: ${tarea['itemTarea']?['nombre'] ?? tarea['nombre']}');
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
          final tareaIdRaw = tarea['id'];
          final tareaId = _convertirATareaIdInt(tareaIdRaw);
          if (tareaId == null) {
            print('⚠️ ADVERTENCIA: Tarea sin ID válido en catch: $tareaIdRaw');
            continue;
          }
          
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

  Future<void> _cargarConfiguracionesGuardadas() async {
    try {
      print('📂 Cargando configuraciones guardadas para Foco: ${widget.focoId}, Fase: ${widget.fase['id']}');
      
      final configuraciones = await _offlineStorage.obtenerConfiguracionesAplicacion(
        focoId: widget.focoId,
        faseId: widget.fase['id'],
      );
      
      print('📂 Configuraciones encontradas: ${configuraciones.length}');
      
      for (var config in configuraciones) {
        print('📂 Config: TareaID=${config['tarea_id']}, Fecha=${config['fecha_programada']}, Frecuencia=${config['frecuencia']}días, Repeticiones=${config['repeticiones']}');
        
        final tareaIdRaw = config['tarea_id'];
        final tareaId = _convertirATareaIdInt(tareaIdRaw);
        if (tareaId == null) {
          print('⚠️ ADVERTENCIA: Config sin tareaId válido: $tareaIdRaw');
          continue;
        }
        
        setState(() {
          // Cargar fecha
          if (config['fecha_programada'] != null) {
            _fechasAplicacion[tareaId] = DateTime.parse(config['fecha_programada']);
          }
          // Cargar frecuencia
          if (config['frecuencia'] != null) {
            _frecuenciasDias[tareaId] = config['frecuencia'] as int;
          }
          // Cargar repeticiones
          if (config['repeticiones'] != null) {
            _repeticiones[tareaId] = config['repeticiones'] as int;
          }
          // Cargar recordatorio
          if (config['recordatorio'] != null) {
            _recordatorios[tareaId] = config['recordatorio'];
          }
        });
      }
      
      print('✅ Configuraciones cargadas exitosamente');
    } catch (e) {
      print('❌ Error cargando configuraciones guardadas: $e');
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
        backgroundColor: const Color(0xFFC62828),
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
              backgroundColor: const Color(0xFFC62828),
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
          final tareaIdRaw = tarea['id'] ?? tarea['itemTarea']?['id'];
          final tareaId = _convertirATareaIdInt(tareaIdRaw);
          
          // Si no hay tareaId válido, saltar esta tarea
          if (tareaId == null) {
            print('⚠️ ADVERTENCIA: Tarea sin ID válido en render: $tareaIdRaw (tipo: ${tareaIdRaw.runtimeType})');
            return const SizedBox.shrink();
          }
          
          print('🎨 RENDER: Tarea ID: $tareaId (tipo: ${tareaId.runtimeType})');
          
          final nombre = _limpiarTexto(
            tarea['itemTarea']?['nombre'] ?? tarea['nombre'] ?? '',
          );
          final dosisOriginal = _limpiarTexto(
            tarea['itemTarea']?['dosis'] ?? tarea['dosis'] ?? '',
          );
          final completado = _tareasCompletadas[tareaId] ?? false;
          print('🎨 RENDER: TareaID $tareaId - Completado: $completado - Map keys: ${_tareasCompletadas.keys.toList()}');

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
                          print('🐛 DEBUG: Checkbox cambiado para tarea $tareaId: $value');
                          setState(() {
                            _tareasCompletadas[tareaId] = value ?? false;
                            print('🐛 DEBUG: Estados completados: $_tareasCompletadas');
                            // Si se marca, mostrar selector de fecha
                            if (value == true) {
                              _mostrarSelectorFecha(context, tareaId);
                            }
                          });
                        },
                        activeColor: const Color(0xFFC62828),
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
                            // Mostrar calendario si está marcado
                            if (completado) ...[
                              const SizedBox(height: 12),
                              Builder(
                                builder: (context) {
                                  print('🐛 DEBUG: Mostrando configuración para tarea $tareaId');
                                  return _buildConfiguracionAplicacion(tareaId);
                                },
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
        const SizedBox(height: 80),
      ],
    );
  }

  bool _esProyeccion(String nombre) {
    final nombreLower = nombre.toLowerCase();
    return nombreLower.contains('proyección') || 
           nombreLower.contains('proyeccion') ||
           nombreLower.contains('glifosato') ||
           nombreLower.contains('aplicación') ||
           nombreLower.contains('aplicacion') ||
           nombreLower.contains('tratamiento') ||
           nombreLower.contains('control') ||
           nombreLower.contains('erradicación') ||
           nombreLower.contains('erradicacion') ||
           nombreLower.contains('fumigación') ||
           nombreLower.contains('fumigacion') ||
           nombreLower.contains('inyección') ||
           nombreLower.contains('inyeccion') ||
           nombreLower.contains('herbicida') ||
           nombreLower.contains('fungicida') ||
           nombreLower.contains('bactericida') ||
           nombreLower.contains('aspersión') ||
           nombreLower.contains('aspersion') ||
           nombreLower.contains('aplicar') ||
           nombreLower.contains('producto') ||
           nombreLower.contains('químico') ||
           nombreLower.contains('quimico');
  }

  Future<void> _mostrarSelectorFecha(BuildContext context, int tareaId) async {
    final fechaActual = _fechasAplicacion[tareaId] ?? DateTime.now();
    final fechaSeleccionada = await showDatePicker(
      context: context,
      initialDate: fechaActual,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('es', 'ES'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFC62828),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (fechaSeleccionada != null) {
      setState(() {
        _fechasAplicacion[tareaId] = fechaSeleccionada;
      });
    }
  }

  Widget _buildConfiguracionAplicacion(int tareaId) {
    final fecha = _fechasAplicacion[tareaId];
    final frecuenciaDias = _frecuenciasDias[tareaId] ?? 7;
    final repeticiones = _repeticiones[tareaId] ?? 1;
    final recordatorio = _recordatorios[tareaId] ?? '1 día antes';
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: Colors.red[700]),
              const SizedBox(width: 8),
              Text(
                'Configuración de Aplicación',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[900],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () => _mostrarSelectorFecha(context, tareaId),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.event, color: Colors.red[700], size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      fecha != null
                          ? 'Fecha programada: ${fecha.day}/${fecha.month}/${fecha.year}'
                          : 'Seleccionar fecha de aplicación',
                      style: TextStyle(
                        fontSize: 13,
                        color: fecha != null ? Colors.black87 : Colors.grey[600],
                      ),
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[400]),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Frecuencia
          Row(
            children: [
              Icon(Icons.repeat, size: 16, color: Colors.red[700]),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Frecuencia (días):',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        if (frecuenciaDias > 1) {
                          _frecuenciasDias[tareaId] = frecuenciaDias - 1;
                        }
                      });
                    },
                    icon: const Icon(Icons.remove_circle_outline),
                    color: Colors.red[700],
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(8),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Text(
                      '$frecuenciaDias',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        if (frecuenciaDias < 365) {
                          _frecuenciasDias[tareaId] = frecuenciaDias + 1;
                        }
                      });
                    },
                    icon: const Icon(Icons.add_circle_outline),
                    color: Colors.red[700],
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(8),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Repeticiones
          Row(
            children: [
              Icon(Icons.format_list_numbered, size: 16, color: Colors.red[700]),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Repeticiones:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        if (repeticiones > 1) {
                          _repeticiones[tareaId] = repeticiones - 1;
                        }
                      });
                    },
                    icon: const Icon(Icons.remove_circle_outline),
                    color: Colors.red[700],
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(8),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Text(
                      '$repeticiones',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        if (repeticiones < 100) {
                          _repeticiones[tareaId] = repeticiones + 1;
                        }
                      });
                    },
                    icon: const Icon(Icons.add_circle_outline),
                    color: Colors.red[700],
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(8),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Recordatorio
          Row(
            children: [
              Icon(Icons.alarm, size: 16, color: Colors.red[700]),
              const SizedBox(width: 8),
              const Text(
                'Recordatorio:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: recordatorio,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    fillColor: Colors.white,
                    filled: true,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Sin recordatorio', child: Text('Sin recordatorio', style: TextStyle(fontSize: 12))),
                    DropdownMenuItem(value: '1 hora antes', child: Text('1 hora antes', style: TextStyle(fontSize: 12))),
                    DropdownMenuItem(value: '3 horas antes', child: Text('3 horas antes', style: TextStyle(fontSize: 12))),
                    DropdownMenuItem(value: '1 día antes', child: Text('1 día antes', style: TextStyle(fontSize: 12))),
                    DropdownMenuItem(value: '2 días antes', child: Text('2 días antes', style: TextStyle(fontSize: 12))),
                    DropdownMenuItem(value: '1 semana antes', child: Text('1 semana antes', style: TextStyle(fontSize: 12))),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _recordatorios[tareaId] = value ?? '1 día antes';
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _guardarEnPlan(tareaId),
              icon: const Icon(Icons.save_outlined, size: 18),
              label: const Text('Guardar en plan'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFC62828),
                side: const BorderSide(color: Color(0xFFC62828)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _guardarEnPlan(int tareaId) async {
    final fecha = _fechasAplicacion[tareaId];
    if (fecha == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor seleccione una fecha de aplicación'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final frecuenciaDias = _frecuenciasDias[tareaId] ?? 7;
      final repeticiones = _repeticiones[tareaId] ?? 1;
      final recordatorio = _recordatorios[tareaId] ?? '1 día antes';

      print('💾 DEBUG Guardar: TareaID=$tareaId, Fecha=$fecha, Frecuencia=$frecuenciaDias, Repeticiones=$repeticiones');

      // Buscar la tarea actual
      final tarea = _tareas.firstWhere((t) => (t['id'] ?? t['itemTarea']?['id']) == tareaId);
      final nombreTarea = _limpiarTexto(
        tarea['itemTarea']?['nombre'] ?? tarea['nombre'] ?? '',
      );

      print('💾 DEBUG Guardar: Nombre tarea="$nombreTarea", FocoID=${widget.focoId}, FaseID=${widget.fase['id']}');

      // Preparar datos para guardar
      final configuracion = {
        'focoId': widget.focoId,
        'faseId': widget.fase['id'],
        'tareaId': tareaId,
        'nombreTarea': nombreTarea,
        'fechaProgramada': fecha.toIso8601String(),
        'frecuencia': frecuenciaDias,
        'repeticiones': repeticiones,
        'recordatorio': recordatorio,
        'completado': false,
        'fechaCreacion': DateTime.now().toIso8601String(),
      };

      print('💾 DEBUG Guardar: Configuración completa: $configuracion');

      // Guardar en almacenamiento offline primero
      final idLocal = await _offlineStorage.guardarConfiguracionAplicacion(configuracion);
      
      print('✅ DEBUG Guardar: ID guardado en BD local: $idLocal');

      // Intentar sincronizar con el servidor
      bool sincronizadoConServidor = false;
      try {
        final respuestaServidor = await widget.service.guardarConfiguracionAplicacion(configuracion);
        sincronizadoConServidor = respuestaServidor['success'] == true;
        print('✅ DEBUG Guardar: Sincronizado con servidor: ${respuestaServidor['configuracion']['id']}');
      } catch (e) {
        print('⚠️ DEBUG Guardar: No se pudo sincronizar con servidor (se guardó localmente): $e');
        // No mostrar error al usuario, la data está guardada localmente
      }
      
      print('✅ DEBUG Guardar: Configuración guardada correctamente con ID local: $idLocal');
      
      // Verificar que se guardó
      final configuraciones = await _offlineStorage.obtenerConfiguracionesAplicacion(
        focoId: widget.focoId,
        faseId: widget.fase['id'],
      );
      
      print('📊 DEBUG Verificar: Total configuraciones guardadas para este foco/fase: ${configuraciones.length}');
      print('📊 DEBUG Verificar: Configuraciones: $configuraciones');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sincronizadoConServidor 
                    ? '✓ Aplicación guardada y sincronizada'
                    : '✓ Aplicación guardada localmente',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text('Fecha: ${fecha.day}/${fecha.month}/${fecha.year}'),
                Text('Frecuencia: cada $frecuenciaDias días'),
                Text('Repeticiones: $repeticiones'),
                Text('Recordatorio: $recordatorio'),
                if (!sincronizadoConServidor) ...[
                  const SizedBox(height: 4),
                  const Text(
                    '📱 Se sincronizará cuando haya conexión',
                    style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
                  ),
                ],

              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
