import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'offline_storage_service.dart';
import 'audit_service.dart';
import 'client_service.dart';
import 'moko_audit_service.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final OfflineStorageService _offlineStorage = OfflineStorageService();
  final AuditService _auditService = AuditService();
  final ClientService _clientService = ClientService();
  final MokoAuditService _mokoAuditService = MokoAuditService();

  // Verificar conectividad
  Future<bool> hasInternetConnection() async {
    try {
      // 1. Verificar conectividad del dispositivo
      final connectivityResult = await Connectivity().checkConnectivity();
      debugPrint('🔍 Conectividad del dispositivo: $connectivityResult');

      if (connectivityResult == ConnectivityResult.none) {
        debugPrint('❌ No hay conectividad en el dispositivo');
        return false;
      }

      // 2. Verificar conexión real con el servidor
      debugPrint('🔗 Probando conexión con el servidor...');
      final response = await _auditService.testConnection();
      debugPrint('📡 Respuesta del servidor: $response');

      if (response) {
        debugPrint('✅ Conexión con servidor exitosa');
      } else {
        debugPrint('❌ No se puede conectar al servidor');
      }

      return response;
    } catch (e) {
      debugPrint('❌ Error verificando conectividad: $e');
      return false;
    }
  }

  // Obtener el número total de elementos pendientes
  Future<int> getPendingCount() async {
    return await _offlineStorage.getPendingCount();
  }

  // Sincronizar todos los datos pendientes
  Future<SyncResult> syncAllData() async {
    if (!await hasInternetConnection()) {
      debugPrint('[SYNC] ❌ No hay conexión a internet');
      return SyncResult(
        success: false,
        message: 'No hay conexión a internet',
        syncedItems: 0,
        failedItems: 0,
      );
    }

    int syncedItems = 0;
    int failedItems = 0;
    List<String> errors = [];

    try {
      debugPrint('[SYNC] Iniciando sincronización de clientes...');
      final clientResult = await _syncClients();
      debugPrint('[SYNC] Resultado clientes: $clientResult');
      syncedItems += clientResult.syncedItems;
      failedItems += clientResult.failedItems;
      if (clientResult.errors.isNotEmpty) {
        errors.addAll(clientResult.errors);
      }

      debugPrint('[SYNC] Iniciando sincronización de auditorías regulares...');
      final auditResult = await _syncAudits();
      debugPrint('[SYNC] Resultado auditorías: $auditResult');
      syncedItems += auditResult.syncedItems;
      failedItems += auditResult.failedItems;
      if (auditResult.errors.isNotEmpty) {
        errors.addAll(auditResult.errors);
      }

      debugPrint('[SYNC] Iniciando sincronización de auditorías Moko...');
      final mokoResult = await _syncMokoAudits();
      debugPrint('[SYNC] Resultado auditorías Moko: $mokoResult');
      syncedItems += mokoResult.syncedItems;
      failedItems += mokoResult.failedItems;
      if (mokoResult.errors.isNotEmpty) {
        errors.addAll(mokoResult.errors);
      }

      debugPrint('[SYNC] Iniciando sincronización de fotos...');
      final photoResult = await _syncPhotos();
      debugPrint('[SYNC] Resultado fotos: $photoResult');
      syncedItems += photoResult.syncedItems;
      failedItems += photoResult.failedItems;
      if (photoResult.errors.isNotEmpty) {
        errors.addAll(photoResult.errors);
      }

      // 5. Limpiar datos sincronizados exitosamente
      if (syncedItems > 0) {
        debugPrint('[SYNC] Limpiando datos sincronizados...');
        await _offlineStorage.cleanSyncedData();
      }

      final success = failedItems == 0;
      debugPrint(
        '[SYNC] Finalizado. Exito: $success, Sincronizados: $syncedItems, Fallidos: $failedItems, Errores: $errors',
      );
      return SyncResult(
        success: success,
        message: success
            ? 'Sincronización completada exitosamente'
            : 'Sincronización completada con errores',
        syncedItems: syncedItems,
        failedItems: failedItems,
        errors: errors,
      );
    } catch (e, stack) {
      debugPrint('[SYNC] Error during sync: $e');
      debugPrint('[SYNC] Stacktrace: $stack');
      return SyncResult(
        success: false,
        message: 'Error general durante la sincronización: $e',
        syncedItems: syncedItems,
        failedItems: failedItems + 1,
        errors: [e.toString()],
      );
    }
  }

  // Sincronizar clientes
  Future<SyncResult> _syncClients() async {
    final pendingClients = await _offlineStorage.getPendingClients();
    int syncedItems = 0;
    int failedItems = 0;
    List<String> errors = [];

    for (final clientData in pendingClients) {
      try {
        final result = await _clientService.createClient(clientData);

        if (result['success'] == true) {
          await _offlineStorage.markClientAsSynced(clientData['id']);
          syncedItems++;
          debugPrint('Cliente sincronizado: ${clientData['nombre']}');
        } else {
          failedItems++;
          errors.add(
            'Error al sincronizar cliente ${clientData['nombre']}: ${result['message']}',
          );
        }
      } catch (e) {
        failedItems++;
        errors.add('Error al sincronizar cliente ${clientData['nombre']}: $e');
        debugPrint('Error syncing client: $e');
      }
    }

    return SyncResult(
      success: failedItems == 0,
      message: 'Clientes: $syncedItems sincronizados, $failedItems fallidos',
      syncedItems: syncedItems,
      failedItems: failedItems,
      errors: errors,
    );
  }

  // Sincronizar auditorías regulares
  Future<SyncResult> _syncAudits() async {
    final pendingAudits = await _offlineStorage.getPendingAudits();
    int syncedItems = 0;
    int failedItems = 0;
    List<String> errors = [];

    for (final auditData in pendingAudits) {
      try {
        debugPrint(
          '[SYNC][AUDIT] Procesando auditoría ID local: ${auditData['id']}',
        );
        final auditDataParsed = (jsonDecode(auditData['audit_data']) as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        debugPrint('[SYNC][AUDIT] auditDataParsed: $auditDataParsed');

        // TODO: Map real values for hacienda, tecnicoId, observaciones if available
        final String hacienda = 'Hacienda Demo';
        final String cultivo = 'banano'; // or from auditData if available
        final String fecha =
            auditData['audit_date'] ?? DateTime.now().toIso8601String();
        final int tecnicoId = 1;
        final String estado = auditData['status'] ?? 'COMPLETADA';
        final String? observaciones = auditData['observations'];
        final scores = AuditService.buildBackendScores(auditDataParsed);

        final result = await _auditService.createAuditBackend(
          hacienda: hacienda,
          cultivo: cultivo,
          fecha: fecha,
          tecnicoId: tecnicoId,
          estado: estado,
          observaciones: observaciones,
          scores: scores,
        );
        debugPrint('[SYNC][AUDIT] Respuesta backend: $result');

        if (result['success'] == true) {
          await _offlineStorage.markAuditAsSynced(auditData['id']);
          syncedItems++;
          debugPrint(
            '[SYNC][AUDIT] Auditoría sincronizada: ${auditData['id']}',
          );
        } else {
          failedItems++;
          errors.add(
            'Error al sincronizar auditoría ${auditData['id']}: ${result['message']}',
          );
          debugPrint('[SYNC][AUDIT] Error backend: ${result['message']}');
        }
      } catch (e, stack) {
        failedItems++;
        errors.add('Error al sincronizar auditoría ${auditData['id']}: $e');
        debugPrint('[SYNC][AUDIT] Error syncing audit: $e');
        debugPrint('[SYNC][AUDIT] Stacktrace: $stack');
      }
    }

    return SyncResult(
      success: failedItems == 0,
      message: 'Auditorías: $syncedItems sincronizadas, $failedItems fallidas',
      syncedItems: syncedItems,
      failedItems: failedItems,
      errors: errors,
    );
  }

  // Sincronizar auditorías Moko
  Future<SyncResult> _syncMokoAudits() async {
    final pendingMokoAudits = await _offlineStorage.getPendingMokoAudits();
    int syncedItems = 0;
    int failedItems = 0;
    List<String> errors = [];

    for (final mokoData in pendingMokoAudits) {
      try {
        final List<dynamic> rawList = jsonDecode(mokoData['moko_data']);
        final List<Map<String, dynamic>> details = rawList
            .map((e) => Map<String, dynamic>.from(e))
            .toList();

        final result = await _mokoAuditService.createMokoAudit(
          tecnicoId: mokoData['client_id'],
          fecha: mokoData['audit_date'],
          estado: mokoData['status'],
          details: details,
          observaciones: mokoData['observations'],
          latitude: mokoData['latitude'],
          longitude: mokoData['longitude'],
        );

        if (result['success'] == true) {
          await _offlineStorage.markMokoAuditAsSynced(mokoData['id']);
          syncedItems++;
          debugPrint('Auditoría Moko sincronizada: ${mokoData['id']}');
        } else {
          failedItems++;
          errors.add(
            'Error al sincronizar auditoría Moko ${mokoData['id']}: ${result['message']}',
          );
        }
      } catch (e) {
        failedItems++;
        errors.add('Error al sincronizar auditoría Moko ${mokoData['id']}: $e');
        debugPrint('Error syncing Moko audit: $e');
      }
    }

    return SyncResult(
      success: failedItems == 0,
      message:
          'Auditorías Moko: $syncedItems sincronizadas, $failedItems fallidas',
      syncedItems: syncedItems,
      failedItems: failedItems,
      errors: errors,
    );
  }

  // Sincronizar fotos (placeholder por ahora)
  Future<SyncResult> _syncPhotos() async {
    final pendingPhotos = await _offlineStorage.getPendingPhotos();
    int syncedItems = 0;
    int failedItems = 0;
    List<String> errors = [];

    for (final photoData in pendingPhotos) {
      try {
        // TODO: Implementar subida de fotos al servidor
        // Por ahora solo marcamos como sincronizadas
        await _offlineStorage.markPhotoAsSynced(photoData['id']);
        syncedItems++;
        debugPrint('Foto sincronizada: ${photoData['photo_path']}');
      } catch (e) {
        failedItems++;
        errors.add('Error al sincronizar foto ${photoData['photo_path']}: $e');
        debugPrint('Error syncing photo: $e');
      }
    }

    return SyncResult(
      success: failedItems == 0,
      message: 'Fotos: $syncedItems sincronizadas, $failedItems fallidas',
      syncedItems: syncedItems,
      failedItems: failedItems,
      errors: errors,
    );
  }

  // Guardar datos offline cuando no hay conexión
  Future<bool> saveAuditOffline({
    required int clientId,
    required int categoryId,
    required String auditDate,
    required String status,
    required List<Map<String, dynamic>> auditData,
    String? observations,
    double? latitude,
    double? longitude,
    String? imagePath,
  }) async {
    try {
      await _offlineStorage.savePendingAudit(
        clientId: clientId,
        categoryId: categoryId,
        auditDate: auditDate,
        status: status,
        auditData: auditData,
        observations: observations,
        latitude: latitude,
        longitude: longitude,
        imagePath: imagePath,
      );
      return true;
    } catch (e) {
      debugPrint('Error saving audit offline: $e');
      return false;
    }
  }

  Future<bool> saveMokoAuditOffline({
    required int clientId,
    required String auditDate,
    required String status,
    required List<Map<String, dynamic>> mokoData,
    String? observations,
    double? latitude,
    double? longitude,
  }) async {
    try {
      await _offlineStorage.savePendingMokoAudit(
        clientId: clientId,
        auditDate: auditDate,
        status: status,
        mokoData: mokoData,
        observations: observations,
        latitude: latitude,
        longitude: longitude,
      );
      return true;
    } catch (e) {
      debugPrint('Error saving Moko audit offline: $e');
      return false;
    }
  }

  Future<bool> saveClientOffline({
    required String cedula,
    required String nombre,
    String? apellidos,
    String? telefono,
    String? email,
    String? direccion,
    double? geolocalizacionLat,
    double? geolocalizacionLng,
    String? nombreFinca,
    double? areaCultivo,
    String? tipoCultivo,
    String? tecnicoAsignado,
  }) async {
    try {
      await _offlineStorage.savePendingClient(
        cedula: cedula,
        nombre: nombre,
        apellidos: apellidos,
        telefono: telefono,
        email: email,
        direccion: direccion,
        geolocalizacionLat: geolocalizacionLat,
        geolocalizacionLng: geolocalizacionLng,
        nombreFinca: nombreFinca,
        areaCultivo: areaCultivo,
        tipoCultivo: tipoCultivo,
        tecnicoAsignado: tecnicoAsignado,
      );
      return true;
    } catch (e) {
      debugPrint('Error saving client offline: $e');
      return false;
    }
  }
}

class SyncResult {
  final bool success;
  final String message;
  final int syncedItems;
  final int failedItems;
  final List<String> errors;

  SyncResult({
    required this.success,
    required this.message,
    required this.syncedItems,
    required this.failedItems,
    this.errors = const [],
  });

  @override
  String toString() {
    return 'SyncResult{success: $success, message: $message, syncedItems: $syncedItems, failedItems: $failedItems, errors: $errors}';
  }
}
