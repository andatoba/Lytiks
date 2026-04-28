import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/plan_seguimiento_moko_service.dart';
import 'fase_1_screen.dart';
import 'fase_2_screen.dart';
import 'fase_3_screen.dart';
import 'fase_4_screen.dart';
import 'fase_detalle_screen.dart';
import 'agrotecban_moko_contencion.dart';
import 'agrotecban_moko_preventivo.dart';

class PlanSeguimientoMokoScreen extends StatefulWidget {
  final int focoId;
  final int numeroFoco;

  const PlanSeguimientoMokoScreen({
    super.key,
    required this.focoId,
    required this.numeroFoco,
  });

  @override
  State<PlanSeguimientoMokoScreen> createState() =>
      _PlanSeguimientoMokoScreenState();
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
          cleaned['detalle'] = _limpiarTexto(fase['detalle']?.toString() ?? '');
          return cleaned;
        }).toList();
        _ejecuciones =
            List<Map<String, dynamic>>.from(estado['ejecuciones'] ?? []);
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
          cleaned['detalle'] = _limpiarTexto(fase['detalle']?.toString() ?? '');
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
      await _service.getEstadoPlan(widget.focoId);

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
              icon:
                  const Icon(Icons.notifications_outlined, color: Colors.white),
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
      floatingActionButton: _isLoading
          ? null
          : FloatingActionButton.extended(
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
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
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
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _abrirProgramaPreventivo,
                  icon: const Icon(Icons.event_note),
                  label: const Text('Programa preventivo'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0F7B3C),
                    side: const BorderSide(color: Color(0xFF0F7B3C)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _abrirProgramaContencion,
                  icon: const Icon(Icons.shield, color: Colors.white),
                  label: const Text(
                    'Programa contencion',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC62828),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Lista de fases
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _fases.length,
            itemBuilder: (context, index) {
              final fase = _fases[index];
              final ejecucion =
                  index < _ejecuciones.length ? _ejecuciones[index] : null;
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

    String fixWord(String input, RegExp pattern, String replacement) {
      return input.replaceAllMapped(pattern, (match) {
        final original = match.group(0) ?? '';
        if (original.isEmpty) return replacement;
        if (original.toUpperCase() == original) {
          return replacement.toUpperCase();
        }
        if (original.toLowerCase() == original) {
          return replacement.toLowerCase();
        }
        return '${replacement[0].toUpperCase()}${replacement.substring(1)}';
      });
    }

    var limpio = texto;

    for (var i = 0; i < 2; i++) {
      if (limpio.contains('Ã') ||
          limpio.contains('Â') ||
          limpio.contains('�')) {
        try {
          limpio = utf8.decode(latin1.encode(limpio));
          continue;
        } catch (_) {}
      }
      break;
    }

    const mojibake = {
      'Ã¡': 'á',
      'Ã©': 'é',
      'Ã­': 'í',
      'Ã³': 'ó',
      'Ãº': 'ú',
      'Ã±': 'ñ',
    };

    for (final entry in mojibake.entries) {
      limpio = limpio.replaceAll(entry.key, entry.value);
    }

    // Reemplazos directos de patrones conocidos con regex flexible
    // Detectar "Vacío" mal codificado (Vac + cualquier caracter + o)
    limpio = limpio.replaceAllMapped(
      RegExp(r'\bVac[^\s]{1,3}o\b', caseSensitive: true),
      (match) => 'Vacío',
    );
    limpio = limpio.replaceAllMapped(
      RegExp(r'\bVAC[^\s]{1,3}O\b', caseSensitive: true),
      (match) => 'VACÍO',
    );
    // Detectar "Biológico" mal codificado (Biol + caracteres + gico)
    limpio = limpio.replaceAllMapped(
      RegExp(r'\bBiol[^\s]{1,3}gico\b', caseSensitive: true),
      (match) => 'Biológico',
    );
    limpio = limpio.replaceAllMapped(
      RegExp(r'\bBIOL[^\s]{1,3}GICO\b', caseSensitive: true),
      (match) => 'BIOLÓGICO',
    );
    // Detectar "Activación" mal codificado
    limpio = limpio.replaceAllMapped(
      RegExp(r'\bActivaci[^\s]{1,3}n\b', caseSensitive: true),
      (match) => 'Activación',
    );
    limpio = limpio.replaceAllMapped(
      RegExp(r'\bACTIVACI[^\s]{1,3}N\b', caseSensitive: true),
      (match) => 'ACTIVACIÓN',
    );

    limpio = limpio.replaceAllMapped(
      RegExp(r'\bvac[ií]o\s+biolog[ií]co\b', caseSensitive: false),
      (match) {
        final original = match.group(0) ?? '';
        if (original.toUpperCase() == original) {
          return 'VACÍO BIOLÓGICO';
        }
        if (original.toLowerCase() == original) {
          return 'vacío biológico';
        }
        return 'Vacío biológico';
      },
    );

    limpio = limpio.replaceAllMapped(
      RegExp(r'\bactivaci[oó]n\s+sar\b', caseSensitive: false),
      (match) {
        final original = match.group(0) ?? '';
        if (original.toUpperCase() == original) {
          return 'ACTIVACIÓN SAR';
        }
        if (original.toLowerCase() == original) {
          return 'activación SAR';
        }
        return 'Activación SAR';
      },
    );

    limpio = fixWord(
      limpio,
      RegExp(r'\baplicacion\b', caseSensitive: false),
      'aplicación',
    );
    limpio = fixWord(
      limpio,
      RegExp(r'\baplicaion\b', caseSensitive: false),
      'aplicación',
    );
    limpio = fixWord(
      limpio,
      RegExp(r'\baplicaión\b', caseSensitive: false),
      'aplicación',
    );
    limpio = fixWord(
      limpio,
      RegExp(r'\binyeccion\b', caseSensitive: false),
      'inyección',
    );
    limpio = fixWord(
      limpio,
      RegExp(r'\bdescomposicion\b', caseSensitive: false),
      'descomposición',
    );

    return limpio;
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

  Future<void> _abrirProgramaPreventivo() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AgrotecbanMokoPreventivoScreen(
          focoId: widget.focoId,
          numeroFoco: widget.numeroFoco,
        ),
      ),
    );
  }

  Future<void> _abrirProgramaContencion() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AgrotecbanMokoContencionScreen(
          focoId: widget.focoId,
          numeroFoco: widget.numeroFoco,
        ),
      ),
    );
  }
}
