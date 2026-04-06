import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/client_service.dart';
import '../services/hacienda_service.dart';
import '../services/lote_service.dart';

class ProductiveIndicatorsScreen extends StatefulWidget {
  final Map<String, dynamic>? clientData;

  const ProductiveIndicatorsScreen({super.key, this.clientData});

  @override
  State<ProductiveIndicatorsScreen> createState() =>
      _ProductiveIndicatorsScreenState();
}

class _ProductiveIndicatorsScreenState extends State<ProductiveIndicatorsScreen>
    with WidgetsBindingObserver {
  static const String _draftKey = 'productive_indicators_draft';

  final ClientService _clientService = ClientService();
  final HaciendaService _haciendaService = HaciendaService();
  final LoteService _loteService = LoteService();
  final TextEditingController _clienteController = TextEditingController();
  final TextEditingController _haciendaController = TextEditingController();
  final TextEditingController _loteController = TextEditingController();
  final FocusNode _clienteFocusNode = FocusNode();

  Timer? _searchDebounce;
  String _lastQuery = '';
  List<Map<String, dynamic>> _clientSuggestions = [];
  List<Map<String, dynamic>> _haciendas = [];
  List<Map<String, dynamic>> _lotes = [];
  Map<String, dynamic>? _selectedClient;
  int? _selectedHaciendaId;
  int? _selectedLoteId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _restoreDraft();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchDebounce?.cancel();
    _clienteController.dispose();
    _haciendaController.dispose();
    _loteController.dispose();
    _clienteFocusNode.dispose();
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

  Future<void> _restoreDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_draftKey);
      if (raw != null && raw.isNotEmpty) {
        final draft = jsonDecode(raw) as Map<String, dynamic>;
        if (!mounted) {
          return;
        }
        setState(() {
          final selectedClientRaw = draft['selectedClient'];
          if (selectedClientRaw is Map) {
            _selectedClient = Map<String, dynamic>.from(selectedClientRaw);
          }
          _clienteController.text = draft['clienteBusqueda']?.toString() ?? '';
          _haciendaController.text = draft['hacienda']?.toString() ?? '';
          _loteController.text = draft['lote']?.toString() ?? '';
          _selectedHaciendaId = draft['selectedHaciendaId'] as int?;
          _selectedLoteId = draft['selectedLoteId'] as int?;
        });
        if (_selectedClient != null) {
          await _loadHaciendasByCliente(
            _resolveClienteId(_selectedClient!),
            preferredHaciendaId: _selectedHaciendaId,
            preferredLoteId: _selectedLoteId,
          );
        }
        return;
      }

      final initialClient =
          widget.clientData ?? await _clientService.getSelectedClient();
      if (!mounted || initialClient == null) {
        return;
      }

      setState(() {
        _selectedClient = Map<String, dynamic>.from(initialClient);
        _clienteController.text = _formatClientName(_selectedClient!);
      });
      await _loadHaciendasByCliente(_resolveClienteId(_selectedClient!));
    } catch (_) {}
  }

  Future<void> _saveDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final draft = {
        'clienteBusqueda': _clienteController.text.trim(),
        'hacienda': _haciendaController.text.trim(),
        'selectedHaciendaId': _selectedHaciendaId,
        'lote': _loteController.text.trim(),
        'selectedLoteId': _selectedLoteId,
        'selectedClient': _selectedClient,
      };
      await prefs.setString(_draftKey, jsonEncode(draft));
    } catch (_) {}
  }

  String _formatClientName(Map<String, dynamic> client) {
    final nombre = client['nombre']?.toString() ?? '';
    final apellidos = client['apellidos']?.toString() ?? '';
    return '$nombre $apellidos'.trim();
  }

  String _formatFincaName(Map<String, dynamic> client) {
    return (client['fincaNombre'] ?? client['nombreFinca'] ?? '').toString();
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

  bool _isLikelyCedula(String value) {
    return value.isNotEmpty && RegExp(r'^[0-9]+$').hasMatch(value);
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
          _selectedHaciendaId = null;
          _selectedLoteId = null;
          _haciendas = [];
          _lotes = [];
          _haciendaController.clear();
          _loteController.clear();
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

    _searchDebounce = Timer(
      const Duration(milliseconds: 350),
      () => _fetchClientSuggestions(query),
    );
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
    final query = _clienteController.text.trim();
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
        _selectedHaciendaId = null;
        _selectedLoteId = null;
        _haciendas = [];
        _lotes = [];
        _haciendaController.clear();
        _loteController.clear();
      });
      _clientService.saveSelectedClient(client);
      _clienteController.text = _formatClientName(client);
      _clienteFocusNode.unfocus();
      await _loadHaciendasByCliente(_resolveClienteId(client));
      _saveDraft();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Indicadores productivos'),
        backgroundColor: const Color(0xFF00903E),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildClientCard(),
          const SizedBox(height: 16),
          if (_haciendas.isNotEmpty)
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
                } else {
                  _saveDraft();
                }
              },
            )
          else
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
          const SizedBox(height: 16),
          if (_lotes.isNotEmpty)
            DropdownButtonFormField<int>(
              value: _selectedLoteId,
              decoration: const InputDecoration(
                labelText: 'Lote',
                hintText: 'Seleccione el lote',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.map_outlined),
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
                  } else {
                    final lote = _lotes.firstWhere((l) => l['id'] == value);
                    _loteController.text = _formatLoteValue(lote);
                  }
                });
                _saveDraft();
              },
            )
          else
            TextField(
              controller: _loteController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Lote',
                hintText: 'Seleccione una finca para cargar lotes',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.map_outlined),
              ),
            ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: const Row(
              children: [
                Icon(Icons.construction_outlined, color: Colors.orange),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Funcion en desarrollo.',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF7A4B00),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClientCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.person_search, color: Color(0xFF004B63)),
              SizedBox(width: 8),
              Text(
                'Seleccionar Cliente',
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
            textEditingController: _clienteController,
            focusNode: _clienteFocusNode,
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
                _selectedHaciendaId = null;
                _selectedLoteId = null;
                _haciendas = [];
                _lotes = [];
                _haciendaController.clear();
                _loteController.clear();
              });
              _clientService.saveSelectedClient(client);
              _loadHaciendasByCliente(_resolveClienteId(client));
              _saveDraft();
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
                onChanged: _onNameChanged,
                decoration: InputDecoration(
                  labelText: 'Nombre, Apellido o Cédula',
                  hintText: 'Ingrese nombre, apellido o cédula',
                  prefixIcon: const Icon(Icons.person),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
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
                  elevation: 4,
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
                          title: Text(
                            nombre.isEmpty ? 'Cliente sin nombre' : nombre,
                          ),
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
                        if ((_selectedClient!['cedula'] ?? '')
                            .toString()
                            .isNotEmpty)
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
}
