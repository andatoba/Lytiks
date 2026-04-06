import 'dart:async';

import 'package:flutter/material.dart';

import '../services/client_service.dart';
import '../services/hacienda_service.dart';
import '../services/lote_service.dart';
import 'agrotecban_moko_contencion.dart';
import 'agrotecban_moko_preventivo.dart';

class AgrotecbanMokoMidleScreen extends StatefulWidget {
  final Map<String, dynamic>? clientData;

  const AgrotecbanMokoMidleScreen({super.key, this.clientData});

  @override
  State<AgrotecbanMokoMidleScreen> createState() =>
      _AgrotecbanMokoMidleScreenState();
}

class _AgrotecbanMokoMidleScreenState extends State<AgrotecbanMokoMidleScreen> {
  final ClientService _clientService = ClientService();
  final HaciendaService _haciendaService = HaciendaService();
  final LoteService _loteService = LoteService();

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _haciendaController = TextEditingController();
  final TextEditingController _loteController = TextEditingController();
  final FocusNode _nombreFocusNode = FocusNode();
  Timer? _searchDebounce;

  Map<String, dynamic>? _selectedClient;
  List<Map<String, dynamic>> _clientSuggestions = [];
  List<Map<String, dynamic>> _haciendas = [];
  List<Map<String, dynamic>> _lotes = [];
  String _lastQuery = '';
  bool _isClienteMode = false;
  int? _selectedHaciendaId;
  int? _selectedLoteId;

  @override
  void initState() {
    super.initState();
    _initializeClient();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _nombreController.dispose();
    _haciendaController.dispose();
    _loteController.dispose();
    _nombreFocusNode.dispose();
    super.dispose();
  }

  Future<void> _initializeClient() async {
    if (widget.clientData != null) {
      final client = Map<String, dynamic>.from(widget.clientData!);
      _isClienteMode = client['isCliente'] == true;
      _applySelectedClient(client);
      return;
    }

    final stored = await _clientService.getSelectedClient();
    if (!mounted || stored == null) {
      return;
    }
    _applySelectedClient(Map<String, dynamic>.from(stored));
  }

  void _applySelectedClient(Map<String, dynamic> client) {
    setState(() {
      _selectedClient = client;
      _clientSuggestions = [];
      _nombreController.text = _formatClientName(client);
      _haciendaController.clear();
      _loteController.clear();
      _haciendas = [];
      _lotes = [];
      _selectedHaciendaId = null;
      _selectedLoteId = null;
    });
    _clientService.saveSelectedClient(client);
    _loadHaciendasByCliente(_resolveClienteId(client));
  }

