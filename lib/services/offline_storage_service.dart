import 'dart:convert';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';

class OfflineStorageService {
  static Database? _database;
  static const String _databaseName = 'lytiks_offline.db';
  static const int _databaseVersion = 4;

  // Singleton
  static final OfflineStorageService _instance =
      OfflineStorageService._internal();
  factory OfflineStorageService() => _instance;
  OfflineStorageService._internal();

  // Inicialización explícita de la base de datos
  Future<void> initialize() async {
    if (_database == null) {
      _database = await _initDatabase();
    }
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    await initialize();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      String path = join(await getDatabasesPath(), _databaseName);
      debugPrint('🗄️ Inicializando base de datos en: $path');

      return await openDatabase(
        path,
        version: _databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        onOpen: (db) {
          debugPrint('✅ Base de datos abierta correctamente');
        },
      );
    } catch (e) {
      debugPrint('❌ Error inicializando base de datos: $e');
      rethrow;
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Agregar columna cedula_cliente a pending_audits si no existe
      await db.execute(
        'ALTER TABLE pending_audits ADD COLUMN cedula_cliente TEXT',
      );
    }
    if (oldVersion < 3) {
      // Crear tabla para auditorías Sigatoka
      await db.execute('''
        CREATE TABLE IF NOT EXISTS pending_sigatoka_audits (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          client_id INTEGER,
          cedula_cliente TEXT,
          audit_date TEXT,
          status TEXT,
          sigatoka_data TEXT,
          observations TEXT,
          recommendations TEXT,
          nivel_analisis TEXT,
          tipo_cultivo TEXT,
          hacienda TEXT,
          lote TEXT,
          latitude REAL,
          longitude REAL,
          created_at TEXT,
          is_synced INTEGER DEFAULT 0
        )
      ''');
      debugPrint('✅ Tabla pending_sigatoka_audits añadida en upgrade');
    }
    if (oldVersion < 4) {
      // Crear tabla para seguimiento de ubicación de técnicos
      await db.execute('''
        CREATE TABLE IF NOT EXISTS location_tracking (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id TEXT NOT NULL,
          user_name TEXT,
          latitude REAL NOT NULL,
          longitude REAL NOT NULL,
          accuracy REAL,
          matrix_latitude REAL,
          matrix_longitude REAL,
          timestamp TEXT NOT NULL,
          is_synced INTEGER DEFAULT 0
        )
      ''');
      debugPrint('✅ Tabla location_tracking añadida en upgrade');
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    try {
      debugPrint('🏗️ Creando tablas de base de datos...');

      // Tabla para auditorías pendientes
      await db.execute('''
        CREATE TABLE pending_audits (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          client_id INTEGER,
          cedula_cliente TEXT NOT NULL,
          category_id INTEGER,
          audit_date TEXT,
          status TEXT,
          audit_data TEXT,
          observations TEXT,
          latitude REAL,
          longitude REAL,
          image_path TEXT,
          created_at TEXT,
          is_synced INTEGER DEFAULT 0
        )
      ''');
      debugPrint('✅ Tabla pending_audits creada');

      // Tabla para auditorías Moko pendientes
      await db.execute('''
        CREATE TABLE pending_moko_audits (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          client_id INTEGER,
          audit_date TEXT,
          status TEXT,
          moko_data TEXT,
          observations TEXT,
          latitude REAL,
          longitude REAL,
          created_at TEXT,
          is_synced INTEGER DEFAULT 0
        )
      ''');
      debugPrint('✅ Tabla pending_moko_audits creada');

      // Tabla para auditorías Sigatoka pendientes
      await db.execute('''
        CREATE TABLE pending_sigatoka_audits (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          client_id INTEGER,
          cedula_cliente TEXT,
          audit_date TEXT,
          status TEXT,
          sigatoka_data TEXT,
          observations TEXT,
          recommendations TEXT,
          nivel_analisis TEXT,
          tipo_cultivo TEXT,
          hacienda TEXT,
          lote TEXT,
          latitude REAL,
          longitude REAL,
          created_at TEXT,
          is_synced INTEGER DEFAULT 0
        )
      ''');
      debugPrint('✅ Tabla pending_sigatoka_audits creada');

      // Tabla para seguimiento de ubicación de técnicos
      await db.execute('''
        CREATE TABLE location_tracking (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id TEXT NOT NULL,
          user_name TEXT,
          latitude REAL NOT NULL,
          longitude REAL NOT NULL,
          accuracy REAL,
          matrix_latitude REAL,
          matrix_longitude REAL,
          timestamp TEXT NOT NULL,
          is_synced INTEGER DEFAULT 0
        )
      ''');
      debugPrint('✅ Tabla location_tracking creada');

      // Tabla para clientes pendientes
      await db.execute('''
        CREATE TABLE pending_clients (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          cedula TEXT,
          nombre TEXT,
          apellidos TEXT,
          telefono TEXT,
          email TEXT,
          direccion TEXT,
          geolocalizacion_lat REAL,
          geolocalizacion_lng REAL,
          nombre_finca TEXT,
          area_cultivo REAL,
          tipo_cultivo TEXT,
          tecnico_asignado TEXT,
          created_at TEXT,
          is_synced INTEGER DEFAULT 0
        )
      ''');
      debugPrint('✅ Tabla pending_clients creada');

      // Tabla para fotos de auditorías pendientes
      await db.execute('''
        CREATE TABLE pending_audit_photos (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          audit_id INTEGER,
          audit_type TEXT,
          photo_path TEXT,
          description TEXT,
          created_at TEXT,
          is_synced INTEGER DEFAULT 0
        )
      ''');
      debugPrint('✅ Tabla pending_audit_photos creada');

      debugPrint('🎉 Todas las tablas creadas exitosamente');
    } catch (e) {
      debugPrint('❌ Error creando tablas: $e');
      rethrow;
    }
  }

