import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/registro_moko_service.dart';
import '../services/offline_storage_service.dart';

class AgrotecbanMokoContencionScreen extends StatefulWidget {
  final int? focoId;
  final int? numeroFoco;
  final Map<String, dynamic>? clientData;

  const AgrotecbanMokoContencionScreen({
    super.key,
    this.focoId,
    this.numeroFoco,
    this.clientData,
  });

  @override
  State<AgrotecbanMokoContencionScreen> createState() =>
      _AgrotecbanMokoContencionScreenState();
}

class _AgrotecbanMokoContencionScreenState
    extends State<AgrotecbanMokoContencionScreen> with WidgetsBindingObserver {
  static const String _draftKey = 'moko_contencion_draft';
  final ImagePicker _picker = ImagePicker();
  final RegistroMokoService _registroService = RegistroMokoService();
  final OfflineStorageService _offlineStorage = OfflineStorageService();
  final List<_ContencionFormulario> _formularios = [];
  List<Map<String, dynamic>> _productos = [];
  int _indiceActual = 0;
  bool _isLoadingProductos = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _formularios.add(_ContencionFormulario(
      focoLabel: widget.numeroFoco != null
          ? 'Foco ${widget.numeroFoco}'
          : 'Foco ${widget.focoId ?? 1}',
    ));
    _restoreDraft();
    _cargarProductos();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    for (final form in _formularios) {
      form.dispose();
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _saveDraft();
    }
  }

  _ContencionFormulario get _form => _formularios[_indiceActual];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Programa Contencion Moko'),
        backgroundColor: const Color(0xFFC62828),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          if (_isLoadingProductos) const LinearProgressIndicator(minHeight: 3),
          _buildTopControls(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildBioseguridad(),
                const SizedBox(height: 12),
                _buildFase1(),
                const SizedBox(height: 12),
                _buildFase2(),
                const SizedBox(height: 12),
                _buildFase3(),
                const SizedBox(height: 12),
                _buildObservaciones(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isSaving ? null : _guardarContencion,
        icon: const Icon(Icons.save, color: Colors.white),
        label: Text(
          _isSaving ? 'Guardando...' : 'Guardar auditoria',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFC62828),
      ),
    );
  }

  Future<void> _cargarProductos() async {
    setState(() {
      _isLoadingProductos = true;
    });

    try {
      var productos = await _registroService.getProductos();
      if (productos.isEmpty) {
        try {
          await _registroService.initProductos();
          productos = await _registroService.getProductos();
        } catch (_) {}
      }

      if (mounted) {
        setState(() {
          _productos = productos;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingProductos = false;
        });
      }
    }
  }

  Widget _buildTopControls() {
    return Container(
      width: double.infinity,
      color: const Color(0xFFC62828),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Auditoria por foco (cada formulario representa 1 foco).',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (int i = 0; i < _formularios.length; i++)
                ChoiceChip(
                  selected: _indiceActual == i,
                  label: Text(_formularios[i].focoLabel),
                  selectedColor: Colors.white,
                  labelStyle: TextStyle(
                    color: _indiceActual == i
                        ? const Color(0xFFC62828)
                        : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  onSelected: (_) {
                    setState(() {
                      _indiceActual = i;
                    });
                  },
                  backgroundColor: const Color(0xFFB71C1C),
                ),
              ActionChip(
                avatar: const Icon(Icons.add, size: 18),
                label: const Text('Auditar otro foco'),
                onPressed: _agregarFormulario,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBioseguridad() {
    final items = _form.bioseguridad;

    return _sectionCard(
      titulo: 'BIOSEGURIDAD',
      subtitulo: 'Seguir formato: Aplicar + evaluacion + observacion + foto.',
      child: Column(
        children: [
          _buildItemCard(items[0],
              ayuda: 'Concentracion de amonio recomendada: 750.'),
          _buildItemCard(items[1]),
          _buildItemCard(items[2]),
          _buildItemCard(
            items[3],
            ayuda: 'Escala: Excelente (100%), Bueno (75%), Regular (25%).',
          ),
        ],
      ),
    );
  }

  Widget _buildFase1() {
    return _sectionCard(
      titulo: 'CONTENCION - FASE 1',
      subtitulo:
          'Checklist similar a auditoria de cultivos. Maximo 5 fotos por item.',
      child: Column(
        children: [
          for (final item in _form.fase1) _buildItemCard(item, maxFotos: 5),
        ],
      ),
    );
  }

  Widget _buildFase2() {
    return _sectionCard(
      titulo: 'CONTENCION - FASE 2',
      subtitulo: 'Vacios biologicos y encalado. Maximo 5 fotos por item.',
      child: Column(
        children: [
          for (final item in _form.fase2) _buildItemCard(item, maxFotos: 5),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildFase3() {
    return _sectionCard(
      titulo: 'CONTENCION - FASE 3',
      subtitulo: 'Detalle + recomendacion + foto por actividad.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final item in _form.fase3) _buildFase3Item(item),
        ],
      ),
    );
  }

  Widget _buildObservaciones() {
    return _sectionCard(
      titulo: 'CIERRE TECNICO',
      subtitulo: 'Resumen del recorrido y acciones recomendadas.',
      child: Column(
        children: [
          TextField(
            controller: _form.observacionesGenerales,
            minLines: 3,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'OBSERVACIONES GENERALES',
              hintText:
                  'Ejemplo: focos renovados, plantas del ultimo censo, novedades encontradas.',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _form.recomendaciones,
            minLines: 3,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'RECOMENDACIONES',
              hintText:
                  'Recomendaciones tecnicas para mejorar la labor segun el recorrido.',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(_CheckItem item, {int maxFotos = 1, String? ayuda}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.titulo,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          if (ayuda != null) ...[
            const SizedBox(height: 4),
            Text(ayuda,
                style: TextStyle(fontSize: 12, color: Colors.grey[700])),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              DropdownButton<bool?>(
                value: item.aplicar,
                hint: const Text('Seleccione'),
                items: const [
                  DropdownMenuItem(value: true, child: Text('SI')),
                  DropdownMenuItem(value: false, child: Text('NO')),
                ],
                onChanged: (value) => setState(() => item.aplicar = value),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => _agregarFoto(item, maxFotos),
                icon: const Icon(Icons.camera_alt),
                label: Text('Foto (${item.fotos.length}/$maxFotos)'),
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (item.titulo == 'Infraestructura' ||
              item.titulo == 'Monitoreo' ||
              item.titulo == 'Desinfeccion Herramientas')
            DropdownButtonFormField<String>(
              value:
                  item.evaluacion.text.isNotEmpty ? item.evaluacion.text : null,
              decoration: const InputDecoration(
                labelText: 'Evaluacion / detalle',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'Excelente', child: Text('Excelente')),
                DropdownMenuItem(value: 'Bueno', child: Text('Bueno')),
                DropdownMenuItem(value: 'Regular', child: Text('Regular')),
                DropdownMenuItem(value: 'NT', child: Text('NT')),
              ],
              onChanged: (value) {
                item.evaluacion.text = value ?? '';
              },
            )
          else
            TextField(
              controller: item.evaluacion,
              decoration: const InputDecoration(
                labelText: 'Evaluacion / detalle',
                border: OutlineInputBorder(),
              ),
            ),
          const SizedBox(height: 8),
          TextField(
            controller: item.observacion,
            minLines: 2,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Observacion',
              border: OutlineInputBorder(),
            ),
          ),
          if (item.fotos.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final foto in item.fotos)
                  Chip(
                    label: Text(
                      foto.split('/').last,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onDeleted: () {
                      setState(() {
                        item.fotos.remove(foto);
                      });
                    },
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFase3Item(_Fase3Item item) {
    final microorganismos = [
      'SAFERBACTER',
      'SAFERSOIL',
      'SAFERMIX',
      'GOLDEN',
      'PREBIOTIK',
    ];
    final dosisMicro = [
      '250 gr',
      '500 gr',
      '2 lt',
      '4 lt',
      '5 kg',
    ];
    final sar = [
      'ARMUROX',
      'AMINOALEXIN',
      'EQUILIBRIUM',
      'TERRASORB T24',
    ];
    final dosisSar = [
      '0.5 lt',
      '0.75 lt',
      '1 lt',
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.parametro,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (item.tipo == 'microorganismo' || item.tipo == 'sar') ...[
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: item.productoSeleccionado,
                    decoration: InputDecoration(
                      labelText: 'Producto',
                      border: const OutlineInputBorder(),
                    ),
                    items:
                        (item.tipo == 'microorganismo' ? microorganismos : sar)
                            .map((p) => DropdownMenuItem<String>(
                                  value: p,
                                  child: Text(p),
                                ))
                            .toList(),
                    onChanged: (value) {
                      setState(() {
                        item.productoSeleccionado = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: item.dosisSeleccionada,
                    decoration: InputDecoration(
                      labelText: 'Dosis',
                      border: const OutlineInputBorder(),
                    ),
                    items:
                        (item.tipo == 'microorganismo' ? dosisMicro : dosisSar)
                            .map((d) => DropdownMenuItem<String>(
                                  value: d,
                                  child: Text(d),
                                ))
                            .toList(),
                    onChanged: (value) {
                      setState(() {
                        item.dosisSeleccionada = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ] else if (item.parametro == 'Control malezas' ||
              item.parametro == 'Control de picudos') ...[
            DropdownButtonFormField<String>(
              value: item.extra1.text.isNotEmpty ? item.extra1.text : null,
              decoration: InputDecoration(
                hintText: 'Seleccione',
                labelText: item.extra1Label.isNotEmpty ? item.extra1Label : null,
                border: const OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'SI', child: Text('SI')),
                DropdownMenuItem(value: 'NO', child: Text('NO')),
              ],
              onChanged: (value) {
                setState(() {
                  item.extra1.text = value ?? '';
                });
              },
            ),
            const SizedBox(height: 8),
          ] else if (item.extra2Label == '# plantas sembradas' ||
              item.extra2Label == '# plantas reinfectada') ...[
            TextField(
              controller: item.extra2,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: item.extra2Label,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
          ],
          TextField(
            controller: item.detalle,
            decoration: const InputDecoration(
              labelText: 'Detalle',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: item.recomendacion,
            minLines: 2,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Recomendacion',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: item.extra1Label == 'Fecha de siembra'
                    ? GestureDetector(
                        onTap: () async {
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() {
                              item.extra1.text =
                                  '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                            });
                          }
                        },
                        child: AbsorbPointer(
                          child: TextField(
                            controller: item.extra1,
                            decoration: InputDecoration(
                              labelText: item.extra1Label,
                              border: const OutlineInputBorder(),
                              suffixIcon: const Icon(Icons.calendar_today),
                            ),
                          ),
                        ),
                      )
                    : TextField(
                        controller: item.extra1,
                        decoration: InputDecoration(
                          labelText: item.extra1Label,
                          border: const OutlineInputBorder(),
                        ),
                      ),
              ),
              if (item.tipo == null &&
                  item.extra2Label != '# plantas sembradas' &&
                  item.extra2Label != '# plantas reinfectada') ...[
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: item.extra2,
                    decoration: InputDecoration(
                      labelText: item.extra2Label,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ],
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => _agregarFoto(item, 1),
              icon: const Icon(Icons.photo_camera),
              label: Text(item.fotos.isEmpty ? 'Agregar foto' : 'Cambiar foto'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required String titulo,
    required String subtitulo,
    required Widget child,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo,
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(subtitulo,
                style: TextStyle(fontSize: 12, color: Colors.grey[700])),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }

  Future<void> _agregarFoto(_ConFoto item, int maxFotos) async {
    if (item.fotos.length >= maxFotos) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Maximo $maxFotos fotos para este item.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    final foto =
        await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
    if (foto == null) {
      return;
    }

    if (mounted) {
      setState(() {
        item.fotos.add(foto.path);
      });
    }
    _saveDraft();
  }

  void _agregarFormulario() {
    setState(() {
      final nuevoNumero = _formularios.length + 1;
      _formularios
          .add(_ContencionFormulario(focoLabel: 'Foco extra $nuevoNumero'));
      _indiceActual = _formularios.length - 1;
    });
    _saveDraft();
  }

  String _nombreProducto(Map<String, dynamic> producto) {
    return (producto['nombre'] ?? '').toString();
  }

  String _normalizarTexto(String value) {
    final lower = value.toLowerCase().trim();
    final sinTildes = lower
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ü', 'u')
        .replaceAll('ñ', 'n');
    return sinTildes.replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  bool _nombreProductoCompatible(String seleccionado, String catalogo) {
    final s = _normalizarTexto(seleccionado);
    final c = _normalizarTexto(catalogo);
    if (s.isEmpty || c.isEmpty) {
      return false;
    }
    return s == c || c.contains(s) || s.contains(c);
  }

  int? _productoIdPorNombre(String nombre) {
    for (final producto in _productos) {
      final pNombre = _nombreProducto(producto);
      if (_nombreProductoCompatible(nombre, pNombre)) {
        final dynamic idRaw = producto['idProducto'] ?? producto['id'];
        if (idRaw is int) return idRaw;
        return int.tryParse(idRaw?.toString() ?? '');
      }
    }
    return null;
  }

  int? _resolveClienteId() {
    final dynamic clientId =
        widget.clientData?['clienteId'] ?? widget.clientData?['id'];
    if (clientId is int) return clientId;
    if (clientId is String) return int.tryParse(clientId);
    return null;
  }

  int? _resolveFocoId() {
    if (widget.focoId != null) {
      return widget.focoId;
    }
    final dynamic focoId = widget.clientData?['focoId'];
    if (focoId is int) return focoId;
    if (focoId is String) return int.tryParse(focoId);
    return null;
  }

  Future<void> _guardarContencion() async {
    if (_isSaving) {
      return;
    }

    if (mounted) {
      setState(() {
        _isSaving = true;
      });
    }

    try {
      int? focoId = _resolveFocoId();
      int? numeroFoco = widget.numeroFoco;

      // Si no hay focoId, obtener el próximo número de foco del servidor
      if (focoId == null || focoId <= 0) {
        try {
          final nextFoco = await _registroService.getNextFocoNumber();
          numeroFoco = nextFoco;
          // focoId se dejará nulo; el backend creará el registro automáticamente
        } catch (_) {
          // Si falla la conexión, usar un timestamp como número temporal
          numeroFoco ??= DateTime.now().millisecondsSinceEpoch % 100000;
        }
      }

      final clienteId = _resolveClienteId();
      if (clienteId == null || clienteId <= 0) {
        throw Exception('No se pudo determinar el cliente asociado al foco.');
      }

      final aplicaciones = <Map<String, dynamic>>[];
      final productosSinMapeo = <String>[];

      for (final item in _form.fase3) {
        final parametro = item.parametro.toLowerCase();
        if (!(parametro.contains('aplicacion') || parametro == 'sar')) {
          continue;
        }

        final productoNombre =
            (item.productoSeleccionado ?? item.extra2.text).trim();
        if (productoNombre.isEmpty) {
          continue;
        }

        final productoId = _productoIdPorNombre(productoNombre);
        if (productoId == null) {
          productosSinMapeo.add(productoNombre);
          continue;
        }

        final dosis = (item.dosisSeleccionada ?? item.detalle.text).trim();

        final aplicacionData = {
          'clienteId': clienteId,
          'productoId': productoId,
          'productoNombre': productoNombre,
          'plan': 'Moko-Contencion',
          'dosis': dosis,
          'fechaInicio': DateTime.now().toIso8601String(),
          'frecuenciaDias': 30,
          'repeticiones': 1,
          'recordatorioHora': '08:00',
          'lote': _form.focoLabel,
        };

        aplicaciones.add(aplicacionData);
      }

      if (aplicaciones.isEmpty) {
        final detalleProductos = productosSinMapeo.isNotEmpty
            ? ' Productos no reconocidos: ${productosSinMapeo.join(', ')}'
            : '';
        throw Exception(
          'No hay aplicaciones validas para guardar. Seleccione producto y dosis en Fase 3.$detalleProductos',
        );
      }

      final plantasAfectadas = _contarSiEnLista(_form.fase1);
      final plantasInyectadas =
          _itemPorTitulo(_form.fase1, 'Plantas inyectadas')?.aplicar == true
              ? plantasAfectadas
              : 0;
      final ppm = int.tryParse(
            (_itemPorTitulo(_form.bioseguridad, 'Concentracion Amonio')
                        ?.evaluacion
                        .text ??
                    '')
                .trim(),
          ) ??
          750;

      final efectivoNumeroFoco = numeroFoco ?? focoId ?? 0;

      final resumen = {
        'focoId': focoId,
        'numeroFoco': efectivoNumeroFoco,
        'semanaInicio': _isoWeek(DateTime.now()),
        'plantasAfectadas': plantasAfectadas,
        'plantasInyectadas': plantasInyectadas,
        'controlVectores':
            _itemPorTitulo(_form.fase1, 'Control de picudos en focos')
                    ?.aplicar ==
                true,
        'cuarentenaActiva':
            _itemPorTitulo(_form.fase1, 'Cumplimiento de perimetro 10x10')
                    ?.aplicar ==
                true,
        'unicaEntradaHabilitada':
            _itemPorTitulo(_form.fase1, 'Cumplimiento de perimetro 10x10')
                    ?.aplicar ==
                true,
        'eliminacionMalezaHospedera':
            _itemPorTitulo(_form.fase1, 'Erradicacion de malezas')?.aplicar ==
                true,
        'controlPicudoAplicado':
            _itemPorTitulo(_form.fase1, 'Control de picudos en focos')
                    ?.aplicar ==
                true,
        'inspeccionPlantasVecinas': _itemPorTitulo(
              _form.fase1,
              'Revision con sacabocado a plantas involucradas',
            )?.aplicar ==
            true,
        'corteRiego': false,
        'pediluvioActivo':
            _itemPorTitulo(_form.bioseguridad, 'Concentracion Amonio')
                    ?.aplicar ==
                true,
        'ppmSolucionDesinfectante': ppm,
        'observaciones': _buildResumenObservaciones(),
      };

      final payload = {
        'focoId': focoId ?? 0,
        'clienteId': clienteId,
        'numeroFoco': efectivoNumeroFoco,
        'aplicaciones': aplicaciones,
        'seguimiento': resumen,
        'auditoria': _buildAuditoriaPayload(),
      };

      // 1. GUARDAR LOCALMENTE PRIMERO
      await _offlineStorage.guardarMokoContencion({
        'focoId': focoId ?? 0,
        'numeroFoco': efectivoNumeroFoco,
        'clienteId': clienteId,
        'aplicaciones': aplicaciones,
        'seguimiento': resumen,
        'auditoria': _buildAuditoriaPayload(),
        'timestamp': DateTime.now().toIso8601String(),
      });

      await _clearDraft();

      // 2. MOSTRAR ÉXITO LOCAL
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Guardado localmente: ${aplicaciones.length} aplicaciones registradas.',
          ),
          backgroundColor: Colors.green,
        ),
      );

      // 3. SINCRONIZAR AL SERVIDOR EN BACKGROUND (sin bloquear)
      _sincronizarContencionAlServidor(payload);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar contencion: $e'),
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

  int _contarSiEnLista(List<_CheckItem> items) {
    return items.where((item) => item.aplicar == true).length;
  }

  _CheckItem? _itemPorTitulo(List<_CheckItem> items, String titulo) {
    for (final item in items) {
      if (item.titulo.toLowerCase() == titulo.toLowerCase()) {
        return item;
      }
    }
    return null;
  }

  String _buildResumenObservaciones() {
    final partes = <String>[];
    final obs = _form.observacionesGenerales.text.trim();
    final rec = _form.recomendaciones.text.trim();
    if (obs.isNotEmpty) {
      partes.add('Observaciones: $obs');
    }
    if (rec.isNotEmpty) {
      partes.add('Recomendaciones: $rec');
    }
    return partes.join(' | ');
  }

  Map<String, dynamic> _buildAuditoriaPayload() {
    return {
      'focoLabel': _form.focoLabel,
      'bioseguridad': _form.bioseguridad.map(_serializeCheckItem).toList(),
      'fase1': _form.fase1.map(_serializeCheckItem).toList(),
      'fase2': _form.fase2.map(_serializeCheckItem).toList(),
      'fase3': _form.fase3.map(_serializeFase3Item).toList(),
      'observacionesGenerales': _form.observacionesGenerales.text.trim(),
      'recomendaciones': _form.recomendaciones.text.trim(),
    };
  }

  Map<String, dynamic> _serializeCheckItem(_CheckItem item) {
    return {
      'titulo': item.titulo,
      'aplicar': item.aplicar,
      'evaluacion': item.evaluacion.text.trim(),
      'observacion': item.observacion.text.trim(),
      'fotos': List<String>.from(item.fotos),
    };
  }

  Map<String, dynamic> _serializeFase3Item(_Fase3Item item) {
    return {
      'parametro': item.parametro,
      'extra1Label': item.extra1Label,
      'extra2Label': item.extra2Label,
      'tipo': item.tipo,
      'detalle': item.detalle.text.trim(),
      'recomendacion': item.recomendacion.text.trim(),
      'extra1': item.extra1.text.trim(),
      'extra2': item.extra2.text.trim(),
      'productoSeleccionado': item.productoSeleccionado,
      'dosisSeleccionada': item.dosisSeleccionada,
      'fotos': List<String>.from(item.fotos),
    };
  }

  int _isoWeek(DateTime date) {
    final dayOfYear = int.parse(
          DateTime(date.year, date.month, date.day)
              .difference(DateTime(date.year, 1, 1))
              .inDays
              .toString(),
        ) +
        1;
    return ((dayOfYear - date.weekday + 10) / 7).floor();
  }

  /// Sincroniza el contencion al servidor en background (sin bloquear)
  void _sincronizarContencionAlServidor(Map<String, dynamic> payload) {
    // Ejecutar en background sin await
    _registroService.guardarContencionCompleta(payload).then((response) {
      if (mounted) {
        final aplicacionesSync =
            (response['aplicacionesGuardadas'] as num?)?.toInt() ?? 0;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Sincronizado: $aplicacionesSync aplicaciones enviadas al servidor.',
            ),
            backgroundColor: Colors.blue,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }).catchError((e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'No se pudo sincronizar al servidor: $e\nLos datos están guardados localmente.',
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    });
  }

  Future<void> _saveDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final draft = {
        'indiceActual': _indiceActual,
        'formularios': _formularios.map(_serializeFormulario).toList(),
      };
      await prefs.setString(_draftKey, jsonEncode(draft));
    } catch (_) {}
  }

  Future<void> _restoreDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_draftKey);
      if (raw == null || raw.isEmpty) {
        return;
      }

      final draft = jsonDecode(raw) as Map<String, dynamic>;
      final formulariosRaw = draft['formularios'];
      if (formulariosRaw is! List || formulariosRaw.isEmpty) {
        return;
      }

      final restored = formulariosRaw
          .whereType<Map>()
          .map(
            (item) => _ContencionFormulario.fromDraft(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();

      if (restored.isEmpty || !mounted) {
        return;
      }

      for (final form in _formularios) {
        form.dispose();
      }

      setState(() {
        _formularios
          ..clear()
          ..addAll(restored);
        final restoredIndex = draft['indiceActual'];
        _indiceActual = restoredIndex is int
            ? restoredIndex.clamp(0, _formularios.length - 1)
            : 0;
      });
    } catch (_) {}
  }

  Future<void> _clearDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_draftKey);
    } catch (_) {}
  }

  Map<String, dynamic> _serializeFormulario(_ContencionFormulario form) {
    return {
      'focoLabel': form.focoLabel,
      'bioseguridad': form.bioseguridad.map(_serializeCheckItem).toList(),
      'fase1': form.fase1.map(_serializeCheckItem).toList(),
      'fase2': form.fase2.map(_serializeCheckItem).toList(),
      'fase3': form.fase3.map(_serializeFase3Item).toList(),
      'observacionesGenerales': form.observacionesGenerales.text.trim(),
      'recomendaciones': form.recomendaciones.text.trim(),
    };
  }
}

abstract class _ConFoto {
  final List<String> fotos = [];
}

class _CheckItem extends _ConFoto {
  final String titulo;
  bool? aplicar;
  final TextEditingController evaluacion = TextEditingController();
  final TextEditingController observacion = TextEditingController();

  _CheckItem(this.titulo);

  factory _CheckItem.fromDraft(Map<String, dynamic> draft) {
    final item = _CheckItem(draft['titulo']?.toString() ?? '');
    item.aplicar = draft['aplicar'] as bool?;
    item.evaluacion.text = draft['evaluacion']?.toString() ?? '';
    item.observacion.text = draft['observacion']?.toString() ?? '';
    final fotosRaw = draft['fotos'];
    if (fotosRaw is List) {
      item.fotos.addAll(fotosRaw.map((foto) => foto.toString()));
    }
    return item;
  }

  void dispose() {
    evaluacion.dispose();
    observacion.dispose();
  }
}

class _Fase3Item extends _ConFoto {
  final String parametro;
  final String extra1Label;
  final String extra2Label;
  final String? tipo; // 'microorganismo' o 'sar' o null
  final TextEditingController detalle = TextEditingController();
  final TextEditingController recomendacion = TextEditingController();
  final TextEditingController extra1 = TextEditingController();
  final TextEditingController extra2 = TextEditingController();
  String? productoSeleccionado;
  String? dosisSeleccionada;

  _Fase3Item(this.parametro, this.extra1Label, this.extra2Label, {this.tipo});

  factory _Fase3Item.fromDraft(Map<String, dynamic> draft) {
    final item = _Fase3Item(
      draft['parametro']?.toString() ?? '',
      draft['extra1Label']?.toString() ?? '',
      draft['extra2Label']?.toString() ?? '',
      tipo: draft['tipo']?.toString(),
    );
    item.detalle.text = draft['detalle']?.toString() ?? '';
    item.recomendacion.text = draft['recomendacion']?.toString() ?? '';
    item.extra1.text = draft['extra1']?.toString() ?? '';
    item.extra2.text = draft['extra2']?.toString() ?? '';
    item.productoSeleccionado = draft['productoSeleccionado']?.toString();
    item.dosisSeleccionada = draft['dosisSeleccionada']?.toString();
    final fotosRaw = draft['fotos'];
    if (fotosRaw is List) {
      item.fotos.addAll(fotosRaw.map((foto) => foto.toString()));
    }
    return item;
  }

  void dispose() {
    detalle.dispose();
    recomendacion.dispose();
    extra1.dispose();
    extra2.dispose();
  }
}

class _ContencionFormulario {
  final String focoLabel;

  final List<_CheckItem> bioseguridad = [
    _CheckItem('Concentracion Amonio'),
    _CheckItem('Infraestructura'),
    _CheckItem('Monitoreo'),
    _CheckItem('Desinfeccion Herramientas'),
  ];

  final List<_CheckItem> fase1 = [
    _CheckItem('Cumplimiento de perimetro 10x10'),
    _CheckItem('Plantas inyectadas'),
    _CheckItem('Eliminacion de rebrotes'),
    _CheckItem('Erradicacion de malezas'),
    _CheckItem('Baja de racimos'),
    _CheckItem('Colocacion de bolos'),
    _CheckItem('Revision con sacabocado a plantas involucradas'),
    _CheckItem('Control de picudos en focos'),
  ];

  final List<_CheckItem> fase2 = [
    _CheckItem('Vacio biologico 1'),
    _CheckItem('Vacio biologico 2'),
    _CheckItem('Vacio biologico 3'),
    _CheckItem('Vacio biologico 4'),
    _CheckItem('Encalado'),
  ];

  final List<_Fase3Item> fase3 = [
    _Fase3Item('Siembra', 'Fecha de siembra', '# plantas sembradas'),
    _Fase3Item('Siembra', 'Fecha de siembra', '# plantas reinfectada'),
    _Fase3Item('Aplicacion Microorganismos', 'Fecha aplicacion', 'Producto',
        tipo: 'microorganismo'),
    _Fase3Item('SAR', 'Fecha aplicacion', 'Producto', tipo: 'sar'),
    _Fase3Item(
      'Control malezas',
      '',
      '',
    ),
    _Fase3Item(
      'Control de picudos',
      '',
      '',
    ),
  ];

  final TextEditingController observacionesGenerales = TextEditingController();
  final TextEditingController recomendaciones = TextEditingController();

  _ContencionFormulario({required this.focoLabel});

  factory _ContencionFormulario.fromDraft(Map<String, dynamic> draft) {
    final form = _ContencionFormulario(
      focoLabel: draft['focoLabel']?.toString() ?? 'Foco 1',
    );
    _restoreCheckItems(form.bioseguridad, draft['bioseguridad']);
    _restoreCheckItems(form.fase1, draft['fase1']);
    _restoreCheckItems(form.fase2, draft['fase2']);
    _restoreFase3Items(form.fase3, draft['fase3']);
    form.observacionesGenerales.text =
        draft['observacionesGenerales']?.toString() ?? '';
    form.recomendaciones.text = draft['recomendaciones']?.toString() ?? '';
    return form;
  }

  void dispose() {
    for (final item in bioseguridad) {
      item.dispose();
    }
    for (final item in fase1) {
      item.dispose();
    }
    for (final item in fase2) {
      item.dispose();
    }
    for (final item in fase3) {
      item.dispose();
    }
    observacionesGenerales.dispose();
    recomendaciones.dispose();
  }
}

void _restoreCheckItems(List<_CheckItem> target, dynamic source) {
  if (source is! List) {
    return;
  }
  for (int i = 0; i < target.length && i < source.length; i++) {
    final itemRaw = source[i];
    if (itemRaw is! Map) {
      continue;
    }
    final restored = _CheckItem.fromDraft(Map<String, dynamic>.from(itemRaw));
    target[i].aplicar = restored.aplicar;
    target[i].evaluacion.text = restored.evaluacion.text;
    target[i].observacion.text = restored.observacion.text;
    target[i].fotos
      ..clear()
      ..addAll(restored.fotos);
    restored.dispose();
  }
}

void _restoreFase3Items(List<_Fase3Item> target, dynamic source) {
  if (source is! List) {
    return;
  }
  for (int i = 0; i < target.length && i < source.length; i++) {
    final itemRaw = source[i];
    if (itemRaw is! Map) {
      continue;
    }
    final restored = _Fase3Item.fromDraft(Map<String, dynamic>.from(itemRaw));
    target[i].detalle.text = restored.detalle.text;
    target[i].recomendacion.text = restored.recomendacion.text;
    target[i].extra1.text = restored.extra1.text;
    target[i].extra2.text = restored.extra2.text;
    target[i].productoSeleccionado = restored.productoSeleccionado;
    target[i].dosisSeleccionada = restored.dosisSeleccionada;
    target[i].fotos
      ..clear()
      ..addAll(restored.fotos);
    restored.dispose();
  }
}