  void _onNameChanged(String value) {
    if (_isClienteMode) {
      return;
    }
    final query = value.trim();
    _lastQuery = query;

    _searchDebounce?.cancel();
    if (query.length < 2) {
      setState(() {
        _clientSuggestions = [];
      });
      return;
    }

    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      _fetchClientSuggestions(query);
    });
  }

  Future<void> _fetchClientSuggestions(String query) async {
    try {
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
      _applySelectedClient(_clientSuggestions.first);
      _nombreFocusNode.unfocus();
    } else {
      _nombreFocusNode.requestFocus();
    }
  }

  String _formatClientName(Map<String, dynamic> client) {
    final nombre = client['nombre']?.toString().trim() ?? '';
    final apellidos = client['apellidos']?.toString().trim() ?? '';
    final fullName = '$nombre $apellidos'.trim();
    if (fullName.isNotEmpty) {
      return fullName;
    }
    final nombres = client['nombres']?.toString().trim() ?? '';
    return nombres.isNotEmpty ? nombres : 'Cliente sin nombre';
  }

  String _formatFincaName(Map<String, dynamic> client) {
    return client['fincaNombre']?.toString().trim() ??
        client['finca_nombre']?.toString().trim() ??
        client['hacienda']?.toString().trim() ??
        '';
  }

  int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  int? _resolveClienteId(Map<String, dynamic> client) {
    return _toInt(client['clienteId']) ?? _toInt(client['id']);
  }

  String _formatLoteValue(Map<String, dynamic> lote) {
    final codigo = lote['codigo']?.toString().trim() ?? '';
    final nombre = lote['nombre']?.toString().trim() ?? '';
    return nombre.isNotEmpty ? nombre : codigo;
  }

  String _formatHaciendaName(Map<String, dynamic> hacienda) {
    return hacienda['nombre']?.toString().trim() ?? '';
  }

  int? _resolveInitialHaciendaId({int? preferredHaciendaId}) {
    if (preferredHaciendaId != null &&
        _haciendas.any((hacienda) => _toInt(hacienda['id']) == preferredHaciendaId)) {
      return preferredHaciendaId;
    }

    final currentHacienda = _haciendaController.text.trim().toLowerCase();
    if (currentHacienda.isNotEmpty) {
      for (final hacienda in _haciendas) {
        if (_formatHaciendaName(hacienda).toLowerCase() == currentHacienda) {
          return _toInt(hacienda['id']);
        }
      }
    }

    if (_haciendas.isNotEmpty) {
      return _toInt(_haciendas.first['id']);
    }

    return null;
  }

  int? _resolveInitialLoteId({int? preferredLoteId}) {
    if (preferredLoteId != null &&
        _lotes.any((lote) => _toInt(lote['id']) == preferredLoteId)) {
      return preferredLoteId;
    }

    final currentLote = _loteController.text.trim().toLowerCase();
    if (currentLote.isNotEmpty) {
      for (final lote in _lotes) {
        if (_formatLoteValue(lote).toLowerCase() == currentLote ||
            (lote['codigo']?.toString().trim().toLowerCase() ?? '') == currentLote) {
          return _toInt(lote['id']);
        }
      }
    }

    if (_lotes.isNotEmpty) {
      return _toInt(_lotes.first['id']);
    }

    return null;
  }

  Future<void> _loadHaciendasByCliente(
    int? clienteId, {
    int? preferredHaciendaId,
    int? preferredLoteId,
  }) async {
    if (clienteId == null) {
      return;
    }

    try {
      final haciendas = await _haciendaService.getHaciendasByCliente(clienteId);
      if (!mounted) {
        return;
      }

      _haciendas = haciendas;
      final nextHaciendaId =
          _resolveInitialHaciendaId(preferredHaciendaId: preferredHaciendaId);

      setState(() {
        _haciendas = haciendas;
        _selectedHaciendaId = nextHaciendaId;
        _haciendaController.text = nextHaciendaId == null
            ? ''
            : (haciendas
                    .firstWhere((h) => h['id'] == nextHaciendaId)['nombre']
                    ?.toString() ??
                '');
        _lotes = [];
        _selectedLoteId = null;
        _loteController.clear();
      });

      if (nextHaciendaId != null) {
        await _loadLotesByHacienda(
          nextHaciendaId,
          preferredLoteId: preferredLoteId,
        );
      }
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _haciendas = [];
        _lotes = [];
        _selectedHaciendaId = null;
        _selectedLoteId = null;
        _haciendaController.clear();
        _loteController.clear();
      });
    }
  }

  Future<void> _loadLotesByHacienda(
    int haciendaId, {
    int? preferredLoteId,
  }) async {
    try {
      final lotes = await _loteService.getLotesByHacienda(haciendaId);
      if (!mounted) {
        return;
      }

      _lotes = lotes;
      final nextLoteId =
          _resolveInitialLoteId(preferredLoteId: preferredLoteId);

      setState(() {
        _lotes = lotes;
        _selectedLoteId = nextLoteId;
        if (nextLoteId != null) {
          final lote = lotes.firstWhere((l) => l['id'] == nextLoteId);
          _loteController.text = _formatLoteValue(lote);
        } else {
          _loteController.clear();
        }
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _lotes = [];
        _selectedLoteId = null;
        _loteController.clear();
      });
    }
  }

  int? _resolveFocoIdFromClient(Map<String, dynamic> client) {
    return _toInt(client['focoId']) ??
        _toInt(client['idFoco']) ??
        _toInt(client['foco_id']);
  }

  int? _resolveNumeroFocoFromClient(Map<String, dynamic> client) {
    return _toInt(client['numeroFoco']) ??
        _toInt(client['numero_foco']) ??
        _toInt(client['focoNumero']) ??
        _toInt(client['foco_numero']);
  }

  Map<String, dynamic> _buildClientPayload() {
    final selected = _selectedClient!;
    return {
      ...selected,
      'clienteId': selected['clienteId'] ?? selected['id'],
      'haciendaId': _selectedHaciendaId,
      'hacienda': _haciendaController.text.trim(),
      'focoId': selected['focoId'] ?? _resolveFocoIdFromClient(selected),
      'numeroFoco': selected['numeroFoco'] ?? _resolveNumeroFocoFromClient(selected),
      'cliente': _formatClientName(selected),
      'lote': _loteController.text.trim(),
    };
  }

  void _openPreventivo() {
    if (_selectedClient == null || _loteController.text.trim().isEmpty) {
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AgrotecbanMokoPreventivoScreen(clientData: _buildClientPayload()),
      ),
    );
  }

  void _openContencion() {
    if (_selectedClient == null || _loteController.text.trim().isEmpty) {
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AgrotecbanMokoContencionScreen(clientData: _buildClientPayload()),
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
              const Icon(
                Icons.person_search,
                color: Color(0xFF004B63),
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
              _applySelectedClient(client);
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
                          'Cliente: ${_formatClientName(_selectedClient!)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        if ((_selectedClient!['cedula']?.toString() ?? '').isNotEmpty)
                          Text(
                            'Cédula: ${_selectedClient!['cedula']}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        if (_formatFincaName(_selectedClient!).isNotEmpty)
                          Text(
                            'Finca: ${_formatFincaName(_selectedClient!)}',
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

  Widget _buildLoteSection() {
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
              const Icon(Icons.edit_location_alt_outlined,
                  color: Color(0xFF004B63), size: 24),
              const SizedBox(width: 8),
              const Text(
                'Ingresar Lote',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF004B63),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_haciendas.isNotEmpty) ...[
            DropdownButtonFormField<int>(
              value: _selectedHaciendaId,
              decoration: const InputDecoration(
                labelText: 'Finca',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.home_work_outlined),
              ),
              items: _haciendas
                  .map(
                    (hacienda) => DropdownMenuItem<int>(
                      value: _toInt(hacienda['id']),
                      child: Text(hacienda['nombre']?.toString() ?? ''),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedHaciendaId = value;
                  _selectedLoteId = null;
                  _lotes = [];
                  _loteController.clear();
                  _haciendaController.text = value == null
                      ? ''
                      : (_haciendas
                              .firstWhere((h) => h['id'] == value)['nombre']
                              ?.toString() ??
                          '');
                });
                if (value != null) {
                  _loadLotesByHacienda(value);
                }
              },
            ),
            const SizedBox(height: 12),
          ] else ...[
            TextField(
              controller: _haciendaController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Finca',
                hintText: 'Seleccione un cliente para cargar fincas',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.home_work_outlined),
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (_lotes.isNotEmpty) ...[
            DropdownButtonFormField<int>(
              value: _selectedLoteId,
              decoration: const InputDecoration(
                labelText: 'Lote',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.text_fields),
              ),
              items: _lotes
                  .map(
                    (lote) => DropdownMenuItem<int>(
                      value: _toInt(lote['id']),
                      child: Text(
                        '${lote['codigo'] ?? ''} - ${lote['nombre'] ?? ''}',
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedLoteId = value;
                  if (value == null) {
                    _loteController.clear();
                    return;
                  }
                  final lote = _lotes.firstWhere((l) => l['id'] == value);
                  _loteController.text = _formatLoteValue(lote);
                });
              },
            ),
          ] else ...[
            TextField(
              controller: _loteController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Lote',
                hintText: 'Seleccione una finca para cargar lotes',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.text_fields),
              ),
            ),
          ],
          if (_loteController.text.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.place, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Lote: ${_loteController.text.trim()}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
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

  Widget _buildActionButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final enabled =
        _selectedClient != null && _loteController.text.trim().isNotEmpty;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: enabled ? onTap : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          disabledBackgroundColor: color.withOpacity(0.25),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF00903E),
        foregroundColor: Colors.white,
        title: const Text('Auditoria Moko'),
      ),
      backgroundColor: const Color(0xFFF7FAF2),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildClientSearchSection(),
            const SizedBox(height: 16),
            _buildLoteSection(),
            const SizedBox(height: 20),
            _buildActionButton(
              title: 'Programa Preventivo',
              subtitle: 'Abrir el plan preventivo del cliente y lote seleccionados.',
              icon: Icons.fact_check,
              color: const Color(0xFF2E7D32),
              onTap: _openPreventivo,
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              title: 'Programa de Contención',
              subtitle: 'Abrir el flujo de contención para el lote seleccionado.',
              icon: Icons.shield,
              color: const Color(0xFFC62828),
              onTap: _openContencion,
            ),
          ],
        ),
      ),
    );
  }
}
