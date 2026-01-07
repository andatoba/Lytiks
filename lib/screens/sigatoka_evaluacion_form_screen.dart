import 'package:flutter/material.dart';
import '../services/sigatoka_evaluacion_service.dart';
import '../services/client_service.dart';

class SigatokaEvaluacionFormScreen extends StatefulWidget {
  const SigatokaEvaluacionFormScreen({Key? key}) : super(key: key);

  @override
  State<SigatokaEvaluacionFormScreen> createState() => _SigatokaEvaluacionFormScreenState();
}

class _SigatokaEvaluacionFormScreenState extends State<SigatokaEvaluacionFormScreen> {
  final SigatokaEvaluacionService _service = SigatokaEvaluacionService();
  final ClientService _clientService = ClientService();
  
  // Estado de la evaluación
  int? _evaluacionId;
  int? _clienteId;
  String? _clienteNombre;
  bool _isLoading = false;
  int _currentStep = 0;
  
  // Controladores para el encabezado
  final TextEditingController _haciendaController = TextEditingController();
  final TextEditingController _fechaController = TextEditingController();
  final TextEditingController _semanaController = TextEditingController();
  final TextEditingController _periodoController = TextEditingController();
  final TextEditingController _evaluadorController = TextEditingController();
  
  // Controladores para las muestras - FORMATO EXCEL COMPLETO
  final TextEditingController _loteController = TextEditingController();
  int _numeroMuestra = 1;
  
  // Grados de infección (3era, 4ta, 5ta hoja)
  final TextEditingController _hoja3eraController = TextEditingController();
  final TextEditingController _hoja4taController = TextEditingController();
  final TextEditingController _hoja5taController = TextEditingController();
  
  // Total hojas por nivel
  final TextEditingController _totalHojas3eraController = TextEditingController();
  final TextEditingController _totalHojas4taController = TextEditingController();
  final TextEditingController _totalHojas5taController = TextEditingController();
  
  // Variables a-e (cálculo)
  final TextEditingController _plantasMuestreadasController = TextEditingController();
  final TextEditingController _plantasConLesionesController = TextEditingController();
  final TextEditingController _totalLesionesController = TextEditingController();
  final TextEditingController _plantas3erEstadioController = TextEditingController();
  final TextEditingController _totalLetrasController = TextEditingController();
  
  // Stover 0 semanas
  final TextEditingController _hvle0wController = TextEditingController();
  final TextEditingController _hvlq0wController = TextEditingController();
  final TextEditingController _hvlq5_0wController = TextEditingController();
  final TextEditingController _th0wController = TextEditingController();
  
  // Stover 10 semanas
  final TextEditingController _hvle10wController = TextEditingController();
  final TextEditingController _hvlq10wController = TextEditingController();
  final TextEditingController _hvlq5_10wController = TextEditingController();
  final TextEditingController _th10wController = TextEditingController();
  
  // Datos del reporte
  Map<String, dynamic>? _reporte;

  @override
  void dispose() {
    _haciendaController.dispose();
    _fechaController.dispose();
    _semanaController.dispose();
    _periodoController.dispose();
    _evaluadorController.dispose();
    _loteController.dispose();
    _hoja3eraController.dispose();
    _hoja4taController.dispose();
    _hoja5taController.dispose();
    _totalHojas3eraController.dispose();
    _totalHojas4taController.dispose();
    _totalHojas5taController.dispose();
    _plantasMuestreadasController.dispose();
    _plantasConLesionesController.dispose();
    _totalLesionesController.dispose();
    _plantas3erEstadioController.dispose();
    _totalLetrasController.dispose();
    _hvle0wController.dispose();
    _hvlq0wController.dispose();
    _hvlq5_0wController.dispose();
    _th0wController.dispose();
    _hvle10wController.dispose();
    _hvlq10wController.dispose();
    _hvlq5_10wController.dispose();
    _th10wController.dispose();
    super.dispose();
  }

