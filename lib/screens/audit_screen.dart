import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../utils/lytiks_utils.dart';
import '../services/offline_storage_service.dart';

class AuditScreen extends StatefulWidget {
  const AuditScreen({super.key});

  @override
  State<AuditScreen> createState() => _AuditScreenState();
}

class _AuditScreenState extends State<AuditScreen> {
  final ImagePicker _picker = ImagePicker();
  final OfflineStorageService _offlineStorage = OfflineStorageService();
  bool _isBasicMode = true; // true para básica, false para completa
  String _selectedCrop =
      'banano'; // tipo de cultivo seleccionado: 'banano' o 'palma'

  // Estructura de datos para los elementos de evaluación (mismo para ambos cultivos)
  final Map<String, List<AuditItem>> _auditSections = {
    'ENFUNDE': [
      AuditItem('IDENTIFICACION', 20),
      AuditItem('RETOLDEO', 20),
      AuditItem('CIRUGIA, SE ENCUENTRAN MELLIZOS', 20),
      AuditItem('FALTA DE PROTECTORES Y/O MAL COLOCADO', 20),
      AuditItem('SACUDIDO BRACTEAS 2DA SUBIDA Y 3RA PICADA', 20),
    ],
    'SELECCION': [
      AuditItem('MALA DISTRIBUCION Y/O DEJA PLANTAS SIN SELECCIONAR', 20),
      AuditItem('MALA SELECCION DE HIJOS DOBLE EN EXCESO', 20),
      AuditItem('MAL CANCELADOS', 20),
      AuditItem('NO GENERA DOBLES', 20),
    ],
    'COSECHA': [
      AuditItem('FFE + FF(16.0% a 7.33%)', 10),
      AuditItem('FFE + FF(16 a 3%)', 15),
      AuditItem('FFE+FF(13.0 a 0%)', 20),
      AuditItem('NO SE LLEVA PARCELA DE CALIBRACION', 15),
      AuditItem('COSECHA OJOS', 5),
      AuditItem('DIARIO DE LOTES', 20),
      AuditItem('COSECHA(LIJOS) PLANIFICACION', 5),
      AuditItem('LOTES CON FRECUENCIA', 5),
      AuditItem('MAYOR A 8 DIAS', 20),
      AuditItem('PLANIFICACION DE COSECHA', 5),
    ],
    'DESHOJE FITOSANITARIO': [
      AuditItem('TEJIDO NECROTICO SIN CORTAR', 40),
      AuditItem('ELIMINAR TEJIDO VERDE Y/O CON ESTRÍAS', 30),
      AuditItem('LA LONGITUD DE LA PALANCA NO ES LA CORRECTA', 30),
    ],
    'DESHOJE NORMAL': [
      AuditItem('HOJA TOCANDO RACIMO Y/O HOJA PUENTE SIN CORTAR', 25),
      AuditItem('ELIMINA HOJAS VERDES', 25),
      AuditItem('DEJA HOJA BAJERA', 25),
      AuditItem('DEJAN COGOLLOS', 25),
    ],
    'DESHIJE': [
      AuditItem('SIN DESVIAR', 50),
      AuditItem('HIJOS MALTRATADOS', 50),
    ],
    'APLICACION PUNTO CON SUCONT': [
      AuditItem('ZUNCHO FLOJO Y/O MAL ANGULO MAL COLOCADO', 25),
      AuditItem('MATAS CAIDAS MAYOR A 3%', 25),
      AuditItem('DEL ENFUNDE PROMEDIO SEMANAL DEL LOTE', 25),
      AuditItem(
        'UTILIZA ESTAQUILLA PARA MEJORAR ANGULO DENT PUEDE LA PLANTACION CARALLE VIA AMARRE EN HIJOS Y/O EN PLANTAS CON ANGULO',
        25,
      ),
    ],
    'APUNTEO CON SUCONT': [
      AuditItem('PUNTAL FLOJO Y/O MAL ANGULO', 20),
      AuditItem('MATAS CAIDAS MAYOR A 3%', 20),
      AuditItem('DEL ENFUNDE PROMEDIO SEMANAL DEL LOTE', 20),
      AuditItem(
        'PUNTAL RECICLADO PACIMO Y/O DAÑA PARTE BASAL DE LA PLANTA  PUNTAL',
        20,
      ),
    ],
    'DRENAJE': [
      AuditItem('SATURACION DE AREA SIN CAPACIDAD DE CAMPO', 20),
      AuditItem('CUMPLIMIENTO DE METROS DE DREN', 20),
      AuditItem('SE OBSERVAN TRIANGULO', 15),
      AuditItem('SE OBSERVAN TORDOS', 15),
      AuditItem('FALTA DE ASPERSORES', 15),
      AuditItem('PRECISION EN APLICACION DE AZUFRE (DAJA)', 15),
    ],
    'MANEJO DE MALEZAS': [
      AuditItem('AGUAS RETENIDAS', 35),
      AuditItem('CANALES SUCIOS', 35),
      AuditItem('ENCHARCAMIENTO POR FALTA DE DRENAJE', 30),
    ],
  };

