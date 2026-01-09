import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/client_service.dart';
import '../services/sigatoka_evaluacion_service.dart';
import 'resumen_sigatoka_screen.dart';

// Estructura de datos para una muestra
class MuestraSigatoka {
  int numero;
  String lote;
  String grado3era;
  String grado4ta;
  String grado5ta;
  int totalHojas;
  double hvleSemana0;
  double hvlqSemana0;
  double hvlq5Semana0;
  double thSemana0;
  double hvleSemana10;
  double hvlqSemana10;
  double hvlq5Semana10;
  double thSemana10;

  MuestraSigatoka({
    required this.numero,
    required this.lote,
    required this.grado3era,
    required this.grado4ta,
    required this.grado5ta,
    required this.totalHojas,
    required this.hvleSemana0,
    required this.hvlqSemana0,
    required this.hvlq5Semana0,
    required this.thSemana0,
    required this.hvleSemana10,
    required this.hvlqSemana10,
    required this.hvlq5Semana10,
    required this.thSemana10,
  });
}

class SigatokaAuditScreen extends StatefulWidget {
  final Map<String, dynamic>? clientData;

  const SigatokaAuditScreen({super.key, this.clientData});

  @override
  State<SigatokaAuditScreen> createState() => _SigatokaAuditScreenState();
}

class _SigatokaAuditScreenState extends State<SigatokaAuditScreen> {
  // Cliente seleccionado
  Map<String, dynamic>? _selectedClient;
  final TextEditingController _cedulaController = TextEditingController();
  final ClientService _clientService = ClientService();

  // 1. Encabezado
  final TextEditingController haciendaController = TextEditingController();
  final TextEditingController fechaController = TextEditingController();
  final TextEditingController semanaController = TextEditingController();
  final TextEditingController periodoController = TextEditingController();
  final TextEditingController evaluadorController = TextEditingController();

  // 2. Controladores para agregar muestras
  final TextEditingController muestraNumController = TextEditingController();
  final TextEditingController loteCodigoController = TextEditingController();
  final TextEditingController plantasMuestreadasController = TextEditingController();
  final TextEditingController grado3eraController = TextEditingController();
  final TextEditingController grado4taController = TextEditingController();
  final TextEditingController grado5taController = TextEditingController();
  final TextEditingController totalHojas3eraController = TextEditingController();
  final TextEditingController totalHojas4taController = TextEditingController();
  final TextEditingController totalHojas5taController = TextEditingController();
  final TextEditingController hvle0wController = TextEditingController();
  final TextEditingController hvlq0wController = TextEditingController();
  final TextEditingController hvlq5_0wController = TextEditingController();
  final TextEditingController th0wController = TextEditingController();
  final TextEditingController hvle10wController = TextEditingController();
  final TextEditingController hvlq10wController = TextEditingController();
  final TextEditingController hvlq5_10wController = TextEditingController();
  final TextEditingController th10wController = TextEditingController();

  // Datos recibidos del backend
  List<dynamic> muestras = [];
  Map<String, dynamic>? resumen;
  Map<String, dynamic>? indicadores;
  Map<String, dynamic>? interpretacion;
  Map<String, dynamic>? stoverReal;
  bool isLoading = false;
  int? evaluacionId;
  
  // Lista de muestras de la sesión actual (en memoria)
  List<Map<String, dynamic>> muestrasSesion = [];

  @override
  void initState() {
    super.initState();
    if (widget.clientData != null) {
      _selectedClient = widget.clientData;
    }
  }

