import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class SigatokaAuditScreen extends StatefulWidget {
  final Map<String, dynamic>? clientData;

  const SigatokaAuditScreen({super.key, this.clientData});

  @override
  State<SigatokaAuditScreen> createState() => _SigatokaAuditScreenState();
}

class _SigatokaAuditScreenState extends State<SigatokaAuditScreen> {
  File? _sigatokaPhoto;
  String? _sigatokaPhotoPath;
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
      setState(() {
        _sigatokaPhoto = File(pickedFile.path);
        _sigatokaPhotoPath = pickedFile.path;
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

  void _saveAudit() {
    // Usar las variables para evitar warnings
    final auditData = {
      'crop': _selectedCrop,
      'observations': _observations,
      'recommendations': _recommendations,
      'realStover': _realStover,
      'recommendedStover': _recommendedStover,
      'basicParams': _basicParams,
    };

    // TODO: Implementar guardado real en base de datos
    print('Guardando auditoría Sigatoka: $auditData');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Auditoría Guardada'),
        content: const Text(
          'La auditoría de Sigatoka ha sido guardada exitosamente.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }
}
