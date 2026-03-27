  int _cicloSeleccionadoMicro = 1;
import 'package:flutter/material.dart';

import '../services/offline_storage_service.dart';
import '../services/plan_seguimiento_moko_service.dart';
import 'agrotecban_moko_contencion.dart';

class AgrotecbanMokoPreventivoScreen extends StatefulWidget {
  final int? focoId;
  final int? numeroFoco;
  final Map<String, dynamic>? clientData;

  const AgrotecbanMokoPreventivoScreen({
    super.key,
    this.focoId,
    this.numeroFoco,
    this.clientData,
  });

  @override
  State<AgrotecbanMokoPreventivoScreen> createState() =>
      _AgrotecbanMokoPreventivoScreenState();
}

class _AgrotecbanMokoPreventivoScreenState
    extends State<AgrotecbanMokoPreventivoScreen> {
  final DateTime _now = DateTime.now();
  final PlanSeguimientoMokoService _service = PlanSeguimientoMokoService();
  final OfflineStorageService _offlineStorage = OfflineStorageService();
  late DateTime _fechaInicioPlan;
  bool _isSaving = false;
  bool _isLoading = false;

  late final List<_PreventivoProducto> _microorganismos;
  late final List<_PreventivoProducto> _sar;

  static const List<int> _ciclosMicro = [1, 2, 3, 5, 6, 7, 8, 9, 10, 11, 12];
  static const List<int> _ciclosSar = [1, 2, 3, 5, 6];

  @override
  void initState() {
    super.initState();
    _fechaInicioPlan = DateTime(_now.year, _now.month, 1);

    _microorganismos = [
      _PreventivoProducto('SAFERBACTER', ['250-500 gr', '2-4 lt', '5 kilos'], _ciclosMicro),
      _PreventivoProducto('SAFERSOIL', ['250-500 gr', '2-4 lt', '5 kilos'], _ciclosMicro),
      _PreventivoProducto('SAFERMIX', ['250-500 gr', '2-4 lt', '5 kilos'], _ciclosMicro),
      _PreventivoProducto('GOLDEN', ['250-500 gr', '2-4 lt', '5 kilos'], _ciclosMicro),
      _PreventivoProducto('PREBIOTIK', ['250-500 gr', '2-4 lt', '5 kilos'], _ciclosMicro),
    ];

    _sar = [
      _PreventivoProducto('ARMUROX', ['1 lt', '0,5-0,75 lt', '0,5-1 lt'], _ciclosSar),
      _PreventivoProducto('AMINOALEXIN', ['1 lt', '0,5-0,75 lt', '0,5-1 lt'], _ciclosSar),
      _PreventivoProducto('EQUILIBRIUM', ['1 lt', '0,5-0,75 lt', '0,5-1 lt'], _ciclosSar),
      _PreventivoProducto('TERRASORB T24', ['1 lt', '0,5-0,75 lt', '0,5-1 lt'], _ciclosSar),
    ];

    _cargarConfiguracionesExistentes();
  }

  @override
  void dispose() {
    for (final producto in [..._microorganismos, ..._sar]) {
      producto.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final alertas = _buildAlertas();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.numeroFoco != null
              ? 'Programa Preventivo - Foco ${widget.numeroFoco}'
              : 'Programa Preventivo',
        ),
        backgroundColor: const Color(0xFF0F7B3C),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          if (_isLoading) const LinearProgressIndicator(minHeight: 3),
          _buildHeader(alertas.length),
          if (alertas.isNotEmpty)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4E5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFFC107)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Alertas de cumplimiento',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  for (final alerta in alertas)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text('• $alerta'),
                    ),
                ],
              ),
            ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('PROGRAMA PREVENTIVO (INOCULACION MICROORGANISMOS)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        const Text('Seleccione el ciclo y registre los productos aplicados.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<int>(
                          value: _cicloSeleccionadoMicro,
                          decoration: const InputDecoration(labelText: 'Ciclo', border: OutlineInputBorder()),
                          items: List.generate(12, (i) => DropdownMenuItem(value: i+1, child: Text('Ciclo ${i+1}'))),
                          onChanged: (v) => setState(() => _cicloSeleccionadoMicro = v ?? 1),
                        ),
                        const SizedBox(height: 16),
                        ..._microorganismos.map((producto) => _buildProductoCicloDropdown(producto)),
                      ],
                    ),
                  ),
                ),
                  Widget _buildProductoCicloDropdown(_PreventivoProducto producto) {
                    return Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: producto.dosisSeleccionada,
                            decoration: InputDecoration(labelText: producto.nombre, border: const OutlineInputBorder()),
                            items: producto.dosisOpciones.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                            onChanged: (v) => setState(() => producto.dosisSeleccionada = v),
                          ),
                        ),
                      ],
                    );
                  }
                const SizedBox(height: 16),
                _buildProgramaSection(
                  titulo: 'PROGRAMA PREVENTIVO (SAR)',
                  subtitulo:
                      'Checklist bimestral: mismas validaciones de cumplimiento, con alerta por atraso.',
                  productos: _sar,
                  frecuenciaMeses: 2,
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isSaving ? null : () => _guardarPreventivo(continuar: true),
        icon: _isSaving
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.save, color: Colors.white),
        label: Text(
          _isSaving ? 'Guardando...' : 'Guardar y continuar',
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF0F7B3C),
      ),
    );
  }

  Future<void> _cargarConfiguracionesExistentes() async {
    final focoId = _resolveFocoId();
    if (focoId == null || focoId <= 0) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final configuraciones = await _service.getConfiguracionesByFoco(focoId);
      _aplicarConfiguraciones(configuraciones);
    } catch (_) {
      final locales = await _offlineStorage.obtenerConfiguracionesAplicacion(
        focoId: focoId,
      );
      _aplicarConfiguraciones(locales);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _aplicarConfiguraciones(List<Map<String, dynamic>> configuraciones) {
    for (final config in configuraciones) {
      final faseId = int.tryParse(
          (config['faseId'] ?? config['fase_id'] ?? '').toString());
      final tareaId = int.tryParse(
          (config['tareaId'] ?? config['tarea_id'] ?? '').toString());
      final completado =
          config['completado'] == true || config['completado'] == 1;
      if (faseId == null || tareaId == null) {
        continue;
      }

      final targetList =
          faseId == 4 ? _microorganismos : (faseId == 3 ? _sar : null);
      if (targetList == null) {
        continue;
      }

      for (int pIndex = 0; pIndex < targetList.length; pIndex++) {
        final producto = targetList[pIndex];
        for (final ciclo in producto.ciclos) {
          final generatedId = _buildTareaId(
            faseId: faseId,
            productIndex: pIndex,
            ciclo: ciclo,
          );
          if (generatedId == tareaId) {
            producto.cumplimiento[ciclo] = completado;
            final observaciones = (config['observaciones'] ?? '').toString();
            if (observaciones.isNotEmpty) {
              producto.detalleController.text = observaciones;
            }
          }
        }
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _guardarPreventivo({required bool continuar}) async {
    if (_isSaving) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final focoId = _resolveFocoId() ?? 0;
    final nowIso = DateTime.now().toIso8601String();
    int totalGuardadas = 0;
    int totalServidor = 0;
    final configuraciones = <Map<String, dynamic>>[];

    Future<void> guardarGrupo({
      required List<_PreventivoProducto> productos,
      required int faseId,
      required int frecuenciaDias,
    }) async {
      for (int pIndex = 0; pIndex < productos.length; pIndex++) {
        final producto = productos[pIndex];
        for (final ciclo in producto.ciclos) {
          final completado = producto.cumplimiento[ciclo] ?? false;
          final programada = _addMonths(
            _fechaInicioPlan,
            (ciclo - 1) * (frecuenciaDias ~/ 30),
          );

          final configuracion = {
            'focoId': focoId,
            'faseId': faseId,
            'tareaId': _buildTareaId(
              faseId: faseId,
              productIndex: pIndex,
              ciclo: ciclo,
            ),
            'nombreTarea': '${producto.nombre} - ciclo $ciclo',
            'fechaProgramada': programada.toIso8601String(),
            'frecuencia': frecuenciaDias,
            'repeticiones': 1,
            'recordatorio': '08:00',
            'completado': completado,
            'fechaCreacion': nowIso,
            'observaciones': producto.detalleController.text.trim(),
          };

          configuraciones.add(configuracion);
          await _offlineStorage.guardarConfiguracionAplicacion(configuracion);
          totalGuardadas++;
        }
      }
    }

    try {
      await guardarGrupo(
          productos: _microorganismos, faseId: 4, frecuenciaDias: 30);
      await guardarGrupo(productos: _sar, faseId: 3, frecuenciaDias: 60);

      if (focoId > 0 && configuraciones.isNotEmpty) {
        try {
          final response = await _service
              .guardarConfiguracionesAplicacionBulk(configuraciones);
          totalServidor = (response['total'] as num?)?.toInt() ?? 0;
        } catch (_) {}
      }

      if (!mounted) {
        return;
      }

      final mensaje = focoId > 0
          ? 'Guardado: $totalGuardadas configuraciones, $totalServidor sincronizadas en servidor.'
          : 'Guardado local completado. Seleccione un foco para sincronizar al servidor.';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensaje), backgroundColor: Colors.green),
      );

      if (continuar) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AgrotecbanMokoContencionScreen(
              focoId: _resolveFocoId(),
              numeroFoco: widget.numeroFoco,
              clientData: widget.clientData,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar preventivo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  int? _resolveFocoId() {
    if (widget.focoId != null) {
      return widget.focoId;
    }
    final dynamic clientId = widget.clientData?['id'];
    if (clientId is int) {
      return clientId;
    }
    if (clientId is String) {
      return int.tryParse(clientId);
    }
    return null;
  }

  int _buildTareaId({
    required int faseId,
    required int productIndex,
    required int ciclo,
  }) {
    return (faseId * 100000) + ((productIndex + 1) * 100) + ciclo;
  }

  Widget _buildHeader(int totalAlertas) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: const Color(0xFF0F7B3C),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.focoId != null
                ? 'Foco: ${widget.focoId} | Alertas: $totalAlertas'
                : 'Alertas: $totalAlertas',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text(
                'Inicio del plan:',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: _selectStartDate,
                icon: const Icon(Icons.date_range, color: Colors.white),
                label: Text(
                  _formatDate(_fechaInicioPlan),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgramaSection({
    required String titulo,
    required String subtitulo,
    required List<_PreventivoProducto> productos,
    required int frecuenciaMeses,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              subtitulo,
              style: TextStyle(color: Colors.grey[700], fontSize: 12),
            ),
            const SizedBox(height: 10),
            for (final producto in productos)
              _buildProductoCard(
                producto: producto,
                frecuenciaMeses: frecuenciaMeses,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductoCard({
    required _PreventivoProducto producto,
    required int frecuenciaMeses,
  }) {
    final proximoPendiente = _nextPendingCycle(producto);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFDDE5DE)),
      ),
      child: ExpansionTile(
        title: Text(
          producto.nombre,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
        subtitle: Row(
          children: [
            const Text('Dosis: ', style: TextStyle(fontSize: 12)),
            Expanded(
              child: DropdownButton<String>(
                value: producto.dosisSeleccionada,
                items: producto.dosisOpciones
                    .map((d) => DropdownMenuItem<String>(
                          value: d,
                          child: Text(d),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    producto.dosisSeleccionada = value;
                  });
                },
                isExpanded: true,
                underline: Container(),
                style: const TextStyle(fontSize: 12, color: Colors.black),
              ),
            ),
            Text(' | Proximo ciclo: ${proximoPendiente ?? 'Completado'}', style: const TextStyle(fontSize: 12)),
          ],
        ),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        children: [
          SizedBox(
            height: 62,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: producto.ciclos.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final ciclo = producto.ciclos[index];
                final checked = producto.cumplimiento[ciclo] ?? false;
                final vencido = _isCicloVencido(
                  ciclo: ciclo,
                  checked: checked,
                  frecuenciaMeses: frecuenciaMeses,
                );

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      final nextValue =
                          !(producto.cumplimiento[ciclo] ?? false);
                      producto.cumplimiento[ciclo] = nextValue;
                      producto.fechas[ciclo] =
                          nextValue ? DateTime.now() : null;
                    });
                  },
                  child: Container(
                    width: 72,
                    padding:
                        const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                    decoration: BoxDecoration(
                      color: checked
                          ? const Color(0xFFDCF6E5)
                          : vencido
                              ? const Color(0xFFFFEBEE)
                              : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: checked
                            ? const Color(0xFF0F7B3C)
                            : vencido
                                ? const Color(0xFFC62828)
                                : Colors.grey.shade400,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Ciclo $ciclo',
                          style: TextStyle(
                            fontSize: 11,
                            color: checked
                                ? const Color(0xFF0F7B3C)
                                : Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Icon(
                          checked
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          size: 18,
                          color: checked
                              ? const Color(0xFF0F7B3C)
                              : vencido
                                  ? const Color(0xFFC62828)
                                  : Colors.grey,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: producto.detalleController,
            minLines: 2,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Detalle del tecnico',
              hintText:
                  'Escriba que aplicaron en cada ciclo y observaciones para el proximo ciclo.',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectStartDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _fechaInicioPlan,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: const Locale('es', 'ES'),
    );

    if (selected != null) {
      setState(() {
        _fechaInicioPlan = DateTime(selected.year, selected.month, 1);
      });
    }
  }

  List<String> _buildAlertas() {
    final alertas = <String>[];

    for (final producto in _microorganismos) {
      for (final ciclo in producto.ciclos) {
        final checked = producto.cumplimiento[ciclo] ?? false;
        if (_isCicloVencido(
            ciclo: ciclo, checked: checked, frecuenciaMeses: 1)) {
          alertas.add(
            'Microorganismos: ${producto.nombre} atrasado en ciclo $ciclo (mensual).',
          );
        }
      }
    }

    for (final producto in _sar) {
      for (final ciclo in producto.ciclos) {
        final checked = producto.cumplimiento[ciclo] ?? false;
        if (_isCicloVencido(
            ciclo: ciclo, checked: checked, frecuenciaMeses: 2)) {
          alertas.add(
            'SAR: ${producto.nombre} atrasado en ciclo $ciclo (cada 2 meses).',
          );
        }
      }
    }

    return alertas;
  }

  int? _nextPendingCycle(_PreventivoProducto producto) {
    for (final ciclo in producto.ciclos) {
      if (producto.cumplimiento[ciclo] != true) {
        return ciclo;
      }
    }
    return null;
  }

  bool _isCicloVencido({
    required int ciclo,
    required bool checked,
    required int frecuenciaMeses,
  }) {
    if (checked) {
      return false;
    }

    final expected =
        _addMonths(_fechaInicioPlan, (ciclo - 1) * frecuenciaMeses);
    final deadline = _addMonths(expected, frecuenciaMeses);
    return _now.isAfter(deadline);
  }

  DateTime _addMonths(DateTime date, int months) {
    final monthIndex = date.month - 1 + months;
    final year = date.year + (monthIndex ~/ 12);
    final month = (monthIndex % 12) + 1;
    final day = date.day;
    final lastDay = DateTime(year, month + 1, 0).day;
    return DateTime(year, month, day <= lastDay ? day : lastDay);
  }

  String _formatDate(DateTime date) {
    final mm = date.month.toString().padLeft(2, '0');
    final dd = date.day.toString().padLeft(2, '0');
    return '${date.year}-$mm-$dd';
  }
}

class _PreventivoProducto {
  final String nombre;
  String? dosisSeleccionada;
  final List<String> dosisOpciones;
  final List<int> ciclos;
  final Map<int, bool> cumplimiento = {};
  final Map<int, DateTime?> fechas = {};
  final TextEditingController detalleController = TextEditingController();

  _PreventivoProducto(this.nombre, this.dosisOpciones, this.ciclos, {String? dosisInicial}) {
    dosisSeleccionada = dosisInicial ?? (dosisOpciones.isNotEmpty ? dosisOpciones[0] : null);
    for (final ciclo in ciclos) {
      cumplimiento[ciclo] = false;
      fechas[ciclo] = null;
    }
  }

  void dispose() {
    detalleController.dispose();
  }
}