  Future<void> _buscarCliente() async {
    final cedulaDialog = TextEditingController();
    
    final cedula = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buscar Cliente'),
        content: TextField(
          controller: cedulaDialog,
          decoration: const InputDecoration(
            labelText: 'Cédula del cliente',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, cedulaDialog.text),
            child: const Text('Buscar'),
          ),
        ],
      ),
    );
    
    if (cedula != null && cedula.isNotEmpty) {
      setState(() => _isLoading = true);
      try {
        final cliente = await _clientService.searchClientByCedula(cedula);
        if (cliente != null) {
          setState(() {
            _clienteId = cliente['id'];
            _clienteNombre = '${cliente['nombre']} ${cliente['apellidos'] ?? ''}';
            _haciendaController.text = cliente['fincaNombre'] ?? '';
          });
        } else {
          _showError('Cliente no encontrado');
        }
      } catch (e) {
        _showError('Error al buscar cliente: $e');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _crearEvaluacion() async {
    if (_clienteId == null) {
      _showError('Debe seleccionar un cliente primero');
      return;
    }
    
    if (_haciendaController.text.isEmpty || _evaluadorController.text.isEmpty) {
      _showError('Complete los campos requeridos');
      return;
    }
    
    setState(() => _isLoading = true);
    try {
      final resultado = await _service.crearEvaluacion(
        clienteId: _clienteId!,
        hacienda: _haciendaController.text,
        fecha: _fechaController.text.isNotEmpty 
          ? _fechaController.text 
          : DateTime.now().toIso8601String().split('T')[0],
        semanaEpidemiologica: _semanaController.text.isNotEmpty 
          ? int.parse(_semanaController.text) 
          : null,
        periodo: _periodoController.text.isNotEmpty ? _periodoController.text : null,
        evaluador: _evaluadorController.text,
      );
      
      if (resultado['success'] == true) {
        setState(() {
          _evaluacionId = resultado['evaluacionId'];
          _currentStep = 1;
        });
        _showSuccess('Evaluación creada exitosamente');
      } else {
        _showError(resultado['message'] ?? 'Error al crear evaluación');
      }
    } catch (e) {
      _showError('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _agregarMuestra() async {
    if (_evaluacionId == null) {
      _showError('Debe crear la evaluación primero');
      return;
    }
    
    if (_loteController.text.isEmpty) {
      _showError('El lote es requerido');
      return;
    }
    
    // Validar campos obligatorios
    if (_plantasMuestreadasController.text.isEmpty ||
        _plantasConLesionesController.text.isEmpty ||
        _totalLesionesController.text.isEmpty ||
        _plantas3erEstadioController.text.isEmpty ||
        _totalLetrasController.text.isEmpty) {
      _showError('Complete todos los campos obligatorios (a-e)');
      return;
    }
    
    setState(() => _isLoading = true);
    try {
      final resultado = await _service.agregarMuestraCompleta(
        evaluacionId: _evaluacionId!,
        numeroMuestra: _numeroMuestra,
        lote: _loteController.text,
        // Grados de infección
        hoja3era: _hoja3eraController.text.isNotEmpty ? _hoja3eraController.text : null,
        hoja4ta: _hoja4taController.text.isNotEmpty ? _hoja4taController.text : null,
        hoja5ta: _hoja5taController.text.isNotEmpty ? _hoja5taController.text : null,
        // Total hojas
        totalHojas3era: _totalHojas3eraController.text.isNotEmpty ? int.parse(_totalHojas3eraController.text) : null,
        totalHojas4ta: _totalHojas4taController.text.isNotEmpty ? int.parse(_totalHojas4taController.text) : null,
        totalHojas5ta: _totalHojas5taController.text.isNotEmpty ? int.parse(_totalHojas5taController.text) : null,
        // Variables a-e
        plantasMuestreadas: int.parse(_plantasMuestreadasController.text),
        plantasConLesiones: int.parse(_plantasConLesionesController.text),
        totalLesiones: int.parse(_totalLesionesController.text),
        plantas3erEstadio: int.parse(_plantas3erEstadioController.text),
        totalLetras: int.parse(_totalLetrasController.text),
        // Stover 0 semanas
        hvle0w: _hvle0wController.text.isNotEmpty ? double.parse(_hvle0wController.text) : null,
        hvlq0w: _hvlq0wController.text.isNotEmpty ? double.parse(_hvlq0wController.text) : null,
        hvlq5_0w: _hvlq5_0wController.text.isNotEmpty ? double.parse(_hvlq5_0wController.text) : null,
        th0w: _th0wController.text.isNotEmpty ? double.parse(_th0wController.text) : null,
        // Stover 10 semanas
        hvle10w: _hvle10wController.text.isNotEmpty ? double.parse(_hvle10wController.text) : null,
        hvlq10w: _hvlq10wController.text.isNotEmpty ? double.parse(_hvlq10wController.text) : null,
        hvlq5_10w: _hvlq5_10wController.text.isNotEmpty ? double.parse(_hvlq5_10wController.text) : null,
        th10w: _th10wController.text.isNotEmpty ? double.parse(_th10wController.text) : null,
      );
      
      if (resultado['success'] == true) {
        setState(() {
          _numeroMuestra++;
          _limpiarFormularioMuestra();
        });
        _showSuccess('Muestra #${_numeroMuestra - 1} agregada exitosamente');
      } else {
        _showError(resultado['message'] ?? 'Error al agregar muestra');
      }
    } catch (e) {
      _showError('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _calcularYVerReporte() async {
    if (_evaluacionId == null) {
      _showError('No hay evaluación activa');
      return;
    }
    
    setState(() => _isLoading = true);
    try {
      // Primero calcular
      await _service.calcularEvaluacion(evaluacionId: _evaluacionId!);
      
      // Luego obtener el reporte
      final resultado = await _service.obtenerReporte(_evaluacionId!);
      
      if (resultado['success'] == true) {
        setState(() {
          _reporte = resultado['reporte'];
          _currentStep = 2;
        });
      } else {
        _showError(resultado['message'] ?? 'Error al obtener reporte');
      }
    } catch (e) {
      _showError('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _limpiarFormularioMuestra() {
    _loteController.clear();
    _hoja3eraController.clear();
    _hoja4taController.clear();
    _hoja5taController.clear();
    _totalHojas3eraController.clear();
    _totalHojas4taController.clear();
    _totalHojas5taController.clear();
    _plantasMuestreadasController.clear();
    _plantasConLesionesController.clear();
    _totalLesionesController.clear();
    _plantas3erEstadioController.clear();
    _totalLetrasController.clear();
    _hvle0wController.clear();
    _hvlq0wController.clear();
    _hvlq5_0wController.clear();
    _th0wController.clear();
    _hvle10wController.clear();
    _hvlq10wController.clear();
    _hvlq5_10wController.clear();
    _th10wController.clear();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Evaluación Sigatoka'),
        actions: [
          if (_evaluacionId != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Chip(
                label: Text('Evaluación #$_evaluacionId'),
                backgroundColor: Colors.green[100],
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stepper(
              currentStep: _currentStep,
              onStepContinue: () {
                if (_currentStep == 0) {
                  _crearEvaluacion();
                } else if (_currentStep == 1) {
                  _calcularYVerReporte();
                }
              },
              onStepCancel: () {
                if (_currentStep > 0) {
                  setState(() => _currentStep--);
                }
              },
              steps: [
                Step(
                  title: const Text('1. Encabezado'),
                  content: _buildEncabezadoSection(),
                  isActive: _currentStep >= 0,
                ),
                Step(
                  title: const Text('2. Muestras'),
                  content: _buildMuestrasSection(),
                  isActive: _currentStep >= 1,
                ),
                Step(
                  title: const Text('3. Reporte'),
                  content: _buildReporteSection(),
                  isActive: _currentStep >= 2,
                ),
              ],
            ),
    );
  }

  Widget _buildEncabezadoSection() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // BÚSQUEDA DE CLIENTE
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: _buscarCliente,
                    icon: const Icon(Icons.search),
                    label: const Text('Buscar Cliente por Cédula'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  if (_clienteNombre != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        border: Border.all(color: Colors.green),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green, size: 32),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Cliente Seleccionado:',
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                                Text(
                                  _clienteNombre!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
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
            ),
          ),
          const SizedBox(height: 20),
          
          // DATOS DE LA EVALUACIÓN
          Text(
            '📋 Datos de Identificación',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
          const SizedBox(height: 12),
          
          // HACIENDA
          TextField(
            controller: _haciendaController,
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
                locale: const Locale('es', 'ES'),
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
                  _fechaController.text = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
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
                            _fechaController.text.isEmpty 
                              ? 'Toque para seleccionar fecha' 
                              : _fechaController.text,
                            style: TextStyle(
                              fontSize: 16,
                              color: _fechaController.text.isEmpty ? Colors.grey : Colors.black,
                              fontWeight: _fechaController.text.isEmpty ? FontWeight.normal : FontWeight.bold,
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
                  controller: _semanaController,
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
                  controller: _periodoController,
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
            controller: _evaluadorController,
            decoration: const InputDecoration(
              labelText: '👩‍🌾 Evaluador *',
              hintText: 'Nombre del técnico',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
          ),
          const SizedBox(height: 8),
          
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
        ],
      ),
    );
  }

  Widget _buildMuestrasSection() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            color: Colors.blue[50],
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  const Icon(Icons.analytics, color: Colors.blue, size: 32),
                  const SizedBox(width: 12),
                  Text(
                    'Muestra #$_numeroMuestra',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.blue[900],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // 🧭 LOTE
          TextField(
            controller: _loteController,
            decoration: const InputDecoration(
              labelText: '🧭 Lote *',
              hintText: 'Código del lote (ej: L-01)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          
          // 🍃 GRADOS DE INFECCIÓN (3era, 4ta, 5ta hoja)
          Text(
            '🍃 Grados de Infección',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.green[800],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _hoja3eraController,
                  decoration: const InputDecoration(
                    labelText: '3era Hoja',
                    hintText: 'ej: 2a',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _hoja4taController,
                  decoration: const InputDecoration(
                    labelText: '4ta Hoja',
                    hintText: 'ej: 3c',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _hoja5taController,
                  decoration: const InputDecoration(
                    labelText: '5ta Hoja',
                    hintText: 'ej: 4b',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // 🍀 TOTAL DE HOJAS
          Text(
            '🍀 Total de Hojas por Nivel',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.green[800],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _totalHojas3eraController,
                  decoration: const InputDecoration(
                    labelText: 'Total 3era',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _totalHojas4taController,
                  decoration: const InputDecoration(
                    labelText: 'Total 4ta',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _totalHojas5taController,
                  decoration: const InputDecoration(
                    labelText: 'Total 5ta',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // 📈 VARIABLES PARA CÁLCULO (a-e)
          Text(
            '📈 Variables para Cálculo',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.orange[800],
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _plantasMuestreadasController,
            decoration: const InputDecoration(
              labelText: 'a) Plantas Muestreadas *',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _plantasConLesionesController,
            decoration: const InputDecoration(
              labelText: 'b) Plantas con Lesiones *',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _totalLesionesController,
            decoration: const InputDecoration(
              labelText: 'c) Total de Lesiones *',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _plantas3erEstadioController,
            decoration: const InputDecoration(
              labelText: 'd) Plantas en 3er Estadio *',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _totalLetrasController,
            decoration: const InputDecoration(
              labelText: 'e) Total de Letras (severidad) *',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 20),
          
          // 📊 STOVER 0 SEMANAS
          Text(
            '📊 Variables Stover (0 Semanas)',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.purple[800],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _hvle0wController,
                  decoration: const InputDecoration(
                    labelText: 'H.V.L.E.',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _hvlq0wController,
                  decoration: const InputDecoration(
                    labelText: 'H.V.L.Q.',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _hvlq5_0wController,
                  decoration: const InputDecoration(
                    labelText: 'H.V.L.Q. 5%',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _th0wController,
                  decoration: const InputDecoration(
                    labelText: 'T.H.',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // 📊 STOVER 10 SEMANAS
          Text(
            '📊 Variables Stover (10 Semanas)',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.purple[800],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _hvle10wController,
                  decoration: const InputDecoration(
                    labelText: 'H.V.L.E.',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _hvlq10wController,
                  decoration: const InputDecoration(
                    labelText: 'H.V.L.Q.',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _hvlq5_10wController,
                  decoration: const InputDecoration(
                    labelText: 'H.V.L.Q. 5%',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _th10wController,
                  decoration: const InputDecoration(
                    labelText: 'T.H.',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // BOTONES DE ACCIÓN
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _agregarMuestra,
                  icon: const Icon(Icons.add_circle),
                  label: const Text('Agregar Muestra'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: _limpiarFormularioMuestra,
                icon: const Icon(Icons.clear),
                label: const Text('Limpiar'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReporteSection() {
    if (_reporte == null) {
      return const Center(
        child: Text('No hay datos del reporte'),
      );
    }
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEncabezadoReporte(),
          const Divider(height: 32),
          _buildMuestrasReporte(),
          const Divider(height: 32),
          _buildResumenReporte(),
          const Divider(height: 32),
          _buildIndicadoresReporte(),
          const Divider(height: 32),
          _buildEstadoEvolutivoReporte(),
        ],
      ),
    );
  }

  Widget _buildEncabezadoReporte() {
    final encabezado = _reporte!['encabezado'] as Map<String, dynamic>;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Encabezado', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Text('Hacienda: ${encabezado['hacienda']}'),
            Text('Fecha: ${encabezado['fecha']}'),
            Text('Evaluador: ${encabezado['evaluador']}'),
            if (encabezado['semanaEpidemiologica'] != null)
              Text('Semana: ${encabezado['semanaEpidemiologica']}'),
          ],
        ),
      ),
    );
  }

  Widget _buildMuestrasReporte() {
    final muestras = _reporte!['muestras'] as List<dynamic>;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Muestras (${muestras.length})', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            ...muestras.map((m) => ListTile(
              leading: CircleAvatar(child: Text('${m['numeroMuestra']}')),
              title: Text('Lote: ${m['lote']}'),
              subtitle: Text(
                'Emitidas: ${m['hojasEmitidas']}, Erectas: ${m['hojasErectas']}, Síntomas: ${m['hojasConSintomas']}'
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildResumenReporte() {
    final resumen = _reporte!['resumen'] as Map<String, dynamic>?;
    
    if (resumen == null) return const SizedBox.shrink();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Resumen General (a-e)', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Text('a) Promedio hojas emitidas: ${resumen['promedioHojasEmitidas']}'),
            Text('b) Promedio hojas erectas: ${resumen['promedioHojasErectas']}'),
            Text('c) Promedio hojas síntomas: ${resumen['promedioHojasSintomas']}'),
            Text('d) Promedio hoja joven enferma: ${resumen['promedioHojaJovenEnferma']}'),
            Text('e) Promedio hoja joven necrosada: ${resumen['promedioHojaJovenNecrosada']}'),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicadoresReporte() {
    final indicadores = _reporte!['indicadores'] as Map<String, dynamic>?;
    
    if (indicadores == null) return const SizedBox.shrink();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Indicadores (f-k)', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Text('f) Incidencia promedio: ${indicadores['incidenciaPromedio']}'),
            Text('g) Severidad promedio: ${indicadores['severidadPromedio']}%'),
            Text('h) Índice hojas erectas: ${indicadores['indiceHojasErectas']}%'),
            Text('i) Ritmo emisión: ${indicadores['ritmoEmision']}'),
            Text('j) Velocidad evolución: ${indicadores['velocidadEvolucion']}'),
            Text('k) Velocidad necrosis: ${indicadores['velocidadNecrosis']}'),
          ],
        ),
      ),
    );
  }

  Widget _buildEstadoEvolutivoReporte() {
    final estado = _reporte!['estadoEvolutivo'] as Map<String, dynamic>?;
    
    if (estado == null) return const SizedBox.shrink();
    
    return Card(
      color: Colors.orange[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Estado Evolutivo', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Text('EE 3era hoja: ${estado['ee3eraHoja']}'),
            Text('EE 4ta hoja: ${estado['ee4taHoja']}'),
            Text('EE 5ta hoja: ${estado['ee5taHoja']}'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Nivel de Infección: ${estado['nivelInfeccion']}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
