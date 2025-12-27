import 'package:flutter/material.dart';
import '../services/sigatoka_service.dart';

// Importa los widgets/secciones existentes si los vas a reutilizar
// import 'sigatoka_select_cliente_screen.dart';
// import 'sigatoka_evaluacion_form_screen.dart';
// import 'sigatoka_muestras_screen.dart';
// import 'sigatoka_resultado_screen.dart';

class SigatokaScreen extends StatefulWidget {
  const SigatokaScreen({super.key});

  @override
  State<SigatokaScreen> createState() => _SigatokaScreenState();
}

class _SigatokaScreenState extends State<SigatokaScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Aquí puedes manejar el estado global de la evaluación, lotes, muestras, resultados, etc.
  // Por ejemplo:
  String? clienteId;
  Map<String, dynamic> evaluacion = {};
  List<Map<String, dynamic>> lotes = [];
  List<Map<String, dynamic>> muestras = [];
  Map<String, dynamic> resultados = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Evaluación Sigatoka'),
        backgroundColor: const Color(0xFF2563EB),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Encabezado'),
            Tab(text: 'Muestras'),
            Tab(text: 'Resumen'),
            Tab(text: 'Indicadores'),
            Tab(text: 'Interpretación'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildEncabezadoSection(),
          _buildMuestrasSection(),
          _buildResumenSection(),
          _buildIndicadoresSection(),
          _buildInterpretacionSection(),
        ],
      ),
    );
  }

  Widget _buildEncabezadoSection() {
    final _formKey = GlobalKey<FormState>();
    final _clienteController = TextEditingController();
    final _haciendaController = TextEditingController();
    final _fechaController = TextEditingController();
    final _semanaController = TextEditingController();
    final _periodoController = TextEditingController();
    final _evaluadorController = TextEditingController();
    final _lotesController = TextEditingController();
    bool _isLoading = false;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            Text('Datos Generales', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
            const SizedBox(height: 16),
            TextFormField(
              controller: _clienteController,
              decoration: const InputDecoration(labelText: 'Cliente/Hacienda'),
              validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
            ),
            TextFormField(
              controller: _haciendaController,
              decoration: const InputDecoration(labelText: 'Nombre de la finca/predio'),
              validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
            ),
            TextFormField(
              controller: _fechaController,
              decoration: const InputDecoration(labelText: 'Fecha de muestreo (YYYY-MM-DD)'),
              validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
            ),
            TextFormField(
              controller: _semanaController,
              decoration: const InputDecoration(labelText: 'Semana epidemiológica'),
              validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
            ),
            TextFormField(
              controller: _periodoController,
              decoration: const InputDecoration(labelText: 'Período/Ciclo'),
            ),
            TextFormField(
              controller: _evaluadorController,
              decoration: const InputDecoration(labelText: 'Evaluador'),
              validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
            ),
            TextFormField(
              controller: _lotesController,
              decoration: const InputDecoration(labelText: 'Lotes (separados por coma)'),
              validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
              ),
              onPressed: _isLoading ? null : () async {
                if (_formKey.currentState!.validate()) {
                  setState(() => _isLoading = true);
                  final service = SigatokaService();
                  final data = {
                    'clienteId': _clienteController.text.trim(),
                    'hacienda': _haciendaController.text.trim(),
                    'fecha': _fechaController.text.trim(),
                    'semanaEpidemiologica': _semanaController.text.trim(),
                    'periodo': _periodoController.text.trim(),
                    'evaluador': _evaluadorController.text.trim(),
                    'lotes': _lotesController.text.split(',').map((e) => e.trim()).toList(),
                  };
                  final resp = await service.crearEvaluacion(data);
                  if (mounted) {
                    setState(() => _isLoading = false);
                    if (resp['success'] == true) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Evaluación creada exitosamente'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: ${resp['error']}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Crear Evaluación'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMuestrasSection() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Función en desarrollo',
            style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Ingreso de muestras por lote',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildResumenSection() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.summarize, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Función en desarrollo',
            style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Resumen de totales y promedios',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicadoresSection() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.speed, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Función en desarrollo',
            style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Indicadores técnicos automáticos',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildInterpretacionSection() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assessment, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Función en desarrollo',
            style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Interpretación del estado evolutivo',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}



