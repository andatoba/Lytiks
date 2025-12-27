import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AuditoriasScreen extends StatefulWidget {
  const AuditoriasScreen({super.key});

  @override
  State<AuditoriasScreen> createState() => _AuditoriasScreenState();
}

class _AuditoriasScreenState extends State<AuditoriasScreen> with SingleTickerProviderStateMixin {
  static const String baseUrl = 'http://5.161.198.89:8081/api';
  late TabController _tabController;
  
  List<Map<String, dynamic>> _auditoriasMoko = [];
  List<Map<String, dynamic>> _auditoriasSigatoka = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAuditorias();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAuditorias() async {
    setState(() => _isLoading = true);
    try {
      // Cargar auditorías Moko
      final mokoResponse = await http.get(
        Uri.parse('$baseUrl/moko/registros'),
        headers: {'Content-Type': 'application/json'},
      );
      
      // Cargar auditorías Sigatoka - NUEVO ENDPOINT
      final sigatokaResponse = await http.get(
        Uri.parse('$baseUrl/sigatoka/evaluaciones'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (mokoResponse.statusCode == 200 && sigatokaResponse.statusCode == 200) {
        setState(() {
          _auditoriasMoko = List<Map<String, dynamic>>.from(
            jsonDecode(utf8.decode(mokoResponse.bodyBytes))
          );
          _auditoriasSigatoka = List<Map<String, dynamic>>.from(
            jsonDecode(utf8.decode(sigatokaResponse.bodyBytes))
          );
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar auditorías: $e')),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Auditorías',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Consulta y gestión de auditorías',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TabBar(
                  controller: _tabController,
                  labelColor: const Color(0xFF2563EB),
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: const Color(0xFF2563EB),
                  tabs: const [
                    Tab(text: 'Moko'),
                    Tab(text: 'Sigatoka'),
                  ],
                ),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildMokoTab(),
                      _buildSigatokaTab(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMokoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Card(
        child: _auditoriasMoko.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(child: Text('No hay auditorías Moko registradas')),
              )
            : DataTable(
                columns: const [
                  DataColumn(label: Text('ID')),
                  DataColumn(label: Text('Foco')),
                  DataColumn(label: Text('Cliente')),
                  DataColumn(label: Text('Fecha')),
                  DataColumn(label: Text('Plantas Afectadas')),
                  DataColumn(label: Text('Estado')),
                ],
                rows: _auditoriasMoko.map((auditoria) {
                  return DataRow(
                    cells: [
                      DataCell(Text('${auditoria['id'] ?? ''}')),
                      DataCell(Text('Foco ${auditoria['numeroFoco'] ?? ''}')),
                      DataCell(Text(auditoria['nombreCliente'] ?? 'N/A')),
                      DataCell(Text(auditoria['fecha'] ?? '')),
                      DataCell(Text('${auditoria['plantasAfectadas'] ?? 0}')),
                      DataCell(
                        Chip(
                          label: Text(
                            auditoria['estado'] ?? 'PENDIENTE',
                            style: const TextStyle(fontSize: 12),
                          ),
                          backgroundColor: Colors.orange.shade100,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
      ),
    );
  }

  Widget _buildSigatokaTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Card(
        child: _auditoriasSigatoka.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(child: Text('No hay evaluaciones Sigatoka registradas')),
              )
            : DataTable(
                columns: const [
                  DataColumn(label: Text('ID')),
                  DataColumn(label: Text('Hacienda')),
                  DataColumn(label: Text('Fecha')),
                  DataColumn(label: Text('Evaluador')),
                  DataColumn(label: Text('Semana')),
                  DataColumn(label: Text('Estado')),
                ],
                rows: _auditoriasSigatoka.map((evaluacion) {
                  // Determinar si tiene datos calculados
                  final tieneCalculo = evaluacion['resumen'] != null || 
                                      evaluacion['indicadores'] != null ||
                                      evaluacion['estadoEvolutivo'] != null;
                  
                  return DataRow(
                    cells: [
                      DataCell(Text('${evaluacion['id'] ?? ''}')),
                      DataCell(Text(evaluacion['hacienda'] ?? 'N/A')),
                      DataCell(Text(evaluacion['fecha']?.toString().split('T')[0] ?? '')),
                      DataCell(Text(evaluacion['evaluador'] ?? 'N/A')),
                      DataCell(Text('${evaluacion['semanaEpidemiologica'] ?? '-'}')),
                      DataCell(
                        Chip(
                          label: Text(
                            tieneCalculo ? 'Calculado' : 'Pendiente',
                            style: const TextStyle(fontSize: 12),
                          ),
                          backgroundColor: tieneCalculo 
                            ? Colors.green.shade100 
                            : Colors.orange.shade100,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
      ),
    );
  }
}