  Future<void> _fetchReporte(int evaluacionId) async {
    // Validar que haya muestras en la sesión
    if (muestrasSesion.isEmpty) {
      // Si no hay muestras, solo mostrar mensaje informativo
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Evaluación creada. Ahora puede agregar muestras.'),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 3),
        ),
      );
      setState(() => isLoading = false);
      return;
    }
    
    setState(() => isLoading = true);
    
    try {
      final service = SigatokaEvaluacionService();
      
      // Enviar todas las muestras de la sesión al backend
      print('📤 Enviando ${muestrasSesion.length} muestras al backend...');
      
      for (var muestra in muestrasSesion) {
        final result = await service.agregarMuestraCompleta(
          evaluacionId: evaluacionId,
          lote: muestra['lote'],
          numeroMuestra: muestra['numeroMuestra'],
          hoja3era: muestra['hoja3era'],
          hoja4ta: muestra['hoja4ta'],
          hoja5ta: muestra['hoja5ta'],
          totalHojas3era: muestra['totalHojas3era'],
          totalHojas4ta: muestra['totalHojas4ta'],
          totalHojas5ta: muestra['totalHojas5ta'],
          plantasMuestreadas: muestra['plantasMuestreadas'] ?? 0,
          plantasConLesiones: 0,
          totalLesiones: 0,
          plantas3erEstadio: 0,
          totalLetras: 0,
          hvle0w: muestra['hvle0w'],
          hvlq0w: muestra['hvlq0w'],
          hvlq5_0w: muestra['hvlq5_0w'],
          th0w: muestra['th0w'],
          hvle10w: muestra['hvle10w'],
          hvlq10w: muestra['hvlq10w'],
          hvlq5_10w: muestra['hvlq5_10w'],
          th10w: muestra['th10w'],
        );
        
        if (!result['success']) {
          throw Exception('Error al guardar muestra #${muestra['numeroMuestra']}: ${result['message']}');
        }
      }
      
      print('✅ Todas las muestras guardadas en el backend');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ ${muestrasSesion.length} muestras guardadas exitosamente'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
      
      setState(() => isLoading = false);
      
    } catch (e) {
      print('❌ Error al guardar muestras: $e');
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar muestras: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  void _onCalcularResumen() {
    // Validar que haya muestras en la sesión
    if (muestrasSesion.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe agregar al menos una muestra antes de calcular el resumen'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    // Navegar a la pantalla de resumen con las muestras de la sesión
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResumenSigatokaScreen(
          muestrasSesion: muestrasSesion,
          evaluacionId: evaluacionId!,
        ),
      ),
    );
  }

  void _onGuardarEncabezado() async {
    if (_selectedClient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe seleccionar un cliente primero'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (haciendaController.text.isEmpty || 
        fechaController.text.isEmpty || 
        evaluadorController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Complete los campos obligatorios (Hacienda, Fecha, Evaluador)'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      // Crear evaluación
      final response = await http.post(
        Uri.parse('http://5.161.198.89:8081/api/sigatoka/crear-evaluacion'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'clienteId': _selectedClient!['id'],
          'hacienda': haciendaController.text,
          'fecha': fechaController.text,
          'semanaEpidemiologica': semanaController.text.isNotEmpty 
            ? int.tryParse(semanaController.text) 
            : null,
          'periodo': periodoController.text.isNotEmpty ? periodoController.text : null,
          'evaluador': evaluadorController.text,
        }),
      );
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        
        // El backend nuevo devuelve la estructura completa
        if (data['evaluacion'] != null && data['evaluacion']['id'] != null) {
          evaluacionId = data['evaluacion']['id'];
        } else if (data['id'] != null) {
          evaluacionId = data['id'];
        } else if (data['evaluacionId'] != null) {
          evaluacionId = data['evaluacionId'];
        }
        
        if (evaluacionId != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Evaluación #$evaluacionId creada exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Cargar reporte si hay muestras
          await _fetchReporte(evaluacionId!);
        } else {
          throw Exception('No se recibió el ID de evaluación');
        }
      } else {
        // Mostrar el error completo del servidor
        String errorMessage = 'Error ${response.statusCode}';
        try {
          final errorData = jsonDecode(response.body);
          errorMessage += ': ${errorData['message'] ?? errorData['error'] ?? response.body}';
        } catch (e) {
          errorMessage += ': ${response.body}';
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Error al guardar encabezado: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _onAgregarMuestra() async {
    if (evaluacionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe crear una evaluación primero'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Validar campos requeridos
    if (muestraNumController.text.isEmpty ||
        loteCodigoController.text.isEmpty ||
        plantasMuestreadasController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe completar Muestra #, Lote # y Plantas Muestreadas'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Guardar muestra en memoria (sesión actual)
    final muestraData = {
      'numeroMuestra': int.tryParse(muestraNumController.text) ?? 1,
      'lote': loteCodigoController.text,
      'plantasMuestreadas': int.tryParse(plantasMuestreadasController.text) ?? 0,
      'hoja3era': grado3eraController.text.isEmpty ? null : grado3eraController.text,
      'hoja4ta': grado4taController.text.isEmpty ? null : grado4taController.text,
      'hoja5ta': grado5taController.text.isEmpty ? null : grado5taController.text,
      'totalHojas3era': int.tryParse(totalHojas3eraController.text) ?? 0,
      'totalHojas4ta': int.tryParse(totalHojas4taController.text) ?? 0,
      'totalHojas5ta': int.tryParse(totalHojas5taController.text) ?? 0,
      'hvle0w': double.tryParse(hvle0wController.text) ?? 0.0,
      'hvlq0w': double.tryParse(hvlq0wController.text) ?? 0.0,
      'hvlq5_0w': double.tryParse(hvlq5_0wController.text) ?? 0.0,
      'th0w': double.tryParse(th0wController.text) ?? 0.0,
      'hvle10w': double.tryParse(hvle10wController.text) ?? 0.0,
      'hvlq10w': double.tryParse(hvlq10wController.text) ?? 0.0,
      'hvlq5_10w': double.tryParse(hvlq5_10wController.text) ?? 0.0,
      'th10w': double.tryParse(th10wController.text) ?? 0.0,
    };

    setState(() {
      muestrasSesion.add(muestraData);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ Muestra #${muestraData['numeroMuestra']} agregada (${muestrasSesion.length} en sesión)'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );

    // Limpiar solo los campos de la muestra, mantener lote para siguiente
    int nextMuestra = (int.tryParse(muestraNumController.text) ?? 0) + 1;
    muestraNumController.text = nextMuestra.toString();
    // NO limpiar lote para facilitar ingreso múltiple
    plantasMuestreadasController.clear();
    grado3eraController.clear();
    grado4taController.clear();
    grado5taController.clear();
    totalHojas3eraController.clear();
    totalHojas4taController.clear();
    totalHojas5taController.clear();
    hvle0wController.clear();
    hvlq0wController.clear();
    hvlq5_0wController.clear();
    th0wController.clear();
    hvle10wController.clear();
    hvlq10wController.clear();
    hvlq5_10wController.clear();
    th10wController.clear();
  }

  @override
  void dispose() {
    _cedulaController.dispose();
    haciendaController.dispose();
    fechaController.dispose();
    semanaController.dispose();
    periodoController.dispose();
    evaluadorController.dispose();
    muestraNumController.dispose();
    loteCodigoController.dispose();
    plantasMuestreadasController.dispose();
    grado3eraController.dispose();
    grado4taController.dispose();
    grado5taController.dispose();
    totalHojas3eraController.dispose();
    totalHojas4taController.dispose();
    totalHojas5taController.dispose();
    hvle0wController.dispose();
    hvlq0wController.dispose();
    hvlq5_0wController.dispose();
    th0wController.dispose();
    hvle10wController.dispose();
    hvlq10wController.dispose();
    hvlq5_10wController.dispose();
    th10wController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF004B63),
        title: const Text(
          'Evaluación Sigatoka',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.all(16),
              children: [
                _buildInfoCard(),
                SizedBox(height: 16),
                _buildClientSearchSection(),
                SizedBox(height: 24),
                _buildEncabezadoSection(),
                SizedBox(height: 24),
              ],
            ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF388E3C), Color(0xFF4CAF50)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
            child: const Icon(Icons.eco, color: Color(0xFF388E3C), size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Control de Sigatoka',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Análisis de evolución y control\nde la enfermedad Sigatoka',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.3,
                  ),
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
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _cedulaController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Cédula del Cliente',
                    hintText: 'Ingrese la cédula',
                    prefixIcon: const Icon(Icons.badge),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: _searchClientByCedula,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_selectedClient != null) ...[
            const SizedBox(height: 16),
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
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _searchClientByCedula() async {
    final cedula = _cedulaController.text.trim();
    if (cedula.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingrese una cédula para buscar.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Buscando cliente...'),
          ],
        ),
      ),
    );

    try {
      final client = await _clientService.searchClientByCedula(cedula);
      Navigator.of(context).pop();

      if (client != null) {
        setState(() {
          _selectedClient = client;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cliente encontrado y seleccionado.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se encontró cliente con esa cédula.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al buscar cliente: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // 1. Encabezado
  Widget _buildEncabezadoSection() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.description, color: Colors.blue[700], size: 28),
                ),
                const SizedBox(width: 12),
                const Text(
                  '📋 Encabezado - Datos Generales',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Color(0xFF004B63),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // HACIENDA
            TextField(
              controller: haciendaController,
              decoration: const InputDecoration(
                labelText: '🏡 Hacienda *',
                hintText: 'Nombre de la finca o predio',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.home),
              ),
            ),
            const SizedBox(height: 16),
            
            // FECHA CON CALENDARIO VISUAL
            InkWell(
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.light(
                          primary: Colors.blue[700]!,
                          onPrimary: Colors.white,
                          onSurface: Colors.black,
                        ),
                        textButtonTheme: TextButtonThemeData(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.blue[700],
                          ),
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null) {
                  setState(() {
                    fechaController.text = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.white,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: Colors.blue[700],
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '📅 Fecha de Muestreo *',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              fechaController.text.isEmpty 
                                ? 'Toque para seleccionar fecha' 
                                : fechaController.text,
                              style: TextStyle(
                                fontSize: 16,
                                color: fechaController.text.isEmpty ? Colors.grey : Colors.black,
                                fontWeight: fechaController.text.isEmpty ? FontWeight.normal : FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Icon(
                      Icons.arrow_drop_down,
                      color: Colors.blue[700],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // SEMANA Y PERÍODO
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: semanaController,
                    decoration: const InputDecoration(
                      labelText: '📆 Semana Epidemiológica',
                      hintText: 'Ej: 45',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_view_week),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: periodoController,
                    decoration: const InputDecoration(
                      labelText: '🧮 Período',
                      hintText: 'Ej: 04',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.numbers),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // EVALUADOR
            TextField(
              controller: evaluadorController,
              decoration: const InputDecoration(
                labelText: '👩‍🌾 Evaluador *',
                hintText: 'Nombre del técnico',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 20),
            
            // BOTÓN GUARDAR
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _onGuardarEncabezado,
                icon: const Icon(Icons.save),
                label: const Text('Guardar y Cargar Reporte'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFF004B63),
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            // NOTA INFORMATIVA
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Los campos marcados con * son obligatorios',
                      style: TextStyle(fontSize: 12, color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
            
            // SECCIÓN AGREGAR MUESTRAS (solo visible si hay evaluacionId)
            if (evaluacionId != null) ...[
              const SizedBox(height: 30),
              const Divider(thickness: 2),
              const SizedBox(height: 20),
              _buildAgregarMuestraSection(),
            ],
          ],
        ),
      ),
    );
  }
  
  // Nueva sección para agregar muestras completas
  Widget _buildAgregarMuestraSection() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.add_circle, color: Colors.green[700], size: 28),
                const SizedBox(width: 12),
                const Text(
                  '➕ Agregar Muestra',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF004B63),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Muestra # y Lote #
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: muestraNumController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '🌿 Muestra # *',
                      hintText: '1',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.tag),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: loteCodigoController,
                    decoration: const InputDecoration(
                      labelText: '🧭 Lote # *',
                      hintText: 'A1',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_on),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Plantas muestreadas
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: plantasMuestreadasController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '🌱 Plantas muestreadas *',
                      hintText: '10',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.eco),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Grados de infección
            const Text('🍃 Grado de Infección', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: TextField(controller: grado3eraController, decoration: const InputDecoration(labelText: '3era hoja', hintText: '2a', border: OutlineInputBorder()))),
                const SizedBox(width: 8),
                Expanded(child: TextField(controller: grado4taController, decoration: const InputDecoration(labelText: '4ta hoja', hintText: '3c', border: OutlineInputBorder()))),
                const SizedBox(width: 8),
                Expanded(child: TextField(controller: grado5taController, decoration: const InputDecoration(labelText: '5ta hoja', hintText: '1b', border: OutlineInputBorder()))),
              ],
            ),
            const SizedBox(height: 16),
            
            // Total hojas
            const Text('🍀 Total de Hojas en Planta', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: TextField(controller: totalHojas3eraController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Total hojas en 3era', hintText: '8', border: OutlineInputBorder()))),
                const SizedBox(width: 8),
                Expanded(child: TextField(controller: totalHojas4taController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Total hojas en 4ta', hintText: '8', border: OutlineInputBorder()))),
                const SizedBox(width: 8),
                Expanded(child: TextField(controller: totalHojas5taController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Total hojas en 5ta', hintText: '8', border: OutlineInputBorder()))),
              ],
            ),
            const SizedBox(height: 16),
            
            // Variables Stover 0 semanas
            const Text('📈 Variables Stover "0 semanas"', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: TextField(controller: hvle0wController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'H.V.L.E.', border: OutlineInputBorder()))),
                const SizedBox(width: 8),
                Expanded(child: TextField(controller: hvlq0wController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'H.V.L.Q.', border: OutlineInputBorder()))),
                const SizedBox(width: 8),
                Expanded(child: TextField(controller: hvlq5_0wController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'H.V.L.Q.5%', border: OutlineInputBorder()))),
                const SizedBox(width: 8),
                Expanded(child: TextField(controller: th0wController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'T.H.', border: OutlineInputBorder()))),
              ],
            ),
            const SizedBox(height: 16),
            
            // Variables Stover 10 semanas
            const Text('📈 Variables Stover "10 semanas"', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: TextField(controller: hvle10wController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'H.V.L.E.', border: OutlineInputBorder()))),
                const SizedBox(width: 8),
                Expanded(child: TextField(controller: hvlq10wController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'H.V.L.Q.', border: OutlineInputBorder()))),
                const SizedBox(width: 8),
                Expanded(child: TextField(controller: hvlq5_10wController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'H.V.L.Q.5%', border: OutlineInputBorder()))),
                const SizedBox(width: 8),
                Expanded(child: TextField(controller: th10wController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'T.H.', border: OutlineInputBorder()))),
              ],
            ),
            const SizedBox(height: 20),
            
            // Botón Guardar Muestra
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _onAgregarMuestra,
                icon: const Icon(Icons.save),
                label: const Text('💾 Guardar Muestra'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Botón Calcular Todo (separado)
            if (evaluacionId != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _onCalcularResumen,
                  icon: const Icon(Icons.calculate),
                  label: const Text('🧮 Calcular Resumen e Indicadores'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
