import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class OfflineStorageService {
  static final OfflineStorageService _instance =
      OfflineStorageService._internal();
  factory OfflineStorageService() => _instance;
  OfflineStorageService._internal();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'offline_audits.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE pending_audits (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            client_id INTEGER,
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
            photo_base64_observaciones TEXT,
            photo_base64_seguimiento TEXT,
            created_at TEXT,
            is_synced INTEGER DEFAULT 0
          )
        ''');
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
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Agregar columnas si no existen
          await db.execute(
            '''ALTER TABLE pending_moko_audits ADD COLUMN photo_base64_observaciones TEXT;''',
          );
          await db.execute(
            '''ALTER TABLE pending_moko_audits ADD COLUMN photo_base64_seguimiento TEXT;''',
          );
        }
      },
    );
  }

  // AUDITORÍAS REGULARES
  Future<int> savePendingAudit({
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
    final db = await database;
    return await db.insert('pending_audits', {
      'client_id': clientId,
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
    final db = await database;
    return await db.insert('pending_moko_audits', {
      'client_id': clientId,
      'audit_date': auditDate,
      'status': status,
      'moko_data': jsonEncode(mokoData),
      'observations': observations,
      'latitude': latitude,
      'longitude': longitude,
      'photo_base64_observaciones': photoBase64Observaciones,
      'photo_base64_seguimiento': photoBase64Seguimiento,
      'created_at': DateTime.now().toIso8601String(),
      'is_synced': 0,
    });
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

    return auditCount + mokoCount + clientCount + photoCount;
  }

  // LIMPIAR DATOS SINCRONIZADOS
  Future<void> cleanSyncedData() async {
    final db = await database;
    await db.delete('pending_audits', where: 'is_synced = 1');
    await db.delete('pending_moko_audits', where: 'is_synced = 1');
    await db.delete('pending_clients', where: 'is_synced = 1');
    await db.delete('pending_audit_photos', where: 'is_synced = 1');
  }

  // LIMPIAR TODA LA BASE DE DATOS (para desarrollo)
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('pending_audits');
    await db.delete('pending_moko_audits');
    await db.delete('pending_clients');
    await db.delete('pending_audit_photos');
  }
}