  Future<void> _saveAudit() async {
    try {
      // Crear la data de la auditoría
      final List<Map<String, dynamic>> auditData = [];

      for (final section in _auditSections.entries) {
        final sectionName = section.key;
        final items = section.value;

        for (final item in items) {
          if (item.rating != null) {
            auditData.add({
              'section': sectionName,
              'item': item.name,
              'maxScore': item.maxScore,
              'rating': item.rating,
              'calculatedScore': item.calculatedScore ?? 0,
              'photoPath': item.photoPath,
            });
          }
        }
      }

      if (auditData.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No hay elementos evaluados para guardar'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Guardar en almacenamiento offline
      await _offlineStorage.savePendingAudit(
        clientId: 1, // Por ahora hardcoded, debería venir de la selección
        categoryId: _selectedCrop == 'banano' ? 1 : 2,
        auditDate: DateTime.now().toIso8601String(),
        status: 'COMPLETED',
        auditData: auditData,
        observations:
            'Auditoría de ${_selectedCrop.toUpperCase()} - Modo ${_isBasicMode ? 'Básico' : 'Completo'}',
      );

      // Mostrar confirmación
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Auditoría guardada exitosamente'),
          backgroundColor: Colors.green,
        ),
      );

      // Volver al home
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar auditoría: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Auditoría de Campo'),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _selectedCrop.toUpperCase(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF004B63),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Switch para modo básico/completo
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF004B63)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Modo de Auditoría',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF004B63),
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        'Básica',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: _isBasicMode
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: _isBasicMode
                              ? const Color(0xFF004B63)
                              : Colors.grey,
                        ),
                      ),
                      Switch(
                        value: !_isBasicMode,
                        onChanged: (value) {
                          setState(() {
                            _isBasicMode = !value;
                          });
                        },
                        activeColor: const Color(0xFF004B63),
                        activeTrackColor: const Color(
                          0xFF004B63,
                        ).withOpacity(0.3),
                        inactiveThumbColor: Colors.grey,
                        inactiveTrackColor: Colors.grey.withOpacity(0.3),
                      ),
                      Text(
                        'Completa',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: !_isBasicMode
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: !_isBasicMode
                              ? const Color(0xFF004B63)
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Selector de cultivo
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF004B63)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Seleccionar Cultivo',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF004B63),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCrop = 'banano';
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _selectedCrop == 'banano'
                                  ? const Color(0xFF004B63)
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _selectedCrop == 'banano'
                                    ? const Color(0xFF004B63)
                                    : Colors.grey.shade300,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.agriculture,
                                  color: _selectedCrop == 'banano'
                                      ? Colors.white
                                      : Colors.grey.shade600,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'BANANO',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _selectedCrop == 'banano'
                                        ? Colors.white
                                        : Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCrop = 'palma';
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _selectedCrop == 'palma'
                                  ? const Color(0xFF004B63)
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _selectedCrop == 'palma'
                                    ? const Color(0xFF004B63)
                                    : Colors.grey.shade300,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.park,
                                  color: _selectedCrop == 'palma'
                                      ? Colors.white
                                      : Colors.grey.shade600,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'PALMA',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _selectedCrop == 'palma'
                                        ? Colors.white
                                        : Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Información del modo
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF004B63).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF004B63)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cultivo: ${_selectedCrop.toUpperCase()} - Modo: ${_isBasicMode ? "Evaluación Básica" : "Evaluación Completa"}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF004B63),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isBasicMode
                        ? 'Relleno parcial de parámetros principales para ${_selectedCrop}'
                        : 'Relleno total de todos los parámetros de evaluación para ${_selectedCrop}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Secciones de evaluación
            ..._auditSections.entries
                .map((entry) => _buildAuditSection(entry.key, entry.value))
                .toList(),

            const SizedBox(height: 20),

            // Botón para guardar resultados
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveAuditResults,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF004B63),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Finalizar Auditoría',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuditSection(String sectionTitle, List<AuditItem> items) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título de la sección
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF004B63),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                sectionTitle,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),

            // Items de evaluación
            ...items.map((item) => _buildAuditItem(item)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAuditItem(AuditItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nombre del item
          Text(
            item.name,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),

          // Puntuación máxima
          Text(
            'Puntuación máxima: ${item.maxScore}',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              // Botón de cámara
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: () => _takePhoto(item),
                  icon: const Icon(Icons.camera_alt, size: 16),
                  label: Text(
                    item.photoPath != null ? 'Foto tomada' : 'Tomar foto',
                    style: const TextStyle(fontSize: 12),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: item.photoPath != null
                        ? LytiksUtils.successColor
                        : LytiksUtils.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Dropdown de calificación
              Expanded(
                flex: 3,
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Calificación',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                  ),
                  initialValue: item.rating,
                  items: const [
                    DropdownMenuItem(value: 'Alto', child: Text('Alto (100)')),
                    DropdownMenuItem(value: 'Medio', child: Text('Medio (50)')),
                    DropdownMenuItem(value: 'Bajo', child: Text('Bajo (30)')),
                  ],
                  onChanged: item.isLocked
                      ? null
                      : (value) {
                          setState(() {
                            item.rating = value;
                            // Calcular puntuación automática
                            switch (value) {
                              case 'Alto':
                                item.calculatedScore = item.maxScore;
                                break;
                              case 'Medio':
                                item.calculatedScore = (item.maxScore * 0.5)
                                    .round();
                                break;
                              case 'Bajo':
                                item.calculatedScore = (item.maxScore * 0.3)
                                    .round();
                                break;
                            }
                          });
                        },
                ),
              ),
            ],
          ),

          if (item.calculatedScore != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getScoreColor(item.calculatedScore!, item.maxScore),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Puntuación: ${item.calculatedScore}/${item.maxScore}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],

          if (item.photoPath != null) ...[
            const SizedBox(height: 8),
            Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(File(item.photoPath!), fit: BoxFit.cover),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getScoreColor(int score, int maxScore) {
    double percentage = (score / maxScore) * 100;
    return LytiksUtils.getScoreColor(percentage);
  }

  Future<void> _takePhoto(AuditItem item) async {
    if (item.isLocked) return;

    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (photo != null) {
        setState(() {
          item.photoPath = photo.path;
        });

        LytiksUtils.showSuccessSnackBar(context, 'Foto capturada exitosamente');
      }
    } catch (e) {
      LytiksUtils.showErrorSnackBar(context, 'Error al tomar la foto: $e');
    }
  }

  void _saveAuditResults() {
    // Verificar que todas las evaluaciones tengan foto y calificación
    bool allComplete = true;
    int totalItems = 0;
    int completedItems = 0;

    for (var section in _auditSections.values) {
      for (var item in section) {
        totalItems++;
        if (item.photoPath != null && item.rating != null) {
          completedItems++;
        } else {
          allComplete = false;
        }
      }
    }

    if (_isBasicMode) {
      // En modo básico, permitir guardar con evaluación parcial
      if (completedItems == 0) {
        LytiksUtils.showWarningSnackBar(
          context,
          'Debe completar al menos una evaluación',
        );
        return;
      }
    } else {
      // En modo completo, requerir todas las evaluaciones
      if (!allComplete) {
        LytiksUtils.showWarningSnackBar(
          context,
          'Debe completar todas las evaluaciones ($completedItems/$totalItems)',
        );
        return;
      }
    }

    // Bloquear resultados después de guardar
    setState(() {
      for (var section in _auditSections.values) {
        for (var item in section) {
          if (item.photoPath != null && item.rating != null) {
            item.isLocked = true;
          }
        }
      }
    });

    // Calcular puntuación total
    int totalScore = 0;
    int maxPossibleScore = 0;

    for (var section in _auditSections.values) {
      for (var item in section) {
        maxPossibleScore += item.maxScore;
        if (item.calculatedScore != null) {
          totalScore += item.calculatedScore!;
        }
      }
    }

    _showAuditSummary(completedItems, totalItems, totalScore, maxPossibleScore);
  }

  void _showAuditSummary(
    int completedItems,
    int totalItems,
    int totalScore,
    int maxPossibleScore,
  ) {
    // Calcular puntuaciones por sección
    Map<String, Map<String, dynamic>> sectionScores = {};

    for (var entry in _auditSections.entries) {
      String sectionName = entry.key;
      List<AuditItem> items = entry.value;

      int sectionTotal = 0;
      int sectionMax = 0;
      int sectionCompleted = 0;

      for (var item in items) {
        sectionMax += item.maxScore;
        if (item.calculatedScore != null) {
          sectionTotal += item.calculatedScore!;
          sectionCompleted++;
        }
      }

      sectionScores[sectionName] = {
        'score': sectionTotal,
        'maxScore': sectionMax,
        'completed': sectionCompleted,
        'total': items.length,
        'percentage': sectionMax > 0 ? (sectionTotal / sectionMax * 100) : 0.0,
      };
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.assignment_turned_in, color: const Color(0xFF004B63)),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Resumen de Auditoría',
                style: TextStyle(
                  color: Color(0xFF004B63),
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.9,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Información general
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF004B63).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Flexible(
                            child: Text(
                              'Hacienda:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Flexible(
                            child: Text(
                              'FINCA MODELO',
                              style: TextStyle(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Flexible(
                            child: Text(
                              'Cultivo:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Flexible(
                            child: Text(
                              _selectedCrop.toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF004B63),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Flexible(
                            child: Text(
                              'Fecha:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Flexible(
                            child: Text(
                              '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Flexible(
                            child: Text(
                              'Evaluaciones:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Flexible(
                            child: Text(
                              '$completedItems/$totalItems',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Título de la tabla
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            color: Color(
                              0xFFFFD700,
                            ), // Amarillo como en la imagen
                            border: Border(
                              top: BorderSide(color: Colors.black, width: 2),
                              left: BorderSide(color: Colors.black, width: 2),
                              bottom: BorderSide(color: Colors.black, width: 1),
                              right: BorderSide(color: Colors.black, width: 1),
                            ),
                          ),
                          child: const Text(
                            'Calificación de Labor',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.visible,
                            softWrap: true,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            color: Color(
                              0xFFFFD700,
                            ), // Amarillo como en la imagen
                            border: Border(
                              top: BorderSide(color: Colors.black, width: 2),
                              right: BorderSide(color: Colors.black, width: 2),
                              bottom: BorderSide(color: Colors.black, width: 1),
                              left: BorderSide(color: Colors.black, width: 1),
                            ),
                          ),
                          child: const Text(
                            'Hacienda',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.visible,
                            softWrap: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Lista de calificaciones por sección
                SizedBox(
                  height: 300,
                  child: SingleChildScrollView(
                    child: Column(
                      children: sectionScores.entries.map((entry) {
                        String sectionName = _getSectionDisplayName(entry.key);
                        var data = entry.value;

                        return Container(
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    border: const Border(
                                      left: BorderSide(
                                        color: Colors.black,
                                        width: 2,
                                      ),
                                      right: BorderSide(
                                        color: Colors.black,
                                        width: 1,
                                      ),
                                      bottom: BorderSide(
                                        color: Colors.black,
                                        width: 1,
                                      ),
                                    ),
                                    color: data['completed'] > 0
                                        ? Colors.white
                                        : Colors.grey.shade200,
                                  ),
                                  child: Text(
                                    sectionName,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: data['completed'] > 0
                                          ? Colors.black
                                          : Colors.grey,
                                    ),
                                    overflow: TextOverflow.visible,
                                    softWrap: true,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    border: const Border(
                                      right: BorderSide(
                                        color: Colors.black,
                                        width: 2,
                                      ),
                                      left: BorderSide(
                                        color: Colors.black,
                                        width: 1,
                                      ),
                                      bottom: BorderSide(
                                        color: Colors.black,
                                        width: 1,
                                      ),
                                    ),
                                    color: data['completed'] > 0
                                        ? (data['percentage'] >= 80
                                              ? Colors.green.shade50
                                              : Colors.white)
                                        : Colors.grey.shade200,
                                  ),
                                  child: Text(
                                    data['completed'] > 0
                                        ? '${data['percentage'].toStringAsFixed(0)}'
                                        : '-',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: data['completed'] > 0
                                          ? (data['percentage'] >= 80
                                                ? Colors.green.shade800
                                                : Colors.black)
                                          : Colors.grey,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Resumen final
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF004B63),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'CALIFICACIÓN GENERAL - ${_selectedCrop.toUpperCase()}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${((totalScore / maxPossibleScore) * 100).toStringAsFixed(1)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                      Text(
                        '$totalScore de $maxPossibleScore puntos',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Botón para guardar auditoría
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _saveAudit,
                    icon: const Icon(Icons.save),
                    label: const Text('Guardar Auditoría'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF004B63),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Continuar Editando',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Volver al home
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF004B63),
              foregroundColor: Colors.white,
            ),
            child: const Text('Finalizar Auditoría'),
          ),
        ],
      ),
    );
  }

  String _getSectionDisplayName(String sectionKey) {
    switch (sectionKey) {
      case 'ENFUNDE':
        return 'Enfunde';
      case 'SELECCION':
        return 'Selección';
      case 'COSECHA':
        return 'Cosecha';
      case 'DESHOJE NORMAL':
        return 'Deshoje normal';
      case 'DESHOJE FITOSANITARIO':
        return 'Deshoje Fitosantario';
      case 'DESHIJE':
        return 'Desvío de hijos';
      case 'APLICACION PUNTO CON SUCONT':
        return 'Apuntalamiento';
      case 'APUNTEO CON SUCONT':
        return 'Apunteo con Sucont';
      case 'DRENAJE':
        return 'Manejo de aguas';
      case 'MANEJO DE MALEZAS':
        return 'Manejo de Malezas';
      default:
        return sectionKey;
    }
  }
}

class AuditItem {
  final String name;
  final int maxScore;
  String? rating;
  int? calculatedScore;
  String? photoPath;
  bool isLocked;

  AuditItem(this.name, this.maxScore) : isLocked = false;
}
