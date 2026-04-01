import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'offline_storage_service.dart';

class LocationTrackingService {
  static final LocationTrackingService _instance = LocationTrackingService._internal();
  factory LocationTrackingService() => _instance;
  LocationTrackingService._internal();

  final _storage = const FlutterSecureStorage();
  Timer? _trackingTimer;
  bool _isTracking = false;
  String? _currentUserId;
  String? _currentUserName;

  // Configuración de horario: 8 AM a 6 PM (18:00)
  static const int _startHour = 8;
  static const int _endHour = 18;
  // Configuración de intervalo: cada 1 minuto
  static const Duration _trackingInterval = Duration(minutes: 1);

  /// Iniciar el seguimiento automático de ubicación
  Future<void> startTracking({
    required String userId,
    required String userName,
  }) async {
    if (_isTracking) {
      debugPrint('⚠️ El seguimiento ya está activo');
      return;
    }

    _currentUserId = userId;
    _currentUserName = userName;
    _isTracking = true;

    debugPrint('📍 Iniciando seguimiento de ubicación para usuario: $userName');

    // Verificar permisos de ubicación
    final hasPermission = await _checkLocationPermission();
    if (!hasPermission) {
      debugPrint('❌ No hay permisos de ubicación');
      _isTracking = false;
      return;
    }

    // Capturar ubicación inmediatamente
    await _captureLocation();

    // Programar capturas cada 5 segundos
    _trackingTimer = Timer.periodic(_trackingInterval, (timer) async {
      if (_shouldTrackNow()) {
        await _captureLocation();
      } else {
        debugPrint('⏰ Fuera del horario de seguimiento (8 AM - 6 PM)');
      }
    });

    debugPrint('✅ Seguimiento de ubicación iniciado');
  }

  /// Detener el seguimiento automático
  void stopTracking() {
    if (_trackingTimer != null) {
      _trackingTimer!.cancel();
      _trackingTimer = null;
    }
    _isTracking = false;
    _currentUserId = null;
    _currentUserName = null;
    debugPrint('🛑 Seguimiento de ubicación detenido');
  }

  /// Verificar si estamos dentro del horario de seguimiento
  bool _shouldTrackNow() {
    final now = DateTime.now();
    final currentHour = now.hour;
    return currentHour >= _startHour && currentHour < _endHour;
  }

