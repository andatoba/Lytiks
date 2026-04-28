import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import '../services/offline_storage_service.dart';
import '../services/plan_seguimiento_moko_service.dart';

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
  final ImagePicker _picker = ImagePicker();
  final PlanSeguimientoMokoService _service = PlanSeguimientoMokoService();
  final OfflineStorageService _offlineStorage = OfflineStorageService();
  late DateTime _fechaInicioPlan;
  bool _isSaving = false;
  bool _isLoading = false;

  late final List<_PreventivoProducto> _microorganismos;
  late final List<_PreventivoProducto> _sar;
  late final _BioseguridadPreventiva _bioseguridad;

  static const List<int> _ciclosMicro = [1, 2, 3, 5, 6, 7, 8, 9, 10, 11, 12];
  static const List<int> _ciclosSar = [1, 2, 3, 5, 6];
  int _cicloSeleccionadoMicro = 1;
  int _cicloSeleccionadoSar = 1;
  String? _moduloSeleccionado = 'bioseguridad';

  @override
  void initState() {
    super.initState();
    _fechaInicioPlan = DateTime(_now.year, _now.month, 1);

    _microorganismos = [
      _PreventivoProducto(
          'SAFERBACTER', ['250 gr', '500 gr', '2 lt', '4 lt', '5 kg'], _ciclosMicro),
      _PreventivoProducto('SAFERSOIL', ['250 gr', '500 gr', '2 lt', '4 lt', '5 kg'], _ciclosMicro),
      _PreventivoProducto('SAFERMIX', ['250 gr', '500 gr', '2 lt', '4 lt', '5 kg'], _ciclosMicro),
      _PreventivoProducto('GOLDEN', ['250 gr', '500 gr', '2 lt', '4 lt', '5 kg'], _ciclosMicro),
      _PreventivoProducto('PREBIOTIK', ['250 gr', '500 gr', '2 lt', '4 lt', '5 kg'], _ciclosMicro),
    ];

    _sar = [
      _PreventivoProducto('ARMUROX', ['0.5 lt', '0.75 lt', '1 lt'], _ciclosSar),
      _PreventivoProducto('AMINOALEXIN', ['0.5 lt', '0.75 lt', '1 lt'], _ciclosSar),
      _PreventivoProducto('EQUILIBRIUM', ['0.5 lt', '0.75 lt', '1 lt'], _ciclosSar),
      _PreventivoProducto(
          'TERRASORB T24', ['0.5 lt', '0.75 lt', '1 lt'], _ciclosSar),
    ];
    _bioseguridad = _BioseguridadPreventiva();

    _cargarConfiguracionesExistentes();
  }

  @override
  void dispose() {
    for (final producto in [..._microorganismos, ..._sar]) {
      producto.dispose();
    }
    _bioseguridad.dispose();
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
                _buildSelectorModulos(),
                const SizedBox(height: 16),
                _buildModuloActivo(),
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
      try {
        final auditoriaResponse = await _service.getUltimaAuditoriaPreventivo(
          focoId,
        );
        final auditoria = auditoriaResponse['auditoria'];
        if (auditoria is Map<String, dynamic>) {
          _aplicarPreventivoCompleto(auditoria);
        } else if (auditoria is Map) {
          _aplicarPreventivoCompleto(Map<String, dynamic>.from(auditoria));
        }
      } catch (_) {}

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

  void _aplicarPreventivoCompleto(Map<String, dynamic> auditoria) {
    final payloadRaw =
        auditoria['payloadJson'] ?? auditoria['payload_json'] ?? auditoria['payload'];
    if (payloadRaw == null) {
      return;
    }

    Map<String, dynamic>? payload;
    if (payloadRaw is String && payloadRaw.isNotEmpty) {
      try {
        final decoded = jsonDecode(payloadRaw);
        if (decoded is Map<String, dynamic>) {
          payload = decoded;
        } else if (decoded is Map) {
          payload = Map<String, dynamic>.from(decoded);
        }
      } catch (_) {}
    } else if (payloadRaw is Map<String, dynamic>) {
      payload = payloadRaw;
    } else if (payloadRaw is Map) {
      payload = Map<String, dynamic>.from(payloadRaw);
    }

    if (payload == null) {
      return;
    }

    final fechaInicioRaw = payload['fechaInicioPlan']?.toString();
    if (fechaInicioRaw != null && fechaInicioRaw.isNotEmpty) {
      final fechaInicio = DateTime.tryParse(fechaInicioRaw);
      if (fechaInicio != null) {
        _fechaInicioPlan = DateTime(fechaInicio.year, fechaInicio.month, 1);
      }
    }

    _cicloSeleccionadoMicro =
        (payload['cicloSeleccionadoMicro'] as num?)?.toInt() ??
            _cicloSeleccionadoMicro;
    _cicloSeleccionadoSar =
        (payload['cicloSeleccionadoSar'] as num?)?.toInt() ??
            _cicloSeleccionadoSar;

    _restoreProductos(payload['microorganismos'], _microorganismos);
    _restoreProductos(payload['sar'], _sar);
    _bioseguridad.restore(payload['bioseguridad']);

    if (mounted) {
      setState(() {});
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
            _aplicarObservacionesGuardadas(producto, ciclo, observaciones);
          }
        }
      }
    }

    _autoseleccionarCiclosPendientes();

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
    String? syncError;

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
            'observaciones': _buildObservaciones(producto, ciclo),
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
        } catch (e) {
          syncError = 'No se pudo sincronizar configuraciones: $e';
        }

        try {
          await _service.guardarPreventivoCompleto(
            _buildPreventivoPayload(focoId),
          );
        } catch (e) {
          syncError = syncError == null
              ? 'No se pudo guardar preventivo completo: $e'
              : '$syncError | No se pudo guardar preventivo completo: $e';
        }
      }

      if (!mounted) {
        return;
      }

      setState(_autoseleccionarCiclosPendientes);

      final mensaje = focoId > 0
          ? 'Guardado: $totalGuardadas configuraciones, $totalServidor sincronizadas en servidor.'
          : 'Guardado local completado. Seleccione un foco para sincronizar al servidor.';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(syncError == null ? mensaje : '$mensaje\n$syncError'),
          backgroundColor: syncError == null ? Colors.green : Colors.orange,
        ),
      );

      if (continuar) {
        Navigator.pop(context);
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
    final dynamic focoId = widget.clientData?['focoId'];
    if (focoId is int) {
      return focoId;
    }
    if (focoId is String) {
      return int.tryParse(focoId);
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

  Widget _buildProductoCicloDropdown(_PreventivoProducto producto, int ciclo) {
    final checked = producto.cumplimiento[ciclo] ?? false;
    final fotoPath = producto.fotoPath;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: producto.dosisPorCiclo[ciclo],
                  decoration: InputDecoration(
                    labelText: '${producto.nombre} - Ciclo $ciclo',
                    border: const OutlineInputBorder(),
                    helperText:
                        checked ? 'Ciclo completado' : 'Ciclo pendiente',
                  ),
                  items: producto.dosisOpciones
                      .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                      .toList(),
                  onChanged: (v) =>
                      setState(() => producto.dosisPorCiclo[ciclo] = v),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  setState(() {
                    final nextValue = !(producto.cumplimiento[ciclo] ?? false);
                    producto.cumplimiento[ciclo] = nextValue;
                    producto.fechas[ciclo] = nextValue ? DateTime.now() : null;
                    _autoseleccionarCiclosPendientes();
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  decoration: BoxDecoration(
                    color: checked
                        ? const Color(0xFFDCF6E5)
                        : const Color(0xFFF4F4F4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: checked
                          ? const Color(0xFF0F7B3C)
                          : Colors.grey.shade400,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        checked
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: checked
                            ? const Color(0xFF0F7B3C)
                            : Colors.grey.shade600,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        checked ? 'Hecho' : 'Pendiente',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: checked
                              ? const Color(0xFF0F7B3C)
                              : Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _capturarFotoProducto(producto),
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: Text(
                    fotoPath == null || fotoPath.isEmpty
                        ? 'Tomar foto'
                        : 'Cambiar foto',
                  ),
                ),
              ),
              if (fotoPath != null && fotoPath.isNotEmpty) ...[
                const SizedBox(width: 8),
                const Icon(Icons.check_circle, color: Color(0xFF0F7B3C)),
              ],
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: producto.observacionController,
            minLines: 2,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Observacion ${producto.nombre}',
              hintText: 'Describa la aplicacion realizada para este producto.',
              border: const OutlineInputBorder(),
              suffixIcon: fotoPath != null && fotoPath.isNotEmpty
                  ? const Icon(Icons.photo, color: Color(0xFF0F7B3C))
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBioseguridadSection() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        title: const Text(
          'BIOSEGURIDAD',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        subtitle: const Text(
          'Registre concentración de amonio, infraestructura, desinfección de herramientas y monitoreos.',
          style: TextStyle(fontSize: 12),
        ),
        children: [
          TextField(
            controller: _bioseguridad.concentracionAmonio,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Concentracion de amonio',
              hintText: 'Ejemplo: 750',
              helperText: 'Concentracion recomendada: 750',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          _buildBioseguridadCampo(
            titulo: 'Infraestructura',
            estadoController: _bioseguridad.infraestructuraEstado,
            observacionController: _bioseguridad.infraestructuraObservacion,
          ),
          const SizedBox(height: 12),
          _buildBioseguridadCampo(
            titulo: 'Desinfeccion de herramientas',
            estadoController: _bioseguridad.desinfeccionEstado,
            observacionController: _bioseguridad.desinfeccionObservacion,
          ),
          const SizedBox(height: 12),
          _buildBioseguridadCampo(
            titulo: 'Monitoreos',
            estadoController: _bioseguridad.monitoreosEstado,
            observacionController: _bioseguridad.monitoreosObservacion,
          ),
        ],
      ),
    );
  }

  Widget _buildSelectorModulos() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Que desea registrar',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Abra solo el modulo que vaya a diligenciar. Bioseguridad es opcional.',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 12),
            _buildModuloTile(
              id: 'bioseguridad',
              titulo: 'Bioseguridad',
              subtitulo:
                  'Infraestructura, amonio, desinfeccion de herramientas y monitoreos.',
              color: const Color(0xFF1565C0),
            ),
            const SizedBox(height: 10),
            _buildModuloTile(
              id: 'microorganismos',
              titulo: 'Aplicacion Microorganismos',
              subtitulo: _textoEstadoModulo(
                productos: _microorganismos,
                ciclos: _ciclosMicro,
                etiqueta: 'ciclo',
              ),
              color: const Color(0xFF2E7D32),
            ),
            const SizedBox(height: 10),
            _buildModuloTile(
              id: 'sar',
              titulo: 'Aplicacion SAR',
              subtitulo: _textoEstadoModulo(
                productos: _sar,
                ciclos: _ciclosSar,
                etiqueta: 'ciclo',
              ),
              color: const Color(0xFFEF6C00),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModuloTile({
    required String id,
    required String titulo,
    required String subtitulo,
    required Color color,
  }) {
    final seleccionado = _moduloSeleccionado == id;
    return InkWell(
      onTap: () {
        setState(() {
          _moduloSeleccionado = id;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: seleccionado ? color.withOpacity(0.10) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: seleccionado ? color : const Color(0xFFDADADA),
            width: seleccionado ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withOpacity(0.14),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                id == 'bioseguridad'
                    ? Icons.verified_user_outlined
                    : id == 'microorganismos'
                        ? Icons.spa_outlined
                        : Icons.science_outlined,
                color: color,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitulo,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
            Icon(
              seleccionado
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              color: color,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModuloActivo() {
    switch (_moduloSeleccionado) {
      case 'microorganismos':
        return _buildProductosSection(
          titulo: 'MICROORGANISMOS',
          subtitulo:
              'Seleccione el ciclo y registre los productos aplicados.',
          resumenTitulo: 'Microorganismos',
          productos: _microorganismos,
          ciclos: _ciclosMicro,
          cicloSeleccionado: _cicloSeleccionadoMicro,
          onCicloChanged: (v) =>
              setState(() => _cicloSeleccionadoMicro = v ?? 1),
        );
      case 'sar':
        return _buildProductosSection(
          titulo: 'SAR',
          subtitulo:
              'Seleccione el ciclo y registre las dosis para todos los productos SAR.',
          resumenTitulo: 'SAR',
          productos: _sar,
          ciclos: _ciclosSar,
          cicloSeleccionado: _cicloSeleccionadoSar,
          onCicloChanged: (v) =>
              setState(() => _cicloSeleccionadoSar = v ?? 1),
        );
      case 'bioseguridad':
      default:
        return _buildBioseguridadSection();
    }
  }

  Widget _buildProductosSection({
    required String titulo,
    required String subtitulo,
    required String resumenTitulo,
    required List<_PreventivoProducto> productos,
    required List<int> ciclos,
    required int cicloSeleccionado,
    required ValueChanged<int?> onCicloChanged,
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
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 10),
            _buildResumenGrupo(
              titulo: resumenTitulo,
              productos: productos,
              ciclos: ciclos,
              cicloActual: cicloSeleccionado,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: cicloSeleccionado,
              decoration: const InputDecoration(
                labelText: 'Ciclo',
                border: OutlineInputBorder(),
              ),
              items: ciclos
                  .map(
                    (ciclo) =>
                        DropdownMenuItem(value: ciclo, child: Text('Ciclo $ciclo')),
                  )
                  .toList(),
              onChanged: onCicloChanged,
            ),
            const SizedBox(height: 16),
            ...productos
                .map(
                  (producto) =>
                      _buildProductoCicloDropdown(producto, cicloSeleccionado),
                )
                .toList(),
          ],
        ),
      ),
    );
  }

  String _textoEstadoModulo({
    required List<_PreventivoProducto> productos,
    required List<int> ciclos,
    required String etiqueta,
  }) {
    final siguientePendiente = _nextPendingCycleForGroup(productos, ciclos);
    if (siguientePendiente == null) {
      return 'Todos los ciclos registrados.';
    }
    return 'Siguiente $etiqueta a registrar: $siguientePendiente.';
  }

  Widget _buildBioseguridadCampo({
    required String titulo,
    required TextEditingController estadoController,
    required TextEditingController observacionController,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: estadoController.text.isNotEmpty ? estadoController.text : null,
            decoration: const InputDecoration(
              labelText: 'Evaluacion',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'Excelente', child: Text('Excelente')),
              DropdownMenuItem(value: 'Bueno', child: Text('Bueno')),
              DropdownMenuItem(value: 'Regular', child: Text('Regular')),
              DropdownMenuItem(value: 'NT', child: Text('NT')),
            ],
            onChanged: (value) {
              setState(() {
                estadoController.text = value ?? '';
              });
            },
          ),
          const SizedBox(height: 8),
          TextField(
            controller: observacionController,
            minLines: 2,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Observacion $titulo',
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumenGrupo({
    required String titulo,
    required List<_PreventivoProducto> productos,
    required List<int> ciclos,
    required int cicloActual,
  }) {
    final siguientePendiente = _nextPendingCycleForGroup(productos, ciclos);
    final ciclosCompletados = ciclos
        .where(
          (ciclo) => productos.every(
            (producto) => producto.cumplimiento[ciclo] == true,
          ),
        )
        .length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF4FAF5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFD6E8D7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            siguientePendiente == null
                ? '$titulo completo'
                : 'Va por ciclo ${siguientePendiente == cicloActual ? cicloActual : siguientePendiente}',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F7B3C),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Ciclos completados: $ciclosCompletados de ${ciclos.length}',
            style: TextStyle(color: Colors.grey[700], fontSize: 12),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ciclos.map((ciclo) {
              final completo = productos.every(
                (producto) => producto.cumplimiento[ciclo] == true,
              );
              final esActual = ciclo == cicloActual && !completo;
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: completo
                      ? const Color(0xFFDCF6E5)
                      : esActual
                          ? const Color(0xFFFFF4E5)
                          : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: completo
                        ? const Color(0xFF0F7B3C)
                        : esActual
                            ? const Color(0xFFFFC107)
                            : const Color(0xFFD6D6D6),
                  ),
                ),
                child: Text(
                  completo
                      ? 'Ciclo $ciclo listo'
                      : esActual
                          ? 'Ciclo $ciclo actual'
                          : 'Ciclo $ciclo pendiente',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: completo
                        ? const Color(0xFF0F7B3C)
                        : esActual
                            ? const Color(0xFF8A5A00)
                            : Colors.grey[700],
                  ),
                ),
              );
            }).toList(),
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
    final cicloDosis = proximoPendiente ?? producto.ciclos.first;
    final fotoPath = producto.fotoPath;

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
                value: producto.dosisPorCiclo[cicloDosis],
                items: producto.dosisOpciones
                    .map((d) => DropdownMenuItem<String>(
                          value: d,
                          child: Text(d),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    producto.dosisPorCiclo[cicloDosis] = value;
                  });
                },
                isExpanded: true,
                underline: Container(),
                style: const TextStyle(fontSize: 12, color: Colors.black),
              ),
            ),
            Text(' | Proximo ciclo: ${proximoPendiente ?? 'Completado'}',
                style: const TextStyle(fontSize: 12)),
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
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _capturarFotoProducto(producto),
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: Text(
                    fotoPath == null || fotoPath.isEmpty
                        ? 'Tomar foto'
                        : 'Cambiar foto',
                  ),
                ),
              ),
              if (fotoPath != null && fotoPath.isNotEmpty) ...[
                const SizedBox(width: 8),
                const Icon(Icons.check_circle, color: Color(0xFF0F7B3C)),
              ],
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: producto.observacionController,
            minLines: 2,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Observacion ${producto.nombre}',
              hintText: 'Escriba que aplicaron y cualquier novedad.',
              border: const OutlineInputBorder(),
              suffixIcon: fotoPath != null && fotoPath.isNotEmpty
                  ? const Icon(Icons.photo, color: Color(0xFF0F7B3C))
                  : null,
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

  void _autoseleccionarCiclosPendientes() {
    final siguienteMicro =
        _nextPendingCycleForGroup(_microorganismos, _ciclosMicro);
    final siguienteSar = _nextPendingCycleForGroup(_sar, _ciclosSar);

    if (siguienteMicro != null) {
      _cicloSeleccionadoMicro = siguienteMicro;
    }
    if (siguienteSar != null) {
      _cicloSeleccionadoSar = siguienteSar;
    }
  }

  int? _nextPendingCycleForGroup(
    List<_PreventivoProducto> productos,
    List<int> ciclos,
  ) {
    for (final ciclo in ciclos) {
      final cicloCompleto = productos.every(
        (producto) => producto.cumplimiento[ciclo] == true,
      );
      if (!cicloCompleto) {
        return ciclo;
      }
    }
    return null;
  }

  Future<void> _capturarFotoProducto(_PreventivoProducto producto) async {
    final foto = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    if (foto == null || !mounted) {
      return;
    }

    setState(() {
      producto.fotoPath = foto.path;
    });
  }

  String _buildObservaciones(_PreventivoProducto producto, int ciclo) {
    return jsonEncode({
      'dosis': producto.dosisPorCiclo[ciclo],
      'observacion': producto.observacionController.text.trim(),
      'fotoPath': producto.fotoPath,
    });
  }

  void _aplicarObservacionesGuardadas(
    _PreventivoProducto producto,
    int ciclo,
    String observaciones,
  ) {
    if (observaciones.isEmpty) {
      return;
    }

    try {
      final decoded = jsonDecode(observaciones);
      if (decoded is Map<String, dynamic>) {
        final dosis = decoded['dosis']?.toString();
        final observacion =
            (decoded['observacion'] ?? decoded['detalle'] ?? '').toString();
        final fotoPath = decoded['fotoPath']?.toString() ?? '';

        if (dosis != null && dosis.isNotEmpty) {
          producto.dosisPorCiclo[ciclo] = dosis;
        }
        if (observacion.isNotEmpty) {
          producto.observacionController.text = observacion;
        }
        if (fotoPath.isNotEmpty) {
          producto.fotoPath = fotoPath;
        }
        return;
      }
    } catch (_) {}

    producto.observacionController.text = observaciones;
  }

  Map<String, dynamic> _buildPreventivoPayload(int focoId) {
    return {
      'focoId': focoId,
      'numeroFoco': widget.numeroFoco,
      'fechaInicioPlan': _fechaInicioPlan.toIso8601String(),
      'cicloSeleccionadoMicro': _cicloSeleccionadoMicro,
      'cicloSeleccionadoSar': _cicloSeleccionadoSar,
      'bioseguridad': _bioseguridad.toJson(),
      'microorganismos': _microorganismos.map(_serializeProducto).toList(),
      'sar': _sar.map(_serializeProducto).toList(),
    };
  }

  void _restoreProductos(
    dynamic source,
    List<_PreventivoProducto> target,
  ) {
    if (source is! List) {
      return;
    }

    for (final productoRaw in source) {
      if (productoRaw is! Map) {
        continue;
      }
      final productoData = Map<String, dynamic>.from(productoRaw);
      final nombre = productoData['nombre']?.toString().trim().toUpperCase();
      if (nombre == null || nombre.isEmpty) {
        continue;
      }

      _PreventivoProducto? producto;
      for (final item in target) {
        if (item.nombre == nombre) {
          producto = item;
          break;
        }
      }
      if (producto == null) {
        continue;
      }

      final dosisPorCiclo = productoData['dosisPorCiclo'];
      if (dosisPorCiclo is Map) {
        for (final entry in dosisPorCiclo.entries) {
          final ciclo = int.tryParse(entry.key.toString());
          final dosis = entry.value?.toString();
          if (ciclo != null && dosis != null && dosis.isNotEmpty) {
            producto.dosisPorCiclo[ciclo] = dosis;
          }
        }
      }

      final cumplimiento = productoData['cumplimiento'];
      if (cumplimiento is Map) {
        for (final entry in cumplimiento.entries) {
          final ciclo = int.tryParse(entry.key.toString());
          if (ciclo == null) {
            continue;
          }
          final value = entry.value;
          producto.cumplimiento[ciclo] = value == true || value == 1;
        }
      }

      final fechas = productoData['fechas'];
      if (fechas is Map) {
        for (final entry in fechas.entries) {
          final ciclo = int.tryParse(entry.key.toString());
          final fecha = DateTime.tryParse(entry.value?.toString() ?? '');
          if (ciclo != null) {
            producto.fechas[ciclo] = fecha;
          }
        }
      }

      producto.observacionController.text =
          productoData['observacion']?.toString() ?? '';
      final fotoPath = productoData['fotoPath']?.toString();
      if (fotoPath != null && fotoPath.isNotEmpty) {
        producto.fotoPath = fotoPath;
      }
    }
  }

  Map<String, dynamic> _serializeProducto(_PreventivoProducto producto) {
    return {
      'nombre': producto.nombre,
      'ciclos': producto.ciclos,
      'dosisPorCiclo': producto.dosisPorCiclo,
      'cumplimiento': producto.cumplimiento,
      'fechas': producto.fechas.map(
        (key, value) => MapEntry(key.toString(), value?.toIso8601String()),
      ),
      'observacion': producto.observacionController.text.trim(),
      'fotoPath': producto.fotoPath,
    };
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
  final List<String> dosisOpciones;
  final List<int> ciclos;
  final Map<int, bool> cumplimiento = {};
  final Map<int, DateTime?> fechas = {};
  final Map<int, String?> dosisPorCiclo = {};
  final TextEditingController observacionController = TextEditingController();
  String? fotoPath;

  _PreventivoProducto(
    this.nombre,
    this.dosisOpciones,
    this.ciclos, {
    String? dosisInicial,
  }) {
    final dosisDefault =
        dosisInicial ?? (dosisOpciones.isNotEmpty ? dosisOpciones[0] : null);
    for (final ciclo in ciclos) {
      cumplimiento[ciclo] = false;
      fechas[ciclo] = null;
      dosisPorCiclo[ciclo] = dosisDefault;
    }
  }

  void dispose() {
    observacionController.dispose();
  }
}

