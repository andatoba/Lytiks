import 'dart:async' as dart_async;

import 'package:flutter/material.dart';

import '../services/client_service.dart';
import '../services/plagas_service.dart';

class _PlagaSample {
  _PlagaSample(this.numero)
      : huevoController = TextEditingController(),
        pequenaController = TextEditingController(),
        medianaController = TextEditingController(),
        grandeController = TextEditingController();

  final int numero;
  final TextEditingController huevoController;
  final TextEditingController pequenaController;
  final TextEditingController medianaController;
  final TextEditingController grandeController;

  int _toInt(TextEditingController controller) {
    return int.tryParse(controller.text.trim()) ?? 0;
  }

  int get huevo => _toInt(huevoController);
  int get pequena => _toInt(pequenaController);
  int get mediana => _toInt(medianaController);
  int get grande => _toInt(grandeController);

  int get totalIndividuos => huevo + pequena + mediana + grande;

  double get porcentajeDanio {
    final total = totalIndividuos;
    if (total <= 0) {
      return 0;
    }
    return (grande / total) * 100;
  }

  void dispose() {
    huevoController.dispose();
    pequenaController.dispose();
    medianaController.dispose();
    grandeController.dispose();
  }
}

class PlagasScreen extends StatefulWidget {
  final Map<String, dynamic>? clientData;

  const PlagasScreen({super.key, this.clientData});

  @override
  State<PlagasScreen> createState() => _PlagasScreenState();
}

class _PlagasScreenState extends State<PlagasScreen> {
  final ClientService _clientService = ClientService();
  final PlagasService _plagasService = PlagasService();

  final TextEditingController _nombreController = TextEditingController();
  final FocusNode _nombreFocusNode = FocusNode();
  final TextEditingController _fechaController = TextEditingController();
  final TextEditingController _loteController = TextEditingController();
  final TextEditingController _plagaController = TextEditingController(
    text: 'CERAMIDIA',
  );

  List<Map<String, dynamic>> _clientSuggestions = [];
  dart_async.Timer? _searchDebounce;
  String _lastQuery = '';
  Map<String, dynamic>? _selectedClient;
  bool _isClienteMode = false;
  bool _isSaving = false;

  final List<_PlagaSample> _samples = List<_PlagaSample>.generate(
    5,
    (index) => _PlagaSample(index + 1),
  );

  @override
  void initState() {
    super.initState();
    _initializeDefaultDate();

    for (final sample in _samples) {
      sample.huevoController.addListener(_onSamplesChanged);
      sample.pequenaController.addListener(_onSamplesChanged);
      sample.medianaController.addListener(_onSamplesChanged);
      sample.grandeController.addListener(_onSamplesChanged);
    }

    if (widget.clientData != null) {
      _selectedClient = widget.clientData;
      _nombreController.text = _formatClientName(widget.clientData!);
      _loteController.text = _formatFincaName(widget.clientData!);
      _clientService.saveSelectedClient(widget.clientData!);
      _isClienteMode = widget.clientData!['isCliente'] == true;
    } else {
      _loadStoredClient();
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _nombreController.dispose();
    _nombreFocusNode.dispose();
    _fechaController.dispose();
    _loteController.dispose();
    _plagaController.dispose();
    for (final sample in _samples) {
      sample.dispose();
    }
    super.dispose();
  }

  void _initializeDefaultDate() {
    final now = DateTime.now();
    _fechaController.text =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    DateTime initialDate = now;
    try {
      initialDate = DateTime.parse(_fechaController.text.trim());
    } catch (_) {}

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: const Locale('es', 'ES'),
    );

    if (selectedDate == null) {
      return;
    }

    setState(() {
      _fechaController.text =
          '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';
    });
  }

  Future<void> _loadStoredClient() async {
    final stored = await _clientService.getSelectedClient();
    if (!mounted || stored == null) {
      return;
    }
    setState(() {
      _selectedClient = stored;
      _nombreController.text = _formatClientName(stored);
      if (_loteController.text.trim().isEmpty) {
        _loteController.text = _formatFincaName(stored);
      }
    });
  }

