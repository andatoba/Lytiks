import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/plan_seguimiento_moko_service.dart';
import 'fase_1_screen.dart';
import 'fase_2_screen.dart';
import 'fase_3_screen.dart';
import 'fase_4_screen.dart';
import 'fase_detalle_screen.dart';

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
  bool _isSaving = false;
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
        _fases = fases.map((fase) {
          final cleaned = Map<String, dynamic>.from(fase);
          cleaned['nombre'] = _limpiarTexto(fase['nombre']?.toString() ?? '');
          cleaned['detalle'] =
              _limpiarTexto(fase['detalle']?.toString() ?? '');
          return cleaned;
        }).toList();
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
        _fases = fases.map((fase) {
          final cleaned = Map<String, dynamic>.from(fase);
          cleaned['nombre'] = _limpiarTexto(fase['nombre']?.toString() ?? '');
          cleaned['detalle'] =
              _limpiarTexto(fase['detalle']?.toString() ?? '');
          return cleaned;
        }).toList();
        _isLoading = false;
      });
    }
  }

  Future<void> _guardarYVolver() async {
    if (_isSaving) return;
    
    setState(() => _isSaving = true);
    
    try {
      // Sincronizar todos los cambios pendientes
      await _service.inicializarPlan(widget.focoId);
      final estado = await _service.getEstadoPlan(widget.focoId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Plan guardado correctamente'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        
        // Esperar un momento para que el usuario vea el mensaje
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Volver a la pantalla anterior
        if (mounted) {
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⚠️ Error al guardar: $e'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFFC62828),
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
                color: const Color(0xFFC62828),
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
      floatingActionButton: _isLoading ? null : FloatingActionButton.extended(
        onPressed: _isSaving ? null : _guardarYVolver,
        backgroundColor: const Color(0xFFC62828),
        icon: _isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.save, color: Colors.white),
        label: Text(
          _isSaving ? 'Guardando...' : 'Guardar',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        // Header con información del foco
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: const Color(0xFFC62828),
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
                      ? const Color(0xFFC62828)
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
              onTap: habilitado
                  ? () => _mostrarDetalleFase(fase, ejecucion, index)
                  : null,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: esActual
                      ? Border.all(color: const Color(0xFFC62828), width: 2)
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
                          color: const Color(0xFFC62828),
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
    final limpio = _limpiarTexto(nombre);
    // Convertir a formato de título
    final palabrasMayusculas = ['SAR'];
    return limpio.split(' ').map((palabra) {
      if (palabrasMayusculas.contains(palabra.toUpperCase())) {
        return palabra.toUpperCase();
      }
      return palabra.isNotEmpty
          ? '${palabra[0].toUpperCase()}${palabra.substring(1).toLowerCase()}'
          : '';
    }).join(' ');
  }

  String _limpiarTexto(String texto) {
    if (texto.isEmpty) return texto;
    if (texto.contains('Ã') || texto.contains('Â')) {
      try {
        return utf8.decode(latin1.encode(texto));
      } catch (_) {}
    }
    return texto;
  }

  int _parseNumeroFase(dynamic value, int fallback) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  Future<void> _mostrarDetalleFase(
    Map<String, dynamic> fase,
    Map<String, dynamic>? ejecucion,
    int numeroFase,
  ) async {
    final faseNumero = _parseNumeroFase(fase['orden'], numeroFase);
    final screen = switch (faseNumero) {
      1 => Fase1Screen(
          fase: fase,
          ejecucion: ejecucion,
          focoId: widget.focoId,
          service: _service,
        ),
      2 => Fase2Screen(
          fase: fase,
          ejecucion: ejecucion,
          focoId: widget.focoId,
          service: _service,
        ),
      3 => Fase3Screen(
          fase: fase,
          ejecucion: ejecucion,
          focoId: widget.focoId,
          service: _service,
        ),
      4 => Fase4Screen(
          fase: fase,
          ejecucion: ejecucion,
          focoId: widget.focoId,
          service: _service,
        ),
      _ => FaseDetalleScreen(
          fase: fase,
          ejecucion: ejecucion,
          focoId: widget.focoId,
          service: _service,
        ),
    };

    final actualizado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );

    if (actualizado == true && mounted) {
      _cargarDatos();
    }
  }
}
