import 'package:flutter/material.dart';
import '../services/plan_seguimiento_moko_service.dart';

class PlanSeguimientoMokoScreen extends StatefulWidget {
  final int focoId;
  final int numeroFoco;

  const PlanSeguimientoMokoScreen({
    super.key,
    required this.focoId,
    required this.numeroFoco,
  });

  @override
  State<PlanSeguimientoMokoScreen> createState() => _PlanSeguimientoMokoScreenState();
}

class _PlanSeguimientoMokoScreenState extends State<PlanSeguimientoMokoScreen> {
  final PlanSeguimientoMokoService _service = PlanSeguimientoMokoService();

  bool _isLoading = true;
  List<Map<String, dynamic>> _fases = [];
  List<Map<String, dynamic>> _ejecuciones = [];
  int _faseActualIndex = 0;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _isLoading = true);

    try {
      // Intentar cargar desde el servidor
      final fases = await _service.getFases();
      
      // Inicializar el plan para el foco si no existe
      await _service.inicializarPlan(widget.focoId);
      
      // Obtener el estado actual
      final estado = await _service.getEstadoPlan(widget.focoId);
      
      setState(() {
        _fases = fases;
        _ejecuciones = List<Map<String, dynamic>>.from(estado['ejecuciones'] ?? []);
        _isLoading = false;
        
        // Encontrar la primera fase no completada
        for (int i = 0; i < _ejecuciones.length; i++) {
          if (_ejecuciones[i]['completado'] != true) {
            _faseActualIndex = i;
            break;
          }
        }
      });
    } catch (e) {
      print('❌ Error al cargar plan: $e');
      // Cargar datos de fallback
      final fases = await _service.getFases();
      setState(() {
        _fases = fases;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A365D),
        elevation: 0,
        title: Row(
          children: [
            const Text(
              'HOJA DE RUTA ESTRATÉGICA',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.notifications_outlined, color: Colors.white),
              onPressed: () {},
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF1A365D),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 20),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        // Header con información del foco
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: const Color(0xFF1A365D),
          child: Text(
            'Foco #${widget.numeroFoco}',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ),
        // Lista de fases
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _fases.length,
            itemBuilder: (context, index) {
              final fase = _fases[index];
              final ejecucion = index < _ejecuciones.length ? _ejecuciones[index] : null;
              final completado = ejecucion?['completado'] ?? false;
              final esActual = index == _faseActualIndex && !completado;
              
              return _buildFaseCard(
                index: index + 1,
                fase: fase,
                ejecucion: ejecucion,
                completado: completado,
                esActual: esActual,
                habilitado: index <= _faseActualIndex || completado,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFaseCard({
    required int index,
    required Map<String, dynamic> fase,
    Map<String, dynamic>? ejecucion,
    required bool completado,
    required bool esActual,
    required bool habilitado,
  }) {
    final nombre = fase['nombre'] ?? 'FASE $index';
    final detalle = fase['detalle'] ?? 'Gestión estratégica y planificación';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Número de fase
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: completado
                  ? Colors.green
                  : esActual
                      ? const Color(0xFF1A365D)
                      : Colors.grey[400],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: completado
                  ? const Icon(Icons.check, color: Colors.white, size: 18)
                  : Text(
                      '$index',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          // Contenido de la fase
          Expanded(
            child: InkWell(
              onTap: habilitado ? () => _mostrarDetalleFase(fase, ejecucion) : null,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: esActual
                      ? Border.all(color: const Color(0xFF1A365D), width: 2)
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'FASE ${index.toString().padLeft(2, '0')}: ${_formatNombreFase(nombre)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: habilitado ? Colors.black87 : Colors.grey,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: habilitado ? Colors.grey : Colors.grey[300],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      detalle,
                      style: TextStyle(
                        fontSize: 12,
                        color: habilitado ? Colors.grey[600] : Colors.grey[400],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (esActual) ...[
                      const SizedBox(height: 8),
                      Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A365D),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatNombreFase(String nombre) {
    // Convertir a formato de título
    final palabrasMayusculas = ['SAR'];
    return nombre.split(' ').map((palabra) {
      if (palabrasMayusculas.contains(palabra.toUpperCase())) {
        return palabra.toUpperCase();
      }
      return palabra.isNotEmpty
          ? '${palabra[0].toUpperCase()}${palabra.substring(1).toLowerCase()}'
          : '';
    }).join(' ');
  }

  void _mostrarDetalleFase(Map<String, dynamic> fase, Map<String, dynamic>? ejecucion) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DetalleEjecucionModal(
        fase: fase,
        ejecucion: ejecucion,
        focoId: widget.focoId,
        service: _service,
        onFinalizarRevision: () {
          Navigator.pop(context);
          _cargarDatos();
        },
      ),
    );
  }
}

class _DetalleEjecucionModal extends StatefulWidget {
  final Map<String, dynamic> fase;
  final Map<String, dynamic>? ejecucion;
  final int focoId;
  final PlanSeguimientoMokoService service;
  final VoidCallback onFinalizarRevision;

  const _DetalleEjecucionModal({
    required this.fase,
    this.ejecucion,
    required this.focoId,
    required this.service,
    required this.onFinalizarRevision,
  });

  @override
  State<_DetalleEjecucionModal> createState() => _DetalleEjecucionModalState();
}

class _DetalleEjecucionModalState extends State<_DetalleEjecucionModal> {
  List<Map<String, dynamic>> _tareas = [];
  Map<int, bool> _tareasCompletadas = {};
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _cargarTareas();
  }

  Future<void> _cargarTareas() async {
    try {
      if (widget.ejecucion != null) {
        // Cargar tareas de la ejecución
        final ejecucionId = widget.ejecucion!['id'];
        final tareas = await widget.service.getTareasEjecucion(ejecucionId);
        
        setState(() {
          _tareas = tareas;
          for (var tarea in tareas) {
            _tareasCompletadas[tarea['id']] = tarea['completado'] ?? false;
          }
          _isLoading = false;
        });
      } else {
        // Cargar tareas de la fase desde fallback
        final tareas = widget.fase['tareas'] ?? [];
        setState(() {
          _tareas = List<Map<String, dynamic>>.from(tareas);
          for (var tarea in _tareas) {
            _tareasCompletadas[tarea['id']] = false;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error al cargar tareas: $e');
      // Usar tareas del fallback
      final tareas = widget.fase['tareas'] ?? [];
      setState(() {
        _tareas = List<Map<String, dynamic>>.from(tareas);
        for (var tarea in _tareas) {
          _tareasCompletadas[tarea['id']] = false;
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _guardarYFinalizar() async {
    setState(() => _isSaving = true);

    try {
      if (widget.ejecucion != null) {
        final ejecucionId = widget.ejecucion!['id'];
        final tareasCompletadas = _tareasCompletadas.entries
            .where((e) => e.value)
            .map((e) => e.key)
            .toList();

        await widget.service.actualizarTareas(ejecucionId, tareasCompletadas);
        await widget.service.finalizarRevision(ejecucionId);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Revisión guardada exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }

      widget.onFinalizarRevision();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final nombre = widget.fase['nombre'] ?? 'Fase';
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
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
                const SizedBox(height: 8),
                Text(
                  nombre,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Tareas
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildTareasList(),
          ),
          // Botón finalizar
          SafeArea(
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
          ),
        ],
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
          final nombre = tarea['itemTarea']?['nombre'] ?? tarea['nombre'] ?? '';
          final dosis = tarea['itemTarea']?['dosis'] ?? tarea['dosis'] ?? '';
          final completado = _tareasCompletadas[tareaId] ?? false;

          return CheckboxListTile(
            value: completado,
            onChanged: (value) {
              setState(() {
                _tareasCompletadas[tareaId] = value ?? false;
              });
            },
            title: Text(
              nombre,
              style: TextStyle(
                fontSize: 14,
                decoration: completado ? TextDecoration.lineThrough : null,
                color: completado ? Colors.grey : Colors.black87,
              ),
            ),
            subtitle: dosis.isNotEmpty
                ? Text(
                    'Dosis: $dosis',
                    style: const TextStyle(fontSize: 12),
                  )
                : null,
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            activeColor: const Color(0xFF1A365D),
          );
        }).toList(),
      ],
    );
  }
}