  void _onSamplesChanged() {
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  String _formatClientName(Map<String, dynamic> client) {
    final nombre = client['nombre']?.toString() ?? '';
    final apellidos = client['apellidos']?.toString() ?? '';
    return '$nombre $apellidos'.trim();
  }

  String _formatFincaName(Map<String, dynamic> client) {
    return (client['fincaNombre'] ?? client['nombreFinca'] ?? '').toString();
  }

  void _onNameChanged(String value) {
    final query = value.trim();
    _searchDebounce?.cancel();
    final queryChanged = query != _lastQuery;
    _lastQuery = query;

    if (_selectedClient != null) {
      final selectedName = _formatClientName(_selectedClient!).toLowerCase();
      if (selectedName != query.toLowerCase()) {
        setState(() {
          _selectedClient = null;
        });
        _clientService.clearSelectedClient();
      }
    }

    if (query.length < 2) {
      if (_clientSuggestions.isNotEmpty) {
        setState(() {
          _clientSuggestions = [];
        });
      }
      return;
    }

    if (queryChanged && _clientSuggestions.isNotEmpty) {
      setState(() {
        _clientSuggestions = [];
      });
    }

    _searchDebounce = dart_async.Timer(
      const Duration(milliseconds: 350),
      () => _fetchClientSuggestions(query),
    );
  }

  bool _isLikelyCedula(String value) {
    if (value.isEmpty) {
      return false;
    }
    return RegExp(r'^[0-9]+$').hasMatch(value);
  }

  Future<void> _fetchClientSuggestions(String query) async {
    try {
      if (_isLikelyCedula(query)) {
        final client = await _clientService.searchClientByCedula(query);
        if (!mounted || query != _lastQuery) {
          return;
        }
        setState(() {
          _clientSuggestions = client == null ? [] : [client];
        });
        return;
      }

      final clients = await _clientService.searchClientsByName(query);
      if (!mounted || query != _lastQuery) {
        return;
      }
      setState(() {
        _clientSuggestions = clients;
      });
    } catch (_) {
      if (!mounted || query != _lastQuery) {
        return;
      }
      setState(() {
        _clientSuggestions = [];
      });
    }
  }

  Future<void> _triggerSearch() async {
    final query = _nombreController.text.trim();
    _lastQuery = query;
    if (query.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingrese al menos 2 letras para buscar'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    await _fetchClientSuggestions(query);
    if (!mounted) {
      return;
    }

    if (_clientSuggestions.length == 1) {
      final client = _clientSuggestions.first;
      setState(() {
        _selectedClient = client;
        _clientSuggestions = [];
        if (_loteController.text.trim().isEmpty) {
          _loteController.text = _formatFincaName(client);
        }
      });
      _clientService.saveSelectedClient(client);
      _nombreController.text = _formatClientName(client);
      _nombreFocusNode.unfocus();
      return;
    }

    _nombreFocusNode.requestFocus();
  }

  int get _totalHuevo =>
      _samples.fold(0, (previousValue, sample) => previousValue + sample.huevo);

  int get _totalPequena => _samples.fold(
    0,
    (previousValue, sample) => previousValue + sample.pequena,
  );

  int get _totalMediana => _samples.fold(
    0,
    (previousValue, sample) => previousValue + sample.mediana,
  );

  int get _totalGrande =>
      _samples.fold(0, (previousValue, sample) => previousValue + sample.grande);

  int get _totalIndividuos =>
      _samples.fold(0, (previousValue, sample) => previousValue + sample.totalIndividuos);

  double _avgInt(int total) => total / _samples.length;

  double get _promHuevo => _avgInt(_totalHuevo);
  double get _promPequena => _avgInt(_totalPequena);
  double get _promMediana => _avgInt(_totalMediana);
  double get _promGrande => _avgInt(_totalGrande);
  double get _promTotal => _avgInt(_totalIndividuos);

  double _ratio(int value, int total) {
    if (total <= 0) {
      return 0;
    }
    return (value / total) * 100;
  }

  double get _pctHuevo => _ratio(_totalHuevo, _totalIndividuos);
  double get _pctPequena => _ratio(_totalPequena, _totalIndividuos);
  double get _pctMediana => _ratio(_totalMediana, _totalIndividuos);
  double get _pctGrande => _ratio(_totalGrande, _totalIndividuos);

  double get _pctDanioResumen => _ratio(_totalGrande, _totalIndividuos);

  double get _promDanio {
    final total = _samples.fold<double>(
      0,
      (previousValue, sample) => previousValue + sample.porcentajeDanio,
    );
    return total / _samples.length;
  }

  String _fmt(double value, {int decimals = 1}) {
    return value.toStringAsFixed(decimals).replaceAll('.', ',');
  }

  Future<void> _guardarResumen() async {
    if (_selectedClient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seleccione un cliente antes de guardar.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final lote = _loteController.text.trim();
    final plaga = _plagaController.text.trim();
    if (lote.isEmpty || plaga.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lote y plaga son obligatorios.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final payload = {
        'clientId': _selectedClient!['id'],
        'cedulaCliente': _selectedClient!['cedula'],
        'fecha': _fechaController.text.trim(),
        'lote': lote,
        'plaga': plaga,
        'totalHuevo': _totalHuevo,
        'totalPequena': _totalPequena,
        'totalMediana': _totalMediana,
        'totalGrande': _totalGrande,
        'totalIndividuos': _totalIndividuos,
        'porcentajeDanio': double.parse(_pctDanioResumen.toStringAsFixed(2)),
        'promedioHuevo': double.parse(_promHuevo.toStringAsFixed(2)),
        'promedioPequena': double.parse(_promPequena.toStringAsFixed(2)),
        'promedioMediana': double.parse(_promMediana.toStringAsFixed(2)),
        'promedioGrande': double.parse(_promGrande.toStringAsFixed(2)),
        'promedioTotal': double.parse(_promTotal.toStringAsFixed(2)),
        'promedioDanio': double.parse(_promDanio.toStringAsFixed(2)),
        'porcentajeHuevo': double.parse(_pctHuevo.toStringAsFixed(2)),
        'porcentajePequena': double.parse(_pctPequena.toStringAsFixed(2)),
        'porcentajeMediana': double.parse(_pctMediana.toStringAsFixed(2)),
        'porcentajeGrande': double.parse(_pctGrande.toStringAsFixed(2)),
        'numeroMuestras': _samples.length,
      };

      final result = await _plagasService.guardarResumen(payload);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']?.toString() ?? 'Resumen de plagas guardado'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar resumen: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF004B63),
        foregroundColor: Colors.white,
        title: const Text('Control de Plagas'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(),
            const SizedBox(height: 20),
            _buildClientSearchSection(),
            const SizedBox(height: 20),
            if (_selectedClient == null)
              _buildSelectClientWarning()
            else ...[
              _buildHeaderSection(),
              const SizedBox(height: 20),
              _buildSamplingSection(),
              const SizedBox(height: 20),
              _buildSummarySection(),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _guardarResumen,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: Text(_isSaving ? 'Guardando...' : 'Guardar Resumen'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5D4037),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5D4037), Color(0xFF8D6E63)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          Icon(Icons.bug_report, color: Colors.white, size: 34),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Evaluación de Plagas en Banano\nLevantamiento manual por muestras',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectClientWarning() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        border: Border.all(color: Colors.amber.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.amber.shade700),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Seleccione un cliente para continuar con el levantamiento de plagas.',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClientSearchSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF004B63)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person_search,
                color: const Color(0xFF004B63),
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'Buscar Cliente',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF004B63),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          RawAutocomplete<Map<String, dynamic>>(
            textEditingController: _nombreController,
            focusNode: _nombreFocusNode,
            displayStringForOption: _formatClientName,
            optionsBuilder: (TextEditingValue value) {
              final query = value.text.trim();
              if (query.length < 2 || query != _lastQuery) {
                return const Iterable<Map<String, dynamic>>.empty();
              }
              return _clientSuggestions;
            },
            onSelected: (client) {
              if (!mounted) {
                return;
              }
              setState(() {
                _selectedClient = client;
                _clientSuggestions = [];
                if (_loteController.text.trim().isEmpty) {
                  _loteController.text = _formatFincaName(client);
                }
              });
              _clientService.saveSelectedClient(client);
            },
            fieldViewBuilder: (
              BuildContext context,
              TextEditingController controller,
              FocusNode focusNode,
              VoidCallback onFieldSubmitted,
            ) {
              return TextField(
                controller: controller,
                focusNode: focusNode,
                keyboardType: TextInputType.text,
                onChanged: _isClienteMode ? null : _onNameChanged,
                readOnly: _isClienteMode,
                enabled: !_isClienteMode,
                decoration: InputDecoration(
                  labelText: 'Nombre, Apellido o Cédula',
                  hintText: _isClienteMode
                      ? 'Cliente autenticado'
                      : 'Ingrese nombre, apellido o cédula',
                  prefixIcon: Icon(
                    Icons.person,
                    color: _isClienteMode ? Colors.grey : null,
                  ),
                  border: const OutlineInputBorder(),
                  filled: _isClienteMode,
                  fillColor:
                      _isClienteMode ? Colors.grey.withOpacity(0.1) : null,
                  suffixIcon: _isClienteMode
                      ? const Icon(Icons.lock, color: Colors.grey)
                      : IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: _triggerSearch,
                        ),
                ),
              );
            },
            optionsViewBuilder: (
              BuildContext context,
              AutocompleteOnSelected<Map<String, dynamic>> onSelected,
              Iterable<Map<String, dynamic>> options,
            ) {
              final optionList = options.toList();
              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  elevation: 4.0,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 240),
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: optionList.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final client = optionList[index];
                        final nombre = _formatClientName(client);
                        final cedula = client['cedula']?.toString() ?? '';
                        final finca = _formatFincaName(client);
                        final subtitleParts = <String>[];
                        if (cedula.isNotEmpty) {
                          subtitleParts.add('Cédula: $cedula');
                        }
                        if (finca.isNotEmpty) {
                          subtitleParts.add('Finca: $finca');
                        }
                        return ListTile(
                          title: Text(nombre.isEmpty ? 'Cliente sin nombre' : nombre),
                          subtitle: subtitleParts.isEmpty
                              ? null
                              : Text(subtitleParts.join(' | ')),
                          onTap: () => onSelected(client),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
          if (_selectedClient != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green.shade600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cliente: ${_selectedClient!['nombre'] ?? ''} ${_selectedClient!['apellidos'] ?? ''}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        if (_selectedClient!['cedula'] != null &&
                            _selectedClient!['cedula'].toString().isNotEmpty)
                          Text(
                            'Cédula: ${_selectedClient!['cedula']}',
                            style: const TextStyle(fontSize: 12),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Encabezado',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF004B63),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _fechaController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Fecha',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_month),
                  ),
                  onTap: _selectDate,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _loteController,
                  decoration: const InputDecoration(
                    labelText: 'Lote',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.agriculture),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _plagaController,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
              labelText: 'Plaga',
              hintText: 'Ej: CERAMIDIA',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.bug_report_outlined),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSamplingSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Levantamiento por Muestra',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF004B63),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Ingrese manualmente Huevo, Pequeña, Mediana y Grande. Total individuos y % daño se calculan automáticamente.',
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 12),
          ..._samples.map(_buildSampleCard),
        ],
      ),
    );
  }

  Widget _buildSampleCard(_PlagaSample sample) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      color: Colors.grey.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MUESTRA ${sample.numero}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF004B63),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _numberField(sample.huevoController, 'Huevo'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _numberField(sample.pequenaController, 'Pequeña'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _numberField(sample.medianaController, 'Mediana'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _numberField(sample.grandeController, 'Grande'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _calcChip(
                    'Total individuos',
                    sample.totalIndividuos.toString(),
                    const Color(0xFF004B63),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _calcChip(
                    '% daño',
                    '${_fmt(sample.porcentajeDanio)} %',
                    const Color(0xFF8D6E63),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _numberField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
    );
  }

  Widget _calcChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cuadro Resumen',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF004B63),
            ),
          ),
          const SizedBox(height: 10),
          _summaryMeta('Fecha', _fechaController.text),
          _summaryMeta('Lote', _loteController.text.trim().isEmpty ? '-' : _loteController.text.trim()),
          _summaryMeta(
            'Plaga',
            _plagaController.text.trim().isEmpty ? '-' : _plagaController.text.trim(),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(
                const Color(0xFF004B63).withOpacity(0.08),
              ),
              columns: const [
                DataColumn(label: Text('PLAGA')),
                DataColumn(label: Text('HUEVO')),
                DataColumn(label: Text('PEQUEÑA')),
                DataColumn(label: Text('MEDIANA')),
                DataColumn(label: Text('GRANDE')),
                DataColumn(label: Text('TOTAL')),
                DataColumn(label: Text('% DAÑO')),
              ],
              rows: [
                DataRow(
                  cells: [
                    DataCell(Text(_plagaController.text.trim().isEmpty ? '-' : _plagaController.text.trim())),
                    DataCell(Text(_totalHuevo.toString())),
                    DataCell(Text(_totalPequena.toString())),
                    DataCell(Text(_totalMediana.toString())),
                    DataCell(Text(_totalGrande.toString())),
                    DataCell(Text(_totalIndividuos.toString())),
                    DataCell(Text('${_fmt(_pctDanioResumen)} %')),
                  ],
                ),
                DataRow(
                  cells: [
                    const DataCell(Text('PROMEDIO')),
                    DataCell(Text(_fmt(_promHuevo))),
                    DataCell(Text(_fmt(_promPequena))),
                    DataCell(Text(_fmt(_promMediana))),
                    DataCell(Text(_fmt(_promGrande))),
                    DataCell(Text(_fmt(_promTotal))),
                    DataCell(Text('${_fmt(_promDanio)} %')),
                  ],
                ),
                DataRow(
                  cells: [
                    const DataCell(Text('DISTRIBUCIÓN %')),
                    DataCell(Text('${_fmt(_pctHuevo)} %')),
                    DataCell(Text('${_fmt(_pctPequena)} %')),
                    DataCell(Text('${_fmt(_pctMediana)} %')),
                    DataCell(Text('${_fmt(_pctGrande)} %')),
                    const DataCell(Text('100,0 %')),
                    DataCell(Text('${_fmt(_pctDanioResumen)} %')),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryMeta(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black87, fontSize: 13),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}
