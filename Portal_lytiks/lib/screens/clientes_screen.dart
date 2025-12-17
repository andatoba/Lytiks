import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ClientesScreen extends StatefulWidget {
  const ClientesScreen({super.key});

  @override
  State<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  static const String baseUrl = 'http://5.161.198.89:8081/api';
  List<Map<String, dynamic>> _clientes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadClientes();
  }

  Future<void> _loadClientes() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/clients'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          _clientes = List<Map<String, dynamic>>.from(data);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar clientes: $e')),
        );
      }
    }
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
            child: Row(
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
                  onPressed: () {
                    // TODO: Implementar agregar cliente
                  },
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
          ),
          
          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _clientes.isEmpty
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
                            rows: _clientes.map((cliente) {
                              return DataRow(
                                cells: [
                                  DataCell(Text(cliente['cedula'] ?? '')),
                                  DataCell(Text(cliente['nombre'] ?? '')),
                                  DataCell(Text(cliente['telefono'] ?? '')),
                                  DataCell(Text(cliente['email'] ?? 'N/A')),
                                  DataCell(Text(cliente['finca'] ?? 'N/A')),
                                  DataCell(
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.visibility, size: 20),
                                          onPressed: () {
                                            // TODO: Ver detalles
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.edit, size: 20),
                                          onPressed: () {
                                            // TODO: Editar cliente
                                          },
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
