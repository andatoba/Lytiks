import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ReportesScreen extends StatefulWidget {
  const ReportesScreen({super.key});

  @override
  State<ReportesScreen> createState() => _ReportesScreenState();
}

class _ReportesScreenState extends State<ReportesScreen> {
  static const String baseUrl = 'http://5.161.198.89:8081/api';
  String? _selectedReportType;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  bool _isGenerating = false;

  final List<Map<String, dynamic>> _reportTypes = [
    {
      'id': 'moko',
      'title': 'Reporte de Auditorías Moko',
      'icon': Icons.security,
      'color': const Color(0xFFFF5722),
      'description': 'Reporte completo de focos Moko registrados',
    },
    {
      'id': 'sigatoka',
      'title': 'Reporte de Auditorías Sigatoka',
      'icon': Icons.biotech,
      'color': const Color(0xFF4CAF50),
      'description': 'Análisis de severidad y cumplimiento Sigatoka',
    },
    {
      'id': 'clientes',
      'title': 'Reporte de Clientes',
      'icon': Icons.people,
      'color': const Color(0xFF2563EB),
      'description': 'Listado de clientes y sus fincas',
    },
    {
      'id': 'productos',
      'title': 'Reporte de Productos Aplicados',
      'icon': Icons.inventory,
      'color': const Color(0xFF9C27B0),
      'description': 'Productos de contención y seguimiento',
    },
  ];

  Future<void> _generateReport() async {
    if (_selectedReportType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor seleccione un tipo de reporte')),
      );
      return;
    }

    setState(() => _isGenerating = true);
    
    try {
      String endpoint = '';
      switch (_selectedReportType) {
        case 'moko':
          endpoint = '$baseUrl/moko/registros';
          break;
        case 'sigatoka':
          endpoint = '$baseUrl/sigatoka/all';
          break;
        case 'clientes':
          endpoint = '$baseUrl/clients';
          break;
        case 'productos':
          endpoint = '$baseUrl/moko/productos-contencion';
          break;
      }

      final response = await http.get(
        Uri.parse(endpoint),
        headers: {'Content-Type': 'application/json'},
      );

      setState(() => _isGenerating = false);

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Reporte generado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          // TODO: Implementar descarga del reporte en formato PDF o Excel
        }
      }
    } catch (e) {
      setState(() => _isGenerating = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al generar reporte: $e')),
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
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Generación de Reportes',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Genera reportes detallados del sistema',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Selector de tipo de reporte
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Seleccione el tipo de reporte',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 16),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 4 : 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 1.2,
                            ),
                            itemCount: _reportTypes.length,
                            itemBuilder: (context, index) {
                              final reportType = _reportTypes[index];
                              final isSelected = _selectedReportType == reportType['id'];
                              
                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedReportType = reportType['id'] as String;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: isSelected
                                          ? reportType['color'] as Color
                                          : Colors.grey.shade300,
                                      width: isSelected ? 2 : 1,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    color: isSelected
                                        ? (reportType['color'] as Color).withOpacity(0.1)
                                        : Colors.white,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        reportType['icon'] as IconData,
                                        size: 48,
                                        color: reportType['color'] as Color,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        reportType['title'] as String,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        reportType['description'] as String,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Rango de fechas
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Rango de fechas',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ListTile(
                                  title: const Text('Fecha de inicio'),
                                  subtitle: Text('${_startDate.day}/${_startDate.month}/${_startDate.year}'),
                                  trailing: const Icon(Icons.calendar_today),
                                  onTap: () async {
                                    final date = await showDatePicker(
                                      context: context,
                                      initialDate: _startDate,
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime.now(),
                                    );
                                    if (date != null) {
                                      setState(() => _startDate = date);
                                    }
                                  },
                                ),
                              ),
                              Expanded(
                                child: ListTile(
                                  title: const Text('Fecha de fin'),
                                  subtitle: Text('${_endDate.day}/${_endDate.month}/${_endDate.year}'),
                                  trailing: const Icon(Icons.calendar_today),
                                  onTap: () async {
                                    final date = await showDatePicker(
                                      context: context,
                                      initialDate: _endDate,
                                      firstDate: _startDate,
                                      lastDate: DateTime.now(),
                                    );
                                    if (date != null) {
                                      setState(() => _endDate = date);
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Botón de generar
                  Center(
                    child: SizedBox(
                      width: 300,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _isGenerating ? null : _generateReport,
                        icon: _isGenerating
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Icon(Icons.download),
                        label: Text(_isGenerating ? 'Generando...' : 'Generar Reporte'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
