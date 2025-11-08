import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';

import 'package:flutter/material.dart';
import '../services/sync_service.dart';
import '../services/moko_audit_service.dart';
import '../services/offline_storage_service.dart';

class MokoAuditScreen extends StatefulWidget {
  final Map<String, dynamic>? clientData;

  const MokoAuditScreen({super.key, this.clientData});

  @override
  State<MokoAuditScreen> createState() => _MokoAuditScreenState();
}

class _MokoAuditScreenState extends State<MokoAuditScreen> {
  bool? controlMaleza;
  bool? riegoEstructurado;
  bool? entradaUnica;
  bool? noMaleza;
  bool? pediluvios;
  bool? solucionesDesinfectantes;
  bool? analisisMicrobiologico;
  String observacionesAuditoria = '';
  String seguimientoAreas = '';
  bool _mostrarResumen = false;

  // Servicios
  final SyncService _syncService = SyncService();
  final MokoAuditService _mokoAuditService = MokoAuditService();
  final OfflineStorageService _offlineStorage = OfflineStorageService();

  File? _mokoPhotoObservaciones;
  String? _mokoPhotoPathObservaciones;
  File? _mokoPhotoSeguimiento;
  String? _mokoPhotoPathSeguimiento;

  // Base64 de las fotos
  String? _mokoPhotoBase64Observaciones;
  String? _mokoPhotoBase64Seguimiento;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF004B63),
        title: const Text(
          'Auditoría Moko',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _mostrarResumen ? _buildResumen() : _buildFormulario(),
    );
  }

  Widget _buildFormulario() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildInfoMoko(),
          const SizedBox(height: 20),
          _buildTitulo('PROGRAMA DE MANEJO'),
          _buildPreguntaSiNo(
            'Control de maleza',
            controlMaleza,
            (v) => setState(() => controlMaleza = v),
          ),
          _buildPreguntaSiNo(
            'Riego estructurado',
            riegoEstructurado,
            (v) => setState(() => riegoEstructurado = v),
          ),
          _buildPreguntaSiNo(
            'Entrada única',
            entradaUnica,
            (v) => setState(() => entradaUnica = v),
          ),
          _buildPreguntaSiNo(
            'Tiene maleza',
            noMaleza,
            (v) => setState(() => noMaleza = v),
          ),
          _buildPreguntaSiNo(
            'Pediluvios',
            pediluvios,
            (v) => setState(() => pediluvios = v),
          ),
          _buildPreguntaSiNo(
            'Soluciones desinfectantes',
            solucionesDesinfectantes,
            (v) => setState(() => solucionesDesinfectantes = v),
          ),
          const SizedBox(height: 24),
          _buildTitulo('LABORES DENTRO DEL MOKO'),
          _buildPreguntaSiNo(
            'Análisis microbiológico',
            analisisMicrobiologico,
            (v) => setState(() => analisisMicrobiologico = v),
          ),
          _buildCampoTextoConFoto(
            'Observaciones auditoría',
            observacionesAuditoria,
            (v) => setState(() => observacionesAuditoria = v),
            _mokoPhotoObservaciones,
            () => _tomarFotoMoko('observaciones'),
          ),
          _buildCampoTextoConFoto(
            'Seguimiento áreas',
            seguimientoAreas,
            (v) => setState(() => seguimientoAreas = v),
            _mokoPhotoSeguimiento,
            () => _tomarFotoMoko('seguimiento'),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => setState(() => _mostrarResumen = true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF004B63),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Ver Resumen y Guardar',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoMoko() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF006A7A), Color(0xFF004B63)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
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
            child: const Icon(
              Icons.biotech_outlined,
              color: Color(0xFF004B63),
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Control de Moko',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Evaluación de medidas\npreventivas y control',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                SizedBox(height: 8),
                Text(
                  'El Moko es una enfermedad bacteriana que afecta\nlas plantaciones de banano. Esta auditoría evalúa\nlas medidas de prevención y control implementadas.',
                  style: TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumen() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    spreadRadius: 2,
                    blurRadius: 8,
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF004B63),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.summarize,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Resumen de Auditoría Moko',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF004B63),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildSeccionResumen('PROGRAMA DE MANEJO'),
                    _buildItemResumen('Control de maleza', controlMaleza),
                    _buildItemResumen('Riego estructurado', riegoEstructurado),
                    _buildItemResumen('Entrada única', entradaUnica),
                    _buildItemResumen('Tiene maleza', noMaleza),
                    _buildItemResumen('Pediluvios', pediluvios),
                    _buildItemResumen(
                      'Soluciones desinfectantes',
                      solucionesDesinfectantes,
                    ),
                    const SizedBox(height: 16),
                    _buildSeccionResumen('LABORES DENTRO DEL MOKO'),
                    _buildItemResumen(
                      'Análisis microbiológico',
                      analisisMicrobiologico,
                    ),
                    if (observacionesAuditoria.isNotEmpty)
                      _buildTextoResumen(
                        'Observaciones auditoría:',
                        observacionesAuditoria,
                      ),
                    if (seguimientoAreas.isNotEmpty)
                      _buildTextoResumen(
                        'Seguimiento áreas:',
                        seguimientoAreas,
                      ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF004B63),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'EVALUACIÓN COMPLETADA',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${_contarCompletadas()}/9 elementos evaluados',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _mostrarResumen = false),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF004B63)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Editar',
                    style: TextStyle(
                      color: Color(0xFF004B63),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _guardarAuditoria,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF004B63),
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
          ),
        ],
      ),
    );
  }

  Widget _buildTitulo(String titulo) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF004B63),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        titulo,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildPreguntaSiNo(
    String pregunta,
    bool? valor,
    Function(bool?) onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            pregunta,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Radio<bool>(
                      value: true,
                      groupValue: valor,
                      onChanged: onChanged,
                      activeColor: const Color(0xFF004B63),
                    ),
                    const Text('Sí'),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Radio<bool>(
                      value: false,
                      groupValue: valor,
                      onChanged: onChanged,
                      activeColor: const Color(0xFF004B63),
                    ),
                    const Text('No'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCampoTextoConFoto(
    String label,
    String valor,
    Function(String) onChanged,
    File? photoFile,
    VoidCallback onTakePhoto,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          TextField(
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Escriba observaciones...',
              border: OutlineInputBorder(),
            ),
            onChanged: onChanged,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onTakePhoto,
              icon: const Icon(Icons.camera_alt, size: 20),
              label: const Text('Tomar Foto'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF004B63),
                side: const BorderSide(color: Color(0xFF004B63)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          if (photoFile != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Image.file(photoFile, height: 120),
            ),
        ],
      ),
    );
  }

  Widget _buildSeccionResumen(String titulo) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        titulo,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Color(0xFF004B63),
        ),
      ),
    );
  }

  Widget _buildItemResumen(String titulo, bool? valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            valor == true
                ? Icons.check_circle
                : valor == false
                ? Icons.cancel
                : Icons.help_outline,
            color: valor == true
                ? Colors.green
                : valor == false
                ? Colors.red
                : Colors.grey,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(titulo, style: const TextStyle(fontSize: 14))),
          Text(
            valor == true
                ? 'Sí'
                : valor == false
                ? 'No'
                : 'Sin evaluar',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: valor == true
                  ? Colors.green
                  : valor == false
                  ? Colors.red
                  : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextoResumen(String titulo, String texto) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(
          titulo,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF004B63),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Text(texto, style: const TextStyle(fontSize: 12)),
        ),
      ],
    );
  }

  int _contarCompletadas() {
    int count = 0;
    if (controlMaleza != null) count++;
    if (riegoEstructurado != null) count++;
    if (entradaUnica != null) count++;
    if (noMaleza != null) count++;
    if (pediluvios != null) count++;
    if (solucionesDesinfectantes != null) count++;
    if (analisisMicrobiologico != null) count++;
    if (observacionesAuditoria.isNotEmpty) count++;
    if (seguimientoAreas.isNotEmpty) count++;
    return count;
  }

  Future<void> _guardarAuditoria() async {
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

      // Preparar datos de la auditoría con los campos que espera el backend
      final List<Map<String, dynamic>> details = [
        {
          'categoria': 'PROGRAMA DE MANEJO',
          'subcategoria': null,
          'pregunta': 'Control de maleza',
          'respuesta': controlMaleza == true
              ? 'SI'
              : controlMaleza == false
              ? 'NO'
              : null,
          'puntuacion': controlMaleza == true ? 1 : 0,
          'puntuacionMaxima': 1,
          'esCritico': false,
          'observaciones': '',
          'recomendaciones': '',
        },
        {
          'categoria': 'PROGRAMA DE MANEJO',
          'subcategoria': null,
          'pregunta': 'Riego estructurado',
          'respuesta': riegoEstructurado == true
              ? 'SI'
              : riegoEstructurado == false
              ? 'NO'
              : null,
          'puntuacion': riegoEstructurado == true ? 1 : 0,
          'puntuacionMaxima': 1,
          'esCritico': false,
          'observaciones': '',
          'recomendaciones': '',
        },
        {
          'categoria': 'PROGRAMA DE MANEJO',
          'subcategoria': null,
          'pregunta': 'Entrada única',
          'respuesta': entradaUnica == true
              ? 'SI'
              : entradaUnica == false
              ? 'NO'
              : null,
          'puntuacion': entradaUnica == true ? 1 : 0,
          'puntuacionMaxima': 1,
          'esCritico': false,
          'observaciones': '',
          'recomendaciones': '',
        },
        {
          'categoria': 'PROGRAMA DE MANEJO',
          'subcategoria': null,
          'pregunta': 'Tiene maleza',
          'respuesta': noMaleza == true
              ? 'SI'
              : noMaleza == false
              ? 'NO'
              : null,
          'puntuacion': noMaleza == true ? 1 : 0,
          'puntuacionMaxima': 1,
          'esCritico': false,
          'observaciones': '',
          'recomendaciones': '',
        },
        {
          'categoria': 'PROGRAMA DE MANEJO',
          'subcategoria': null,
          'pregunta': 'Pediluvios',
          'respuesta': pediluvios == true
              ? 'SI'
              : pediluvios == false
              ? 'NO'
              : null,
          'puntuacion': pediluvios == true ? 1 : 0,
          'puntuacionMaxima': 1,
          'esCritico': false,
          'observaciones': '',
          'recomendaciones': '',
        },
        {
          'categoria': 'PROGRAMA DE MANEJO',
          'subcategoria': null,
          'pregunta': 'Soluciones desinfectantes',
          'respuesta': solucionesDesinfectantes == true
              ? 'SI'
              : solucionesDesinfectantes == false
              ? 'NO'
              : null,
          'puntuacion': solucionesDesinfectantes == true ? 1 : 0,
          'puntuacionMaxima': 1,
          'esCritico': false,
          'observaciones': '',
          'recomendaciones': '',
        },
        {
          'categoria': 'LABORES DENTRO DEL MOKO',
          'subcategoria': null,
          'pregunta': 'Análisis microbiológico',
          'respuesta': analisisMicrobiologico == true
              ? 'SI'
              : analisisMicrobiologico == false
              ? 'NO'
              : null,
          'puntuacion': analisisMicrobiologico == true ? 1 : 0,
          'puntuacionMaxima': 1,
          'esCritico': false,
          'observaciones': '',
          'recomendaciones': '',
        },
      ];

      // Codificar fotos a base64 si existen
      if (_mokoPhotoPathObservaciones != null) {
        final bytes = File(_mokoPhotoPathObservaciones!).readAsBytesSync();
        _mokoPhotoBase64Observaciones = base64Encode(bytes);
      }
      if (_mokoPhotoPathSeguimiento != null) {
        final bytes = File(_mokoPhotoPathSeguimiento!).readAsBytesSync();
        _mokoPhotoBase64Seguimiento = base64Encode(bytes);
      }

      final auditData = {
        'tecnicoId': widget.clientData?['id'] ?? 1,
        'fecha': DateTime.now().toIso8601String(),
        'estado': 'COMPLETADA',
        'details': details,
        'observaciones': observacionesAuditoria,
        'photoBase64Observaciones': _mokoPhotoBase64Observaciones,
        'photoBase64Seguimiento': _mokoPhotoBase64Seguimiento,
      };

      // 1. Guardar en SQLite primero (siempre)
      final localId = await _offlineStorage.savePendingMokoAudit(
        clientId: auditData['tecnicoId'],
        auditDate: auditData['fecha'],
        status: auditData['estado'],
        mokoData: List<Map<String, dynamic>>.from(auditData['details']),
        observations: auditData['observaciones'],
        photoBase64Observaciones: _mokoPhotoBase64Observaciones,
        photoBase64Seguimiento: _mokoPhotoBase64Seguimiento,
      );

      // 2. Verificar conexión y sincronizar si es posible
      final hasConnection = await _syncService.hasInternetConnection();

      String message;
      if (hasConnection) {
        try {
          // Intentar subir inmediatamente
          final result = await _mokoAuditService.createMokoAudit(
            tecnicoId: auditData['tecnicoId'],
            fecha: auditData['fecha'],
            estado: auditData['estado'],
            details: List<Map<String, dynamic>>.from(auditData['details']),
            observaciones: auditData['observaciones'],
            latitude: null,
            longitude: null,
            photoBase64Observaciones: _mokoPhotoBase64Observaciones,
            photoBase64Seguimiento: _mokoPhotoBase64Seguimiento,
          );

          if (result['success'] == true) {
            // Marcar como sincronizado en SQLite
            await _offlineStorage.markMokoAuditAsSynced(localId);
            message = 'Auditoría guardada y sincronizada exitosamente.';
          } else {
            message =
                'Auditoría guardada localmente. Se sincronizará cuando haya conexión estable.';
          }
        } catch (e) {
          message =
              'Auditoría guardada localmente. Error en sincronización: [${e.toString()}';
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

  Future<void> _tomarFotoMoko(String tipo) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
    );
    if (pickedFile != null) {
      // Guardar la foto con nombre único
      final directory = await Directory.systemTemp.createTemp();
      final uniqueName =
          'moko_${tipo}_${DateTime.now().millisecondsSinceEpoch}_${pickedFile.name}';
      final newPath = '${directory.path}/$uniqueName';
      final newFile = await File(pickedFile.path).copy(newPath);
      setState(() {
        if (tipo == 'observaciones') {
          _mokoPhotoObservaciones = newFile;
          _mokoPhotoPathObservaciones = newFile.path;
        } else if (tipo == 'seguimiento') {
          _mokoPhotoSeguimiento = newFile;
          _mokoPhotoPathSeguimiento = newFile.path;
        }
      });
    }
  }
}