  // AUDITORÍAS REGULARES
  Future<int> savePendingAudit({
    required int clientId,
    required String cedulaCliente,
    required int categoryId,
    required String auditDate,
    required String status,
    required List<Map<String, dynamic>> auditData,
    String? observations,
    double? latitude,
    double? longitude,
    String? imagePath,
  }) async {
    final db = await database;
    return await db.insert('pending_audits', {
      'client_id': clientId,
      'cedula_cliente': cedulaCliente,
      'category_id': categoryId,
      'audit_date': auditDate,
      'status': status,
      'audit_data': jsonEncode(auditData),
      'observations': observations,
      'latitude': latitude,
      'longitude': longitude,
      'image_path': imagePath,
      'created_at': DateTime.now().toIso8601String(),
      'is_synced': 0,
    });
  }

  Future<List<Map<String, dynamic>>> getPendingAudits() async {
    final db = await database;
    return await db.query(
      'pending_audits',
      where: 'is_synced = ?',
      whereArgs: [0],
      orderBy: 'created_at DESC',
    );
  }

  Future<void> markAuditAsSynced(int id) async {
    final db = await database;
    await db.update(
      'pending_audits',
      {'is_synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // AUDITORÍAS MOKO
  Future<int> savePendingMokoAudit({
    required int clientId,
    required String auditDate,
    required String status,
    required List<Map<String, dynamic>> mokoData,
    String? observations,
    double? latitude,
    double? longitude,
    String? photoBase64Observaciones,
    String? photoBase64Seguimiento,
  }) async {
    try {
      debugPrint('💾 Guardando auditoría Moko offline...');
      final db = await database;

      final result = await db.insert('pending_moko_audits', {
        'client_id': clientId,
        'audit_date': auditDate,
        'status': status,
        'moko_data': jsonEncode(mokoData),
        'observations': observations,
        'latitude': latitude,
        'longitude': longitude,
        'created_at': DateTime.now().toIso8601String(),
        'is_synced': 0,
      });

      debugPrint('✅ Auditoría Moko guardada con ID: $result');
      return result;
    } catch (e) {
      debugPrint('❌ Error guardando auditoría Moko: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getPendingMokoAudits() async {
    final db = await database;
    return await db.query(
      'pending_moko_audits',
      where: 'is_synced = ?',
      whereArgs: [0],
      orderBy: 'created_at DESC',
    );
  }

  Future<void> markMokoAuditAsSynced(int id) async {
    final db = await database;
    await db.update(
      'pending_moko_audits',
      {'is_synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // AUDITORÍAS SIGATOKA
  Future<int> savePendingSigatokaAudit({
    required int clientId,
    required String cedulaCliente,
    required String auditDate,
    required String status,
    required Map<String, dynamic> sigatokaData,
    String? observations,
    String? recommendations,
    String? nivelAnalisis,
    String? tipoCultivo,
    String? hacienda,
    String? lote,
    double? latitude,
    double? longitude,
  }) async {
    try {
      debugPrint('💾 Guardando auditoría Sigatoka offline...');
      final db = await database;

      final result = await db.insert('pending_sigatoka_audits', {
        'client_id': clientId,
        'cedula_cliente': cedulaCliente,
        'audit_date': auditDate,
        'status': status,
        'sigatoka_data': jsonEncode(sigatokaData),
        'observations': observations,
        'recommendations': recommendations,
        'nivel_analisis': nivelAnalisis,
        'tipo_cultivo': tipoCultivo,
        'hacienda': hacienda,
        'lote': lote,
        'latitude': latitude,
        'longitude': longitude,
        'created_at': DateTime.now().toIso8601String(),
        'is_synced': 0,
      });

      debugPrint('✅ Auditoría Sigatoka guardada con ID: $result');
      return result;
    } catch (e) {
      debugPrint('❌ Error guardando auditoría Sigatoka: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getPendingSigatokaAudits() async {
    final db = await database;
    return await db.query(
      'pending_sigatoka_audits',
      where: 'is_synced = ?',
      whereArgs: [0],
      orderBy: 'created_at DESC',
    );
  }

  Future<void> markSigatokaAuditAsSynced(int id) async {
    final db = await database;
    await db.update(
      'pending_sigatoka_audits',
      {'is_synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // CLIENTES
  Future<int> savePendingClient({
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
    final db = await database;
    return await db.insert('pending_clients', {
      'cedula': cedula,
      'nombre': nombre,
      'apellidos': apellidos,
      'telefono': telefono,
      'email': email,
      'direccion': direccion,
      'geolocalizacion_lat': geolocalizacionLat,
      'geolocalizacion_lng': geolocalizacionLng,
      'nombre_finca': nombreFinca,
      'area_cultivo': areaCultivo,
      'tipo_cultivo': tipoCultivo,
      'tecnico_asignado': tecnicoAsignado,
      'created_at': DateTime.now().toIso8601String(),
      'is_synced': 0,
    });
  }

  Future<List<Map<String, dynamic>>> getPendingClients() async {
    final db = await database;
    return await db.query(
      'pending_clients',
      where: 'is_synced = ?',
      whereArgs: [0],
      orderBy: 'created_at DESC',
    );
  }

  Future<void> markClientAsSynced(int id) async {
    final db = await database;
    await db.update(
      'pending_clients',
      {'is_synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // FOTOS
  Future<int> savePendingPhoto({
    required int auditId,
    required String auditType, // 'audit' o 'moko'
    required String photoPath,
    String? description,
  }) async {
    final db = await database;
    return await db.insert('pending_audit_photos', {
      'audit_id': auditId,
      'audit_type': auditType,
      'photo_path': photoPath,
      'description': description,
      'created_at': DateTime.now().toIso8601String(),
      'is_synced': 0,
    });
  }

  Future<List<Map<String, dynamic>>> getPendingPhotos() async {
    final db = await database;
    return await db.query(
      'pending_audit_photos',
      where: 'is_synced = ?',
      whereArgs: [0],
      orderBy: 'created_at DESC',
    );
  }

  Future<void> markPhotoAsSynced(int id) async {
    final db = await database;
    await db.update(
      'pending_audit_photos',
      {'is_synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // CONTAR ELEMENTOS PENDIENTES
  Future<int> getPendingCount() async {
    final db = await database;

    final auditCount =
        Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM pending_audits WHERE is_synced = 0',
          ),
        ) ??
        0;

    final mokoCount =
        Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM pending_moko_audits WHERE is_synced = 0',
          ),
        ) ??
        0;

    final sigatokaCount =
        Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM pending_sigatoka_audits WHERE is_synced = 0',
          ),
        ) ??
        0;

    final clientCount =
        Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM pending_clients WHERE is_synced = 0',
          ),
        ) ??
        0;

    final photoCount =
        Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM pending_audit_photos WHERE is_synced = 0',
          ),
        ) ??
        0;

    return auditCount + mokoCount + sigatokaCount + clientCount + photoCount;
  }

  // LIMPIAR DATOS SINCRONIZADOS
  Future<void> cleanSyncedData() async {
    final db = await database;
    await db.delete('pending_audits', where: 'is_synced = 1');
    await db.delete('pending_moko_audits', where: 'is_synced = 1');
    await db.delete('pending_sigatoka_audits', where: 'is_synced = 1');
    await db.delete('pending_clients', where: 'is_synced = 1');
    await db.delete('pending_audit_photos', where: 'is_synced = 1');
  }

  // LIMPIAR TODA LA BASE DE DATOS (para desarrollo)
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('pending_audits');
    await db.delete('pending_moko_audits');
    await db.delete('pending_sigatoka_audits');
    await db.delete('pending_clients');
    await db.delete('pending_audit_photos');
  }
}
