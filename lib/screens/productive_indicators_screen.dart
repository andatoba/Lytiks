import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/client_service.dart';

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
  final TextEditingController _clienteController = TextEditingController();
  final TextEditingController _loteController = TextEditingController();
  final FocusNode _clienteFocusNode = FocusNode();

  Timer? _searchDebounce;
  String _lastQuery = '';
  List<Map<String, dynamic>> _clientSuggestions = [];
  Map<String, dynamic>? _selectedClient;

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
          _loteController.text = draft['lote']?.toString() ?? '';
        });
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
    } catch (_) {}
  }

  Future<void> _saveDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final draft = {
        'clienteBusqueda': _clienteController.text.trim(),
        'lote': _loteController.text.trim(),
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
      });
      _clientService.saveSelectedClient(client);
      _clienteController.text = _formatClientName(client);
      _clienteFocusNode.unfocus();
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
          TextField(
            controller: _loteController,
            decoration: const InputDecoration(
              labelText: 'Lote',
              hintText: 'Ingrese el lote',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.map_outlined),
            ),
            onChanged: (_) => _saveDraft(),
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
              });
              _clientService.saveSelectedClient(client);
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
