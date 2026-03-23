import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/registro_moko_service.dart';

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
    extends State<AgrotecbanMokoContencionScreen> {
  final ImagePicker _picker = ImagePicker();
  final RegistroMokoService _registroService = RegistroMokoService();
  final List<_ContencionFormulario> _formularios = [];
  List<Map<String, dynamic>> _productos = [];
  int _indiceActual = 0;
  bool _isLoadingProductos = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _formularios.add(_ContencionFormulario(
      focoLabel: widget.numeroFoco != null
          ? 'Foco ${widget.numeroFoco}'
          : 'Foco ${widget.focoId ?? 1}',
    ));
    _cargarProductos();
  }

  @override
  void dispose() {
    for (final form in _formularios) {
      form.dispose();
    }
    super.dispose();
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
          _buildDosisReferencia(),
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
              const Text('Aplicar:'),
              const SizedBox(width: 8),
              DropdownButton<bool?>(
                value: item.aplicar,
                hint: const Text('SI/NO'),
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
                child: TextField(
                  controller: item.extra1,
                  decoration: InputDecoration(
                    labelText: item.extra1Label,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _productos
                          .any((p) => _nombreProducto(p) == item.extra2.text)
                      ? item.extra2.text
                      : null,
                  decoration: InputDecoration(
                    labelText: item.extra2Label,
                    border: const OutlineInputBorder(),
                  ),
                  items: _productos
                      .map(
                        (p) => DropdownMenuItem<String>(
                          value: _nombreProducto(p),
                          child: Text(_nombreProducto(p)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      item.extra2.text = value ?? '';
                    });
                  },
                ),
              ),
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

  Widget _buildDosisReferencia() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Referencia de dosis',
              style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 6),
          Text('MICROORGANISMOS'),
          Text('SAFERBACTER: 250-500 gr'),
          Text('SAFERSOIL: 250-500 gr'),
          Text('SAFERMIX: 250-500 gr'),
          Text('GOLDEN: 2-4 lt'),
          Text('PREBIOTIK: 5 kilos'),
          SizedBox(height: 8),
          Text('SAR'),
          Text('ARMUROX: 1 lt'),
          Text('AMINOALEXIN: 0,5-0,75 lt'),
          Text('EQUILIBRIUM: 0,5-1 lt'),
          Text('TERRASORB T24: 1 lt'),
        ],
      ),
    );
  }

  Future<void> _agregarFoto(_ConFoto item, int maxFotos) async {
    if (item.fotos.length >= maxFotos) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Maximo $maxFotos fotos para este item.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final foto =
        await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
    if (foto == null) {
      return;
    }

    setState(() {
      item.fotos.add(foto.path);
    });
  }

  void _agregarFormulario() {
    setState(() {
      final nuevoNumero = _formularios.length + 1;
      _formularios
          .add(_ContencionFormulario(focoLabel: 'Foco extra $nuevoNumero'));
      _indiceActual = _formularios.length - 1;
    });
  }

  String _nombreProducto(Map<String, dynamic> producto) {
    return (producto['nombre'] ?? '').toString();
  }

  int? _productoIdPorNombre(String nombre) {
    for (final producto in _productos) {
      final pNombre = _nombreProducto(producto).toLowerCase().trim();
      if (pNombre == nombre.toLowerCase().trim()) {
        final dynamic idRaw = producto['idProducto'] ?? producto['id'];
        if (idRaw is int) return idRaw;
        return int.tryParse(idRaw?.toString() ?? '');
      }
    }
    return null;
  }

  int? _resolveFocoId() {
    if (widget.focoId != null) {
      return widget.focoId;
    }
    final dynamic clientId = widget.clientData?['id'];
    if (clientId is int) return clientId;
    if (clientId is String) return int.tryParse(clientId);
    return null;
  }

  Future<void> _guardarContencion() async {
    if (_isSaving) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final focoId = _resolveFocoId() ?? 0;
      final aplicaciones = <Map<String, dynamic>>[];

      for (final item in _form.fase3) {
        final parametro = item.parametro.toLowerCase();
        if (!(parametro.contains('aplicacion') || parametro == 'sar')) {
          continue;
        }

        final productoNombre = item.extra2.text.trim();
        if (productoNombre.isEmpty) {
          continue;
        }

        final productoId = _productoIdPorNombre(productoNombre);
        if (productoId == null) {
          continue;
        }

        final aplicacionData = {
          'clienteId': widget.clientData?['id'],
          'productoId': productoId,
          'productoNombre': productoNombre,
          'plan': 'Moko-Contencion',
          'dosis': item.detalle.text.trim(),
          'fechaInicio': DateTime.now().toIso8601String(),
          'frecuenciaDias': 30,
          'repeticiones': 1,
          'recordatorioHora': '08:00',
          'lote': _form.focoLabel,
        };

        aplicaciones.add(aplicacionData);
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

      final resumen = {
        'focoId': focoId,
        'numeroFoco': widget.numeroFoco ?? focoId,
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
        'focoId': focoId,
        'numeroFoco': widget.numeroFoco ?? focoId,
        'aplicaciones': aplicaciones,
        'seguimiento': resumen,
      };

      final response =
          await _registroService.guardarContencionCompleta(payload);
      final aplicacionesGuardadas =
          (response['aplicacionesGuardadas'] as num?)?.toInt() ??
              aplicaciones.length;

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Contencion guardada. Aplicaciones enviadas: $aplicacionesGuardadas',
          ),
          backgroundColor: Colors.green,
        ),
      );
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

  void dispose() {
    evaluacion.dispose();
    observacion.dispose();
  }
}

class _Fase3Item extends _ConFoto {
  final String parametro;
  final String extra1Label;
  final String extra2Label;
  final TextEditingController detalle = TextEditingController();
  final TextEditingController recomendacion = TextEditingController();
  final TextEditingController extra1 = TextEditingController();
  final TextEditingController extra2 = TextEditingController();

  _Fase3Item(this.parametro, this.extra1Label, this.extra2Label);

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
    _Fase3Item('Aplicacion Microorganismos', 'Fecha aplicacion', 'Producto'),
    _Fase3Item('SAR', 'Fecha aplicacion', 'Producto'),
    _Fase3Item('Control malezas', 'Si / No', 'Detalle de control'),
    _Fase3Item('Control de picudos', 'Si / No', 'Detalle de control'),
  ];

  final TextEditingController observacionesGenerales = TextEditingController();
  final TextEditingController recomendaciones = TextEditingController();

  _ContencionFormulario({required this.focoLabel});

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
