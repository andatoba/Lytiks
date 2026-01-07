import 'package:flutter/material.dart';
import '../services/clientes_service.dart';

class ClientesScreen extends StatefulWidget {
  const ClientesScreen({super.key});

  @override
  State<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  final ClientesService _service = ClientesService();
  List<Map<String, dynamic>> _clientes = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadClientes();
  }

  Future<void> _loadClientes() async {
    setState(() => _isLoading = true);
    try {
      final clientes = await _service.getAllClientes();
      setState(() {
        _clientes = clientes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar clientes: $e')),
        );
      }
    }
  }

  List<Map<String, dynamic>> get _filteredClientes {
    if (_searchQuery.isEmpty) return _clientes;
    final searchLower = _searchQuery.toLowerCase();
    return _clientes.where((cliente) {
      final nombreCompleto = '${cliente['nombre'] ?? ''} ${cliente['apellidos'] ?? ''}'.trim();
      return (cliente['cedula']?.toString().toLowerCase().contains(searchLower) ?? false) ||
          (nombreCompleto.toLowerCase().contains(searchLower)) ||
          (cliente['telefono']?.toString().toLowerCase().contains(searchLower) ?? false) ||
          (cliente['email']?.toString().toLowerCase().contains(searchLower) ?? false) ||
          (cliente['fincaNombre']?.toString().toLowerCase().contains(searchLower) ?? false);
    }).toList();
  }

  void _showClienteDialog({Map<String, dynamic>? cliente}) {
    final isEditing = cliente != null;
    final cedulaController = TextEditingController(text: cliente?['cedula']?.toString() ?? '');
    final nombreController = TextEditingController(text: cliente?['nombre']?.toString() ?? '');
    final apellidosController = TextEditingController(text: cliente?['apellidos']?.toString() ?? '');
    final telefonoController = TextEditingController(text: cliente?['telefono']?.toString() ?? '');
    final emailController = TextEditingController(text: cliente?['email']?.toString() ?? '');
    final direccionController = TextEditingController(text: cliente?['direccion']?.toString() ?? '');
    final parroquiaController = TextEditingController(text: cliente?['parroquia']?.toString() ?? '');
    final fincaNombreController = TextEditingController(text: cliente?['fincaNombre']?.toString() ?? '');
    final fincaHectareasController = TextEditingController(text: cliente?['fincaHectareas']?.toString() ?? '');
    final cultivosController = TextEditingController(text: cliente?['cultivosPrincipales']?.toString() ?? '');
    final geolocalizacionLatController =
        TextEditingController(text: cliente?['geolocalizacionLat']?.toString() ?? '');
    final geolocalizacionLngController =
        TextEditingController(text: cliente?['geolocalizacionLng']?.toString() ?? '');
    final observacionesController = TextEditingController(text: cliente?['observaciones']?.toString() ?? '');
    final tecnicoAsignadoController =
        TextEditingController(text: cliente?['tecnicoAsignadoId']?.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Editar Cliente' : 'Nuevo Cliente'),
        content: SingleChildScrollView(
          child: SizedBox(
            width: 520,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: cedulaController,
                  enabled: !isEditing,
                  decoration: const InputDecoration(
                    labelText: 'Cédula *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nombreController,
                  enabled: !isEditing,
                  decoration: const InputDecoration(
                    labelText: 'Nombre *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: apellidosController,
                  enabled: !isEditing,
                  decoration: const InputDecoration(
                    labelText: 'Apellidos',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: telefonoController,
                  decoration: const InputDecoration(
                    labelText: 'Teléfono',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: direccionController,
                  decoration: const InputDecoration(
                    labelText: 'Dirección',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: parroquiaController,
                  decoration: const InputDecoration(
                    labelText: 'Parroquia',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: fincaNombreController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de finca',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: fincaHectareasController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Hectáreas de finca',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: cultivosController,
                  decoration: const InputDecoration(
                    labelText: 'Cultivos principales',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: geolocalizacionLatController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                  decoration: const InputDecoration(
                    labelText: 'Latitud',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: geolocalizacionLngController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                  decoration: const InputDecoration(
                    labelText: 'Longitud',
                    border: OutlineInputBorder(),
                  ),
                ),
                if (!isEditing) ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: tecnicoAsignadoController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'ID técnico asignado',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                TextField(
                  controller: observacionesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Observaciones',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              double? parseDouble(String value) => value.trim().isEmpty ? null : double.tryParse(value);
              int? parseInt(String value) => value.trim().isEmpty ? null : int.tryParse(value);

              if (!isEditing &&
                  (cedulaController.text.trim().isEmpty || nombreController.text.trim().isEmpty)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cédula y nombre son obligatorios')),
                );
                return;
              }

              final hectareas = parseDouble(fincaHectareasController.text);
              if (fincaHectareasController.text.trim().isNotEmpty && hectareas == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Hectáreas debe ser numérico')),
                );
                return;
              }

              final lat = parseDouble(geolocalizacionLatController.text);
              if (geolocalizacionLatController.text.trim().isNotEmpty && lat == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Latitud debe ser numérica')),
                );
                return;
              }

              final lng = parseDouble(geolocalizacionLngController.text);
              if (geolocalizacionLngController.text.trim().isNotEmpty && lng == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Longitud debe ser numérica')),
                );
                return;
              }

              final tecnicoId = parseInt(tecnicoAsignadoController.text);
              if (!isEditing && tecnicoAsignadoController.text.trim().isNotEmpty && tecnicoId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('ID técnico debe ser numérico')),
                );
                return;
              }

              try {
                if (isEditing) {
                  final clientId = parseInt(cliente?['id']?.toString() ?? '');
                  if (clientId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No se encontró el ID del cliente')),
                    );
                    return;
                  }

                  final updateData = {
                    'telefono': telefonoController.text.trim(),
                    'email': emailController.text.trim(),
                    'direccion': direccionController.text.trim(),
                    'parroquia': parroquiaController.text.trim(),
                    'fincaNombre': fincaNombreController.text.trim(),
                    'cultivosPrincipales': cultivosController.text.trim(),
                    'observaciones': observacionesController.text.trim(),
                    'fincaHectareas': hectareas,
                    'geolocalizacionLat': lat,
                    'geolocalizacionLng': lng,
                  };

                  await _service.updateCliente(clientId, updateData);
                } else {
                  final clientData = {
                    'cedula': cedulaController.text.trim(),
                    'nombre': nombreController.text.trim(),
                    'apellidos': apellidosController.text.trim(),
                    'telefono': telefonoController.text.trim(),
                    'email': emailController.text.trim(),
                    'direccion': direccionController.text.trim(),
                    'parroquia': parroquiaController.text.trim(),
                    'fincaNombre': fincaNombreController.text.trim(),
                    'cultivosPrincipales': cultivosController.text.trim(),
                    'observaciones': observacionesController.text.trim(),
                  };

                  if (hectareas != null) {
                    clientData['fincaHectareas'] = hectareas;
                  }

                  if (lat != null) {
                    clientData['geolocalizacionLat'] = lat;
                  }

                  if (lng != null) {
                    clientData['geolocalizacionLng'] = lng;
                  }

                  if (tecnicoId != null) {
                    clientData['tecnicoAsignadoId'] = tecnicoId;
                  }

                  await _service.createCliente(clientData);
                }

                if (mounted) {
                  Navigator.pop(context);
                  _loadClientes();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(isEditing ? 'Cliente actualizado' : 'Cliente creado')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al guardar cliente: $e')),
                  );
                }
              }
            },
            child: Text(isEditing ? 'Actualizar' : 'Crear'),
          ),
        ],
      ),
    );
  }

  void _showClienteDetails(Map<String, dynamic> cliente) {
    final nombreCompleto = '${cliente['nombre'] ?? ''} ${cliente['apellidos'] ?? ''}'.trim();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detalle de Cliente'),
        content: SizedBox(
          width: 480,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Cédula: ${cliente['cedula'] ?? ''}'),
              const SizedBox(height: 8),
              Text('Nombre: $nombreCompleto'),
              const SizedBox(height: 8),
              Text('Teléfono: ${cliente['telefono'] ?? ''}'),
              const SizedBox(height: 8),
              Text('Email: ${cliente['email'] ?? ''}'),
              const SizedBox(height: 8),
              Text('Dirección: ${cliente['direccion'] ?? ''}'),
              const SizedBox(height: 8),
              Text('Parroquia: ${cliente['parroquia'] ?? ''}'),
              const SizedBox(height: 8),
              Text('Finca: ${cliente['fincaNombre'] ?? ''}'),
              const SizedBox(height: 8),
              Text('Hectáreas: ${cliente['fincaHectareas'] ?? ''}'),
              const SizedBox(height: 8),
              Text('Cultivos: ${cliente['cultivosPrincipales'] ?? ''}'),
              const SizedBox(height: 8),
              Text('Latitud: ${cliente['geolocalizacionLat'] ?? ''}'),
              const SizedBox(height: 8),
              Text('Longitud: ${cliente['geolocalizacionLng'] ?? ''}'),
              const SizedBox(height: 8),
              Text('Observaciones: ${cliente['observaciones'] ?? ''}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24.0),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Gestión de Clientes',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Administra los clientes y fincas',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: _showClienteDialog,
                      icon: const Icon(Icons.add),
                      label: const Text('Nuevo Cliente'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Buscar clientes...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredClientes.isEmpty
                    ? const Center(
                        child: Text('No hay clientes registrados'),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(24.0),
                        child: Card(
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('Cédula')),
                              DataColumn(label: Text('Nombre')),
                              DataColumn(label: Text('Teléfono')),
                              DataColumn(label: Text('Email')),
                              DataColumn(label: Text('Finca')),
                              DataColumn(label: Text('Acciones')),
                            ],
                            rows: _filteredClientes.map((cliente) {
                              final nombreCompleto =
                                  '${cliente['nombre'] ?? ''} ${cliente['apellidos'] ?? ''}'.trim();
                              return DataRow(
                                cells: [
                                  DataCell(Text(cliente['cedula'] ?? '')),
                                  DataCell(Text(nombreCompleto.isEmpty ? '' : nombreCompleto)),
                                  DataCell(Text(cliente['telefono'] ?? '')),
                                  DataCell(Text(cliente['email'] ?? 'N/A')),
                                  DataCell(Text(cliente['fincaNombre'] ?? 'N/A')),
                                  DataCell(
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.visibility, size: 20),
                                          onPressed: () => _showClienteDetails(cliente),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.edit, size: 20),
                                          onPressed: () => _showClienteDialog(cliente: cliente),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
