import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import '../utils/lytiks_utils.dart';
import '../services/offline_storage_service.dart';
import '../services/audit_service.dart';

class AuditScreen extends StatefulWidget {
  const AuditScreen({super.key});

  @override
  State<AuditScreen> createState() => _AuditScreenState();
}

class _AuditScreenState extends State<AuditScreen> {
  // Servicios para auditoría de campo
  final OfflineStorageService _offlineStorageCampo = OfflineStorageService();
  // TODO: Agregar aquí el servicio de sincronización de auditoría de campo si existe (por ejemplo, AuditSyncService)
  Future<void> _guardarAuditoriaCampo(
    int completedItems,
    int totalItems,
    int totalScore,
    int maxPossibleScore,
  ) async {
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
              Text('Guardando auditoría...'),
            ],
          ),
        ),
      );

      // Preparar datos de la auditoría de campo
      final List<Map<String, dynamic>> details = [];
      for (final section in _auditSections.entries) {
        final sectionName = section.key;
        final items = section.value;
        for (final item in items) {
          if (item.rating != null) {
            details.add({
              'section': sectionName,
              'item': item.name,
              'maxScore': item.maxScore,
              'rating': item.rating,
              'calculatedScore': item.calculatedScore ?? 0,
              'photoBase64': item.photoPath != null
                  ? base64Encode(File(item.photoPath!).readAsBytesSync())
                  : null,
            });
          }
        }
      }

      // Guardar en SQLite primero (tabla pending_audits)
      final int clientId = 1; // TODO: Reemplazar con el ID real del cliente
      final int categoryId =
          1; // TODO: Reemplazar con el ID real de la categoría
      await _offlineStorageCampo.savePendingAudit(
        clientId: clientId,
        categoryId: categoryId,
        auditDate: DateTime.now().toIso8601String(),
        status: 'COMPLETADA',
        auditData: details,
        observations: null,
        latitude: null,
        longitude: null,
        imagePath: null,
      );

      // Intentar sincronizar con backend solo si hay internet
      final auditService = AuditService();
      final String hacienda = 'Hacienda Demo';
      final String cultivo = _selectedCrop;
      final String fecha = DateTime.now().toIso8601String();
      final int tecnicoId = 1;
      final String estado = 'COMPLETADA';
      final String? observaciones = null;
      final scores = AuditService.buildBackendScores(details);

      bool hayInternet = false;
      try {
        hayInternet = await auditService.testConnection();
      } catch (_) {
        hayInternet = false;
      }

      String mensaje;
      if (hayInternet) {
        try {
          await auditService.createAuditBackend(
            hacienda: hacienda,
            cultivo: cultivo,
            fecha: fecha,
            tecnicoId: tecnicoId,
            estado: estado,
            observaciones: observaciones,
            scores: scores,
          );
          mensaje = 'Auditoría guardada y sincronizada exitosamente.';
        } catch (e) {
          mensaje =
              'Auditoría guardada localmente, se sincronizará cuando haya conexión estable.';
        }
      } else {
        mensaje =
            'Auditoría guardada localmente, se sincronizará cuando haya conexión estable.';
      }

      // Cerrar indicador de carga
      Navigator.of(context).pop();

      // Mostrar resultado
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Auditoría Guardada'),
          content: Text(mensaje),
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
    } catch (e) {
      Navigator.of(context).pop();
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

  final ImagePicker _picker = ImagePicker();
  bool _isBasicMode = true; // true para básica, false para completa
  String _selectedCrop =
      'banano'; // tipo de cultivo seleccionado: 'banano' o 'palma'

  // Estructura de datos para los elementos de evaluación (mismo para ambos cultivos)
  final Map<String, List<AuditItem>> _auditSections = {
    'ENFUNDE': [
      AuditItem('ATRASO DE LABOR E MAL IDENTIFICACION', 20),
      AuditItem('RETOLDEO', 20),
      AuditItem('CIRUGIA, SE ENCUENTRAN MELLIZOS', 20),
      AuditItem('FALTA DE PROTECTORES Y/O MAL COLOCADO', 20),
      AuditItem('SACUDIR BRACTEAS 2DA SUBIDA Y 3RA SUBIDA AL RACIMO', 20),
    ],
    'SELECCION': [
      AuditItem('MALA DISTRIBUCION Y/O DEJA PLANTAS SIN SELECTAR', 20),
      AuditItem('MALA SELECCION DE HIJOS', 20),
      AuditItem('DOBLE EN EXCESO', 20),
      AuditItem('MAL CANCELADOS', 20),
      AuditItem('NO GENERA DOBLES PERIFERICOS', 20),
    ],
    'COSECHA': [
      AuditItem('FFE + FFI (6,01% a 7,99%)', 10),
      AuditItem('FFE + FFI (8 a 9%)', 15),
      AuditItem('FFE+FFI (=>9,01%)', 20),
      AuditItem('NO SE LLEVA PARCELA DE CALIBRACION', 15),
      AuditItem(
        'LIBRO DE AR (LLEVA REGISTRO DIARIO DE LOTES COSECHADOS) PLANIFICACION DE COSECHA',
        20,
      ),
      AuditItem(
        'LOTES CON FRECUENCIA MAYOR A 5 DÍAS / MAL PLANIFICACION DE COSECHA',
        20,
      ),
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
      AuditItem('DEJAN CODOS', 25),
    ],
    'DESVIO DE HIJOS': [
      AuditItem('SIN DESVIAR', 50),
      AuditItem('HIJOS MALTRATADOS', 50),
    ],
    'APUNTALAMIENTO CON SUNCHOT': [
      AuditItem('ZUNCHO FLOJO Y/O MAL ANGULO MAL COLOCADO', 25),
      AuditItem(
        'MATAS CAIDAS MAYOR A 3%  DEL ENFUNDE PROMEDIO SEMANAL DEL LOTE',
        25,
      ),
      AuditItem(
        'UTILIZA ESTAQUILLA PARA MEJORAR ANGULO DENTRO DE LA PLANTACION Y CABLE VIA',
        25,
      ),
      AuditItem('AMARRE EN HIJOS Y/O EN PLANTAS CON RACIMOS +9 SEM', 25),
    ],
    'APUNTALAMIENTO CON PUNTAL': [
      AuditItem('PUNTAL FLOJO Y/O MAL ANGULO', 20),
      AuditItem(
        'MATAS CAIDAS MAYOR A 3% DEL ENFUNDE PROMEDIO SEMANAL DEL LOTE',
        20,
      ),
      AuditItem('UN PUNTAL', 20),
      AuditItem('PUNTAL ROZANDO RACIMO Y/O DAÑA PARTE BASAL DE LA HOJA', 20),
      AuditItem('PUNTAL PODRIDO', 20),
    ],
    'MANEJO DE AGUAS (RIEGO)': [
      AuditItem('SATURACION DE AREA SIN CAPACIDAD DE CAMPO', 20),
      AuditItem('CUMPLIMIENTO DE TURNOS DE RIEGO ', 20),
      AuditItem('SE OBSERVAN TRIANGULO SECOS', 15),
      AuditItem('SE OBSERVAN FUGAS', 15),
      AuditItem('FALTA DE ASPERSORES', 15),
      AuditItem('PRESION INADEUADA (ALTA O BAJA)', 15),
    ],
    'MANEJO DE AGUAS (DRENAJE)': [
      AuditItem('AGUAS RETENIDAS', 35),
      AuditItem('CANALES SUCIOS', 35),
      AuditItem('ENCHARCAMIENTO POR FALTA DE DRENAJE', 30),
    ],
  };

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
                    'Auditoría',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF004B63),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Text(
                            'Básica',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: _isBasicMode
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: _isBasicMode
                                  ? const Color(0xFF004B63)
                                  : Colors.grey,
                            ),
                            overflow: TextOverflow.ellipsis,
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
                        Expanded(
                          child: Text(
                            'Completa',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: !_isBasicMode
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: !_isBasicMode
                                  ? const Color(0xFF004B63)
                                  : Colors.grey,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
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
                  ' Ver Resumen y Guardar',
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
                    DropdownMenuItem(value: 'Alto', child: Text('Alto (30)')),
                    DropdownMenuItem(value: 'Medio', child: Text('Medio (50)')),
                    DropdownMenuItem(value: 'Bajo', child: Text('Bajo (100)')),
                  ],
                  onChanged: item.isLocked
                      ? null
                      : (value) {
                          setState(() {
                            item.rating = value;
                            // Invertir lógica: 'Bajo' es el puntaje más alto, 'Alto' el más bajo
                            switch (value) {
                              case 'Alto':
                                item.calculatedScore = (item.maxScore * 0.3)
                                    .round();
                                break;
                              case 'Medio':
                                item.calculatedScore = (item.maxScore * 0.5)
                                    .round();
                                break;
                              case 'Bajo':
                                item.calculatedScore = item.maxScore;
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
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.assignment_turned_in,
                    color: const Color(0xFF004B63),
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Resumen de Auditoría',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF004B63),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Completaste $completedItems de $totalItems evaluaciones.',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Puntuación total: $totalScore / $maxPossibleScore',
                style: const TextStyle(fontSize: 15, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 180,
                child: SingleChildScrollView(
                  child: Column(
                    children: sectionScores.entries.map((entry) {
                      final section = entry.value;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                _getSectionDisplayName(entry.key),
                                style: const TextStyle(fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                '${section['score']} / ${section['maxScore']}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 1,
                              child: Text(
                                '${(section['percentage'] as double).toStringAsFixed(1)}%',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: (section['percentage'] as double) >= 80
                                      ? Colors.green
                                      : (section['percentage'] as double) >= 60
                                      ? Colors.orange
                                      : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Editar',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _guardarAuditoriaCampo(
                        completedItems,
                        totalItems,
                        totalScore,
                        maxPossibleScore,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF004B63),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Guardar auditoria',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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
