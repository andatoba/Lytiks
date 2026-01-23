import 'dart:async';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../services/sync_service.dart';
import '../services/moko_audit_service.dart';
import '../services/offline_storage_service.dart';
import '../services/client_service.dart';
import 'registro_moko_screen.dart';
import 'seguimiento_focos_screen.dart';
import 'lista_focos_screen.dart';

class MokoAuditScreen extends StatefulWidget {
  final Map<String, dynamic>? clientData;

  const MokoAuditScreen({super.key, this.clientData});

  @override
  State<MokoAuditScreen> createState() => _MokoAuditScreenState();
}

class _MokoAuditScreenState extends State<MokoAuditScreen> {
  // Servicios
  final ClientService _clientService = ClientService();

  // Cliente seleccionado
  Map<String, dynamic>? _selectedClient;
  final TextEditingController _nombreController = TextEditingController();
  final FocusNode _nombreFocusNode = FocusNode();
  List<Map<String, dynamic>> _clientSuggestions = [];
  Timer? _searchDebounce;
  String _lastQuery = '';

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _nombreController.dispose();
    _nombreFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF004B63),
        title: const Text(
          'Control de Moko',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _buildFormulario(),
    );
  }

  Widget _buildFormulario() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildInfoMoko(),
          const SizedBox(height: 20),
          _buildClientSearchSection(),
          const SizedBox(height: 40),

          // Botones principales del módulo Moko
          _buildIntuitiveButton(
            title: 'Registrar Nuevo Foco',
            subtitle: 'Reportar una nueva área infectada',
            icon: Icons.add_circle_outline,
            color: const Color(0xFFE53E3E), // Rojo para urgencia
            onPressed: () {
              if (_selectedClient == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Debe seleccionar un cliente primero'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RegistroMokoScreen(clientData: _selectedClient),
                ),
              );
            },
          ),
          const SizedBox(height: 16),

          _buildIntuitiveButton(
            title: 'Seguimiento de Focos',
            subtitle: 'Monitorear áreas ya identificadas',
            icon: Icons.visibility,
            color: const Color(0xFFED8936), // Naranja para seguimiento
            onPressed: () {
              if (_selectedClient == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Debe seleccionar un cliente primero'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SeguimientoFocosScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 16),

          _buildIntuitiveButton(
            title: 'Lista de Focos',
            subtitle: 'Ver todos los focos registrados',
            icon: Icons.format_list_bulleted,
            color: const Color(0xFF38A169), // Verde para consulta
            onPressed: () {
              if (_selectedClient == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Debe seleccionar un cliente primero'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ListaFocosScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildIntuitiveButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 32, color: color),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 20,
                  color: color.withValues(alpha: 0.7),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoMoko() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF006A7A), Color(0xFF004B63)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.biotech_outlined,
              color: Color(0xFF004B63),
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Control de Moko',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Evaluación de medidas\npreventivas y control',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                SizedBox(height: 8),
                Text(
                  'El Moko es una enfermedad bacteriana que afecta\nlas plantaciones de banano. Esta auditoría evalúa\nlas medidas de prevención y control implementadas.',
                  style: TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
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
            color: Colors.grey.withValues(alpha: 0.1),
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
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: RawAutocomplete<Map<String, dynamic>>(
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
                    });
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
                      onChanged: _onNameChanged,
                      decoration: InputDecoration(
                        labelText: 'Nombre y Apellido del Cliente',
                        hintText: 'Ingrese nombre y apellido',
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
              ),
            ],
          ),
          if (_selectedClient != null) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green[600],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Cliente Seleccionado',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Cédula: ${_selectedClient!['cedula']}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  Text(
                    '${_selectedClient!['nombre']}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  if (_selectedClient!['telefono'] != null &&
                      _selectedClient!['telefono'].toString().isNotEmpty)
                    Text(
                      'Teléfono: ${_selectedClient!['telefono']}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  if (_selectedClient!['direccion'] != null &&
                      _selectedClient!['direccion'].toString().isNotEmpty)
                    Text(
                      'Dirección: ${_selectedClient!['direccion']}',
                      style: const TextStyle(fontSize: 12),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
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
      final clients = await _clientService.searchClientsByName(query);
      if (!mounted || query != _lastQuery) {
        return;
      }
      setState(() {
        _clientSuggestions = clients;
      });
    } catch (e) {
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
    if (mounted) {
      _nombreFocusNode.requestFocus();
    }
  }
}
