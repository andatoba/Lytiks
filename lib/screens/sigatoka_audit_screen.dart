import '../services/sigatoka_audit_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../services/sigatoka_audit_service.dart';
import '../services/sync_service.dart';
import '../services/offline_storage_service.dart';
import '../services/client_service.dart';

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

  // Servicios
  final SigatokaAuditService _sigatokaService = SigatokaAuditService();
  final SyncService _syncService = SyncService();
  final OfflineStorageService _offlineStorage = OfflineStorageService();
  final ClientService _clientService = ClientService();

  File? _sigatokaPhoto;
  String _selectedCrop = 'Banano';
  bool _showResults = false;

  // Parámetros básicos (0 y 10 semanas)
  final Map<String, Map<String, double?>> _basicParams = {
    'HSI': {'week0': null, 'week10': null},
    'YLS': {'week0': null, 'week10': null},
    'ILP': {'week0': null, 'week10': null},
    'ISED': {'week0': null, 'week10': null},
  };

  String _observations = '';
  String _recommendations = '';
  double? _realStover;
  double? _recommendedStover;

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
    if (widget.clientData != null) {
      _selectedClient = widget.clientData;
    }
  }

  Future<void> _initializeDatabase() async {
    try {
      await _offlineStorage.initialize();
      debugPrint(
        '✅ Base de datos inicializada correctamente en Sigatoka screen',
      );
    } catch (e) {
      debugPrint('❌ Error inicializando base de datos en Sigatoka screen: $e');
    }
  }

  @override
  void dispose() {
    _cedulaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF004B63),
        title: const Text(
          'Auditoría Sigatoka',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _showResults ? Icons.edit : Icons.analytics,
              color: Colors.white,
            ),
            onPressed: () => setState(() => _showResults = !_showResults),
          ),
        ],
      ),
      body: _showResults ? _buildResults() : _buildForm(),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildInfoCard(),
          const SizedBox(height: 16),
          _buildClientSearchSection(),
          const SizedBox(height: 16),
          _buildConfigurationCard(),
          const SizedBox(height: 16),
          _buildParametersCard(),
          const SizedBox(height: 16),
          _buildObservationsCard(),
          const SizedBox(height: 16),
          _buildActionButtons(),
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

  Widget _buildConfigurationCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.settings, color: Colors.grey[700]),
                const SizedBox(width: 8),
                const Text(
                  'Configuración de Análisis',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tipo de Cultivo:',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: DropdownButtonFormField<String>(
                    value: _selectedCrop,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Banano',
                        child: Text('🍌 Banano'),
                      ),
                      DropdownMenuItem(value: 'Palma', child: Text('🌴 Palma')),
                    ],
                    onChanged: (value) =>
                        setState(() => _selectedCrop = value!),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue[700], size: 20),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Análisis básico: Parámetros en semana 0 y 10',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParametersCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: Colors.grey[700]),
                const SizedBox(width: 8),
                const Text(
                  'Parámetros de Análisis Básico',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildBasicParameters(),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicParameters() {
    return Column(
      children: [
        const Text(
          'Ingrese los valores para las semanas 0 y 10:',
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 16),
        ..._basicParams.entries.map(
          (entry) => _buildBasicParameterRow(entry.key, entry.value),
        ),
        const SizedBox(height: 16),
        _buildStoverSection(),
      ],
    );
  }

  Widget _buildBasicParameterRow(
    String parameter,
    Map<String, double?> values,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _getParameterFullName(parameter),
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Semana 0',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      _basicParams[parameter]!['week0'] = double.tryParse(
                        value,
                      );
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Semana 10 *',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      _basicParams[parameter]!['week10'] = double.tryParse(
                        value,
                      );
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStoverSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Análisis de Stover',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Stover Real',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      _realStover = double.tryParse(value);
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Stover Recomendado',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      _recommendedStover = double.tryParse(value);
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildObservationsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.note_add, color: Colors.grey[700]),
                const SizedBox(width: 8),
                const Text(
                  'Observaciones y Evidencias',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Observaciones adicionales...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(12),
              ),
              onChanged: (value) => setState(() => _observations = value),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _tomarFotoSigatoka,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Tomar Evidencias Fotográficas'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF388E3C),
                  side: const BorderSide(color: Color(0xFF388E3C)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            if (_sigatokaPhoto != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Image.file(_sigatokaPhoto!, height: 120),
              ),
            const SizedBox(height: 12),
            TextField(
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'Recomendaciones técnicas...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(12),
              ),
              onChanged: (value) => setState(() => _recommendations = value),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _tomarFotoSigatoka() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
    );
    if (pickedFile != null) {
      // Guardar la foto con nombre único
      final directory = await Directory.systemTemp.createTemp();
      final uniqueName =
          'sigatoka_${DateTime.now().millisecondsSinceEpoch}_${pickedFile.name}';
      final newPath = '${directory.path}/$uniqueName';
      final newFile = await File(pickedFile.path).copy(newPath);
      setState(() {
        _sigatokaPhoto = File(pickedFile.path);
      });
    }
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => setState(() => _showResults = true),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF388E3C)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text(
              'Ver Análisis',
              style: TextStyle(
                color: Color(0xFF388E3C),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: _saveAudit,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF388E3C),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text(
              'Guardar Auditoría',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResults() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildResultsHeader(),
          const SizedBox(height: 16),
          _buildInterpretationCard(),
          const SizedBox(height: 16),
          _buildRecommendationsCard(),
        ],
      ),
    );
  }

  Widget _buildResultsHeader() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF388E3C),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.analytics,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Resultados del Análisis Sigatoka',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildResultMetric(
                    'Cultivo',
                    _selectedCrop,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildResultMetric(
                    'Estado',
                    _calculateOverallStatus(),
                    _getStatusColor(_calculateOverallStatus()),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultMetric(String label, String value, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInterpretationCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Interpretación de Resultados',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ..._getActiveParameters().map(
              (param) => _buildParameterInterpretation(param),
            ),
            if (_realStover != null && _recommendedStover != null)
              _buildStoverInterpretation(),
          ],
        ),
      ),
    );
  }

  Widget _buildParameterInterpretation(String parameter) {
    final level = _getParameterLevel(parameter);
    final color = _getLevelColor(level);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_getParameterFullName(parameter)}: $level',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  _getParameterRecommendation(parameter, level),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoverInterpretation() {
    final difference = (_realStover! - _recommendedStover!).abs();
    final isWithinRange = difference <= (_recommendedStover! * 0.1);

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isWithinRange
            ? Colors.green.withOpacity(0.1)
            : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isWithinRange
              ? Colors.green.withOpacity(0.3)
              : Colors.orange.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Análisis de Stover: ${isWithinRange ? 'Óptimo' : 'Requiere Ajuste'}',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            'Real: $_realStover vs Recomendado: $_recommendedStover (Diferencia: ${difference.toStringAsFixed(2)})',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recomendaciones Automáticas',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ..._generateAutomaticRecommendations().map(
              (rec) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF388E3C),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(rec, style: const TextStyle(fontSize: 14)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getParameterFullName(String param) {
    switch (param) {
      case 'HSI':
        return 'HSI (Health Status Index)';
      case 'YLS':
        return 'YLS (Youngest Leaf Spotted)';
      case 'ILP':
        return 'ILP (Index of Leaf Position)';
      case 'ISED':
        return 'ISED (Index of Severity Evolution Disease)';
      default:
        return param;
    }
  }

  List<String> _getActiveParameters() {
    return _basicParams.keys.toList();
  }

  List<double?> _getParameterData(String parameter) {
    final basicData = _basicParams[parameter]!;
    return List.generate(11, (index) {
      if (index == 0) return basicData['week0'];
      if (index == 10) return basicData['week10'];
      return null;
    });
  }

  String _getParameterLevel(String parameter) {
    final data = _getParameterData(parameter);
    final validValues = data.where((v) => v != null).map((v) => v!).toList();
    if (validValues.isEmpty) return 'Sin datos';

    final average = validValues.reduce((a, b) => a + b) / validValues.length;

    // Lógica simplificada para demostración
    if (average < 30) return 'Bajo';
    if (average < 70) return 'Medio';
    return 'Alto';
  }

  Color _getLevelColor(String level) {
    switch (level) {
      case 'Bajo':
        return Colors.green;
      case 'Medio':
        return Colors.orange;
      case 'Alto':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getParameterRecommendation(String parameter, String level) {
    switch (level) {
      case 'Bajo':
        return 'Nivel óptimo, mantener programa actual';
      case 'Medio':
        return 'Nivel moderado, monitorear de cerca';
      case 'Alto':
        return 'Nivel crítico, aplicar medidas correctivas inmediatas';
      default:
        return 'Insuficientes datos para evaluación';
    }
  }

  String _calculateOverallStatus() {
    final levels = _getActiveParameters()
        .map((p) => _getParameterLevel(p))
        .toList();
    if (levels.contains('Alto')) return 'Crítico';
    if (levels.contains('Medio')) return 'Moderado';
    if (levels.contains('Bajo')) return 'Óptimo';
    return 'Sin evaluar';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Óptimo':
        return Colors.green;
      case 'Moderado':
        return Colors.orange;
      case 'Crítico':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  List<String> _generateAutomaticRecommendations() {
    List<String> recommendations = [];

    final overallStatus = _calculateOverallStatus();

    switch (overallStatus) {
      case 'Crítico':
        recommendations.addAll([
          'Implementar aplicación foliar inmediata con fungicidas sistémicos',
          'Incrementar frecuencia de monitoreo a semanal',
          'Evaluar eficacia del programa de deshoje actual',
          'Considerar ajuste en densidad de siembra si aplica',
        ]);
        break;
      case 'Moderado':
        recommendations.addAll([
          'Mantener programa de aplicaciones preventivas',
          'Intensificar labores de deshoje sanitario',
          'Monitorear evolución quincenal',
        ]);
        break;
      case 'Óptimo':
        recommendations.addAll([
          'Continuar con programa preventivo actual',
          'Mantener monitoreo mensual',
          'Evaluar reducción gradual de aplicaciones si es sostenible',
        ]);
        break;
    }

    if (_realStover != null && _recommendedStover != null) {
      final difference = _realStover! - _recommendedStover!;
      if (difference.abs() > (_recommendedStover! * 0.1)) {
        if (difference > 0) {
          recommendations.add(
            'Reducir programa de deshoje, stover actual superior al recomendado',
          );
        } else {
          recommendations.add(
            'Incrementar programa de deshoje, stover actual inferior al recomendado',
          );
        }
      }
    }

    if (_selectedCrop == 'Banano') {
      recommendations.add(
        'Aplicar consideraciones específicas para cultivo de banano',
      );
    } else {
      recommendations.add(
        'Aplicar consideraciones específicas para cultivo de palma',
      );
    }

    return recommendations;
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

    // Mostrar indicador de carga
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

      // Cerrar diálogo de carga
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
            content: Text('No se encontró ningún cliente con esta cédula'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // Cerrar diálogo de carga si hay error
      Navigator.of(context).pop();

      String errorMessage = 'Error al buscar cliente';
      if (e.toString().contains('Failed to fetch') ||
          e.toString().contains('Error de conexión')) {
        errorMessage =
            'No se pudo conectar con el servidor. Por favor:\n'
            '1. Verifique su conexión a internet\n'
            '2. Compruebe que el servidor esté en línea\n'
            '3. Intente nuevamente en unos momentos';
      } else {
        errorMessage = 'Error al buscar cliente: $e';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    }
  }

  void _saveAudit() async {
    // Verificar que haya un cliente seleccionado
    if (_selectedClient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Debe seleccionar un cliente antes de guardar la auditoría.',
          ),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    // Validar campos obligatorios
    if (_selectedCrop.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe seleccionar un cultivo'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validar que la cédula esté presente
    if (!_selectedClient!.containsKey('cedula') ||
        _selectedClient!['cedula'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cliente sin cédula válida'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Mostrar indicador de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Guardando auditoría Sigatoka...'),
            ],
          ),
        ),
      );

      // Preparar datos de la auditoría
      final Map<String, dynamic> sigatokaData = {
        'nivelAnalisis': 'Básico',
        'tipoCultivo': _selectedCrop,
        'hacienda': _selectedClient!['hacienda'] ?? 'Hacienda Principal',
        'lote': 'Lote 1',
        'tecnicoId': 1,
        'observaciones': _observations,
        'recomendaciones': _recommendations,
        'stoverReal': _realStover,
        'stoverRecomendado': _recommendedStover,
        'estadoGeneral': _calculateOverallStatus(),
        'basicParams': _basicParams,
        'cedulaCliente': _selectedClient!['cedula'],
        'clienteId': _selectedClient!['id'],
        'fecha': DateTime.now().toIso8601String(),
      };

      // 1. Guardar en SQLite primero (siempre)
      final localId = await _offlineStorage.savePendingSigatokaAudit(
        clientId: _selectedClient!['id'],
        cedulaCliente: _selectedClient!['cedula'],
        auditDate: DateTime.now().toIso8601String(),
        status: 'COMPLETADA',
        sigatokaData: sigatokaData,
        observations: _observations,
        recommendations: _recommendations,
        nivelAnalisis: 'Básico',
        tipoCultivo: _selectedCrop,
        hacienda: _selectedClient!['hacienda'] ?? 'Hacienda Principal',
        lote: 'Lote 1',
      );

      // 2. Verificar conexión y sincronizar si es posible
      final hasConnection = await _syncService.hasInternetConnection();

      String message;
      if (hasConnection) {
        try {
          // Intentar subir inmediatamente
          final result = await _sigatokaService.createSigatokaAudit(
            nivelAnalisis: 'Básico',
            tipoCultivo: _selectedCrop,
            hacienda: _selectedClient!['hacienda'] ?? 'Hacienda Principal',
            lote: 'Lote 1',
            tecnicoId: 1,
            observaciones: _observations,
            recomendaciones: _recommendations,
            stoverReal: _realStover,
            stoverRecomendado: _recommendedStover,
            estadoGeneral: _calculateOverallStatus(),
            basicParams: _basicParams,
            cedulaCliente: _selectedClient!['cedula'],
          );

          if (result['success'] == true) {
            // Marcar como sincronizado en SQLite
            await _offlineStorage.markSigatokaAuditAsSynced(localId);
            message =
                'Auditoría Sigatoka guardada y sincronizada exitosamente.';
          } else {
            message =
                'Auditoría guardada localmente. Se sincronizará cuando haya conexión estable.';
          }
        } catch (e) {
          message =
              'Auditoría guardada localmente. Error en sincronización: ${e.toString()}';
        }
      } else {
        message =
            'Auditoría guardada localmente. Sin conexión a internet. Se sincronizará automáticamente cuando haya conexión.';
      }

      // Cerrar indicador de carga
      Navigator.of(context).pop();

      // Mostrar resultado
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Auditoría Guardada'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar diálogo
                Navigator.of(context).pop(); // Volver a la pantalla anterior
              },
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );
    } catch (e) {
      // Cerrar indicador de carga si está abierto
      Navigator.of(context).pop();

      // Mostrar error
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text('Error al guardar la auditoría: ${e.toString()}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );
    }
  }
}