class _BioseguridadPreventiva {
  final TextEditingController concentracionAmonio = TextEditingController();
  final TextEditingController infraestructuraEstado = TextEditingController();
  final TextEditingController infraestructuraObservacion =
      TextEditingController();
  final TextEditingController desinfeccionEstado = TextEditingController();
  final TextEditingController desinfeccionObservacion =
      TextEditingController();
  final TextEditingController monitoreosEstado = TextEditingController();
  final TextEditingController monitoreosObservacion = TextEditingController();

  Map<String, dynamic> toJson() {
    return {
      'concentracionAmonio': concentracionAmonio.text.trim(),
      'infraestructura': {
        'evaluacion': infraestructuraEstado.text.trim(),
        'observacion': infraestructuraObservacion.text.trim(),
      },
      'desinfeccionHerramientas': {
        'evaluacion': desinfeccionEstado.text.trim(),
        'observacion': desinfeccionObservacion.text.trim(),
      },
      'monitoreos': {
        'evaluacion': monitoreosEstado.text.trim(),
        'observacion': monitoreosObservacion.text.trim(),
      },
    };
  }

  void restore(dynamic source) {
    if (source is! Map) {
      return;
    }

    final data = Map<String, dynamic>.from(source);
    concentracionAmonio.text = data['concentracionAmonio']?.toString() ?? '';

    final infraestructura = _asMap(data['infraestructura']);
    infraestructuraEstado.text = infraestructura['evaluacion']?.toString() ?? '';
    infraestructuraObservacion.text =
        infraestructura['observacion']?.toString() ?? '';

    final desinfeccion = _asMap(data['desinfeccionHerramientas']);
    desinfeccionEstado.text = desinfeccion['evaluacion']?.toString() ?? '';
    desinfeccionObservacion.text =
        desinfeccion['observacion']?.toString() ?? '';

    final monitoreos = _asMap(data['monitoreos']);
    monitoreosEstado.text = monitoreos['evaluacion']?.toString() ?? '';
    monitoreosObservacion.text = monitoreos['observacion']?.toString() ?? '';
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return <String, dynamic>{};
  }

  void dispose() {
    concentracionAmonio.dispose();
    infraestructuraEstado.dispose();
    infraestructuraObservacion.dispose();
    desinfeccionEstado.dispose();
    desinfeccionObservacion.dispose();
    monitoreosEstado.dispose();
    monitoreosObservacion.dispose();
  }
}