  /// Verificar permisos de ubicación
  Future<bool> _checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('❌ Los servicios de ubicación están deshabilitados');
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('❌ Permisos de ubicación denegados');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint('❌ Permisos de ubicación denegados permanentemente');
      return false;
    }

    return true;
  }

  /// Capturar la ubicación actual y guardarla
  Future<void> _captureLocation() async {
    try {
      debugPrint('📍 Capturando ubicación...');

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      debugPrint('✅ Ubicación obtenida: ${position.latitude}, ${position.longitude}');

      // Obtener coordenadas de la matriz (si existen)
      final matrixCoords = await getMatrixCoordinates();

      // Guardar en base de datos local
      await _saveLocationLocally(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        matrixLatitude: matrixCoords?['latitude'],
        matrixLongitude: matrixCoords?['longitude'],
      );

      // Intentar sincronizar si hay conexión
      await _syncPendingLocations();

    } catch (e) {
      debugPrint('❌ Error capturando ubicación: $e');
    }
  }

  /// Guardar ubicación en la base de datos local
  Future<void> _saveLocationLocally({
    required double latitude,
    required double longitude,
    required double accuracy,
    double? matrixLatitude,
    double? matrixLongitude,
  }) async {
    try {
      final db = await OfflineStorageService().database;
      final timestamp = DateTime.now().toIso8601String();

      final locationData = {
        'user_id': _currentUserId,
        'user_name': _currentUserName,
        'latitude': latitude,
        'longitude': longitude,
        'accuracy': accuracy,
        'matrix_latitude': matrixLatitude,
        'matrix_longitude': matrixLongitude,
        'timestamp': timestamp,
        'is_synced': 0,
      };

      await db.insert('location_tracking', locationData);
      debugPrint('✅ Ubicación guardada localmente');
    } catch (e) {
      // En Web o si hay error, solo mostrar advertencia y continuar
      // La ubicación se enviará directamente al servidor en la próxima sincronización
      debugPrint('⚠️ No se pudo guardar ubicación localmente (normal en Web): $e');
    }
  }

  /// Sincronizar ubicaciones pendientes con el servidor
  Future<void> _syncPendingLocations() async {
    try {
      // Verificar conectividad
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        debugPrint('📡 Sin conexión - ubicaciones quedarán pendientes');
        return;
      }

      final db = await OfflineStorageService().database;
      final pendingLocations = await db.query(
        'location_tracking',
        where: 'is_synced = ?',
        whereArgs: [0],
        orderBy: 'timestamp ASC',
      );

      if (pendingLocations.isEmpty) {
        debugPrint('✅ No hay ubicaciones pendientes por sincronizar');
        return;
      }

      debugPrint('📤 Sincronizando ${pendingLocations.length} ubicaciones pendientes...');

      // Obtener URL del servidor
      final savedUrl = await _storage.read(key: 'server_url');
      final baseUrl = savedUrl ?? 'http://5.161.198.89:8081/api';

      for (final location in pendingLocations) {
        try {
          final response = await http.post(
            Uri.parse('$baseUrl/location-tracking'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'userId': location['user_id'],
              'userName': location['user_name'],
              'latitude': location['latitude'],
              'longitude': location['longitude'],
              'accuracy': location['accuracy'],
              'matrixLatitude': location['matrix_latitude'],
              'matrixLongitude': location['matrix_longitude'],
              'timestamp': location['timestamp'],
            }),
          ).timeout(const Duration(seconds: 10));

          if (response.statusCode == 200 || response.statusCode == 201) {
            // Marcar como sincronizado
            await db.update(
              'location_tracking',
              {'is_synced': 1},
              where: 'id = ?',
              whereArgs: [location['id']],
            );
            debugPrint('✅ Ubicación ID ${location['id']} sincronizada');
          } else {
            debugPrint('⚠️ Error al sincronizar ubicación: ${response.statusCode}');
          }
        } catch (e) {
          debugPrint('❌ Error sincronizando ubicación individual: $e');
        }
      }

      debugPrint('✅ Sincronización completada');

    } catch (e) {
      debugPrint('❌ Error en sincronización de ubicaciones: $e');
    }
  }

  /// Establecer coordenadas de la matriz (punto de partida)
  Future<void> setMatrixCoordinates({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('matrix_latitude', latitude);
      await prefs.setDouble('matrix_longitude', longitude);
      debugPrint('✅ Coordenadas de matriz guardadas: $latitude, $longitude');
    } catch (e) {
      debugPrint('❌ Error guardando coordenadas de matriz: $e');
    }
  }

  /// Obtener coordenadas de la matriz
  Future<Map<String, double>?> getMatrixCoordinates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final latitude = prefs.getDouble('matrix_latitude');
      final longitude = prefs.getDouble('matrix_longitude');

      if (latitude != null && longitude != null) {
        return {
          'latitude': latitude,
          'longitude': longitude,
        };
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error obteniendo coordenadas de matriz: $e');
      return null;
    }
  }

  /// Obtener estado del seguimiento
  bool get isTracking => _isTracking;

  /// Forzar sincronización manual
  Future<void> forceSyncNow() async {
    debugPrint('🔄 Sincronización manual iniciada');
    await _syncPendingLocations();
  }

  /// Obtener historial de ubicaciones (últimas 50)
  Future<List<Map<String, dynamic>>> getLocationHistory({int limit = 50}) async {
    try {
      final db = await OfflineStorageService().database;
      final locations = await db.query(
        'location_tracking',
        orderBy: 'timestamp DESC',
        limit: limit,
      );
      return locations;
    } catch (e) {
      debugPrint('❌ Error obteniendo historial: $e');
      return [];
    }
  }

  /// Limpiar ubicaciones sincronizadas antiguas (más de 30 días)
  Future<void> cleanOldSyncedLocations() async {
    try {
      final db = await OfflineStorageService().database;
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30)).toIso8601String();
      
      final deleted = await db.delete(
        'location_tracking',
        where: 'is_synced = ? AND timestamp < ?',
        whereArgs: [1, thirtyDaysAgo],
      );
      
      debugPrint('🗑️ Limpiadas $deleted ubicaciones antiguas');
    } catch (e) {
      debugPrint('❌ Error limpiando ubicaciones antiguas: $e');
    }
  }
}
