import 'dart:convert';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';

class OfflineStorageService {
  static Database? _database;
  static const String _databaseName = 'lytiks_offline.db';
  static const int _databaseVersion = 7;

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
      // Usar databaseFactoryFfi solo para plataformas desktop (NO Web)
      if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }
      
      // En Web, la funcionalidad de base de datos local no está disponible
      if (kIsWeb) {
        debugPrint('⚠️ Base de datos local no disponible en Web. Los datos se guardarán solo en el servidor.');
        throw UnsupportedError('SQLite no está disponible en plataforma Web');
      }
      
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
    if (oldVersion < 5) {
      // Agregar columnas para trayecto de ubicaciones en auditorías
      await db.execute('ALTER TABLE pending_audits ADD COLUMN trayecto_ubicaciones TEXT');
      await db.execute('ALTER TABLE pending_audits ADD COLUMN inicio_evaluacion TEXT');
      await db.execute('ALTER TABLE pending_audits ADD COLUMN fin_evaluacion TEXT');
      debugPrint('✅ Columnas de trayecto añadidas a pending_audits en upgrade');
    }
    if (oldVersion < 6) {
      // Crear tabla para plan de seguimiento Moko pendiente
      await db.execute('''
        CREATE TABLE IF NOT EXISTS pending_plan_moko_updates (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          foco_id INTEGER,
          plan_seg_moko_id INTEGER,
          ejecucion_plan_id INTEGER,
          tareas_completadas TEXT,
          observaciones TEXT,
          finalizar INTEGER DEFAULT 1,
          created_at TEXT,
          is_synced INTEGER DEFAULT 0
        )
      ''');
      debugPrint('✅ Tabla pending_plan_moko_updates añadida en upgrade');
    }
    if (oldVersion < 7) {
      // Crear tabla para configuraciones de aplicación
      await db.execute('''
        CREATE TABLE IF NOT EXISTS configuraciones_aplicacion (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          foco_id INTEGER NOT NULL,
          fase_id INTEGER NOT NULL,
          tarea_id INTEGER NOT NULL,
          nombre_tarea TEXT NOT NULL,
          fecha_programada TEXT NOT NULL,
          frecuencia INTEGER NOT NULL,
          repeticiones INTEGER NOT NULL,
          recordatorio TEXT NOT NULL,
          completado INTEGER DEFAULT 0,
          fecha_creacion TEXT NOT NULL,
          fecha_completado TEXT,
          observaciones TEXT,
          is_synced INTEGER DEFAULT 0
        )
      ''');
      debugPrint('✅ Tabla configuraciones_aplicacion añadida en upgrade');
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
          trayecto_ubicaciones TEXT,
          inicio_evaluacion TEXT,
          fin_evaluacion TEXT,
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

      // Tabla para plan de seguimiento Moko pendiente
      await db.execute('''
        CREATE TABLE pending_plan_moko_updates (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          foco_id INTEGER,
          plan_seg_moko_id INTEGER,
          ejecucion_plan_id INTEGER,
          tareas_completadas TEXT,
          observaciones TEXT,
          finalizar INTEGER DEFAULT 1,
          created_at TEXT,
          is_synced INTEGER DEFAULT 0
        )
      ''');
      debugPrint('✅ Tabla pending_plan_moko_updates creada');

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

      // Tabla para configuraciones de aplicación
      await db.execute('''
        CREATE TABLE configuraciones_aplicacion (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          foco_id INTEGER NOT NULL,
          fase_id INTEGER NOT NULL,
          tarea_id INTEGER NOT NULL,
          nombre_tarea TEXT NOT NULL,
          fecha_programada TEXT NOT NULL,
          frecuencia INTEGER NOT NULL,
          repeticiones INTEGER NOT NULL,
          recordatorio TEXT NOT NULL,
          completado INTEGER DEFAULT 0,
          fecha_creacion TEXT NOT NULL,
          fecha_completado TEXT,
          observaciones TEXT,
          is_synced INTEGER DEFAULT 0
        )
      ''');
      debugPrint('✅ Tabla configuraciones_aplicacion creada');

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
    List<Map<String, dynamic>>? trayectoUbicaciones,
    String? inicioEvaluacion,
    String? finEvaluacion,
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
      'trayecto_ubicaciones': trayectoUbicaciones != null ? jsonEncode(trayectoUbicaciones) : null,
      'inicio_evaluacion': inicioEvaluacion,
      'fin_evaluacion': finEvaluacion,
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

  // PLAN SEGUIMIENTO MOKO
  Future<int> savePendingPlanMokoUpdate({
    required int focoId,
    required int planSeguimientoId,
    int? ejecucionPlanId,
    required List<int> tareasCompletadas,
    String? observaciones,
    bool finalizar = true,
  }) async {
    final db = await database;
    return await db.insert('pending_plan_moko_updates', {
      'foco_id': focoId,
      'plan_seg_moko_id': planSeguimientoId,
      'ejecucion_plan_id': ejecucionPlanId,
      'tareas_completadas': jsonEncode(tareasCompletadas),
      'observaciones': observaciones,
      'finalizar': finalizar ? 1 : 0,
      'created_at': DateTime.now().toIso8601String(),
      'is_synced': 0,
    });
  }

  Future<List<Map<String, dynamic>>> getPendingPlanMokoUpdates() async {
    final db = await database;
    return await db.query(
      'pending_plan_moko_updates',
      where: 'is_synced = ?',
      whereArgs: [0],
      orderBy: 'created_at DESC',
    );
  }

  Future<void> markPlanMokoUpdateAsSynced(int id) async {
    final db = await database;
    await db.update(
      'pending_plan_moko_updates',
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

    final planMokoCount =
        Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM pending_plan_moko_updates WHERE is_synced = 0',
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

    return auditCount + mokoCount + planMokoCount + sigatokaCount + clientCount + photoCount;
  }

  // LIMPIAR DATOS SINCRONIZADOS
  Future<void> cleanSyncedData() async {
    final db = await database;
    await db.delete('pending_audits', where: 'is_synced = 1');
    await db.delete('pending_moko_audits', where: 'is_synced = 1');
    await db.delete('pending_plan_moko_updates', where: 'is_synced = 1');
    await db.delete('pending_sigatoka_audits', where: 'is_synced = 1');
    await db.delete('pending_clients', where: 'is_synced = 1');
    await db.delete('pending_audit_photos', where: 'is_synced = 1');
  }

  // LIMPIAR TODA LA BASE DE DATOS (para desarrollo)
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('pending_audits');
    await db.delete('pending_moko_audits');
    await db.delete('pending_plan_moko_updates');
    await db.delete('pending_sigatoka_audits');
    await db.delete('pending_clients');
    await db.delete('pending_audit_photos');
  }

  // CONFIGURACIONES DE APLICACIÓN
  Future<int> guardarConfiguracionAplicacion(Map<String, dynamic> configuracion) async {
    try {
      final db = await database;
      
      debugPrint('💾 Guardando configuración: $configuracion');
      
      // Verificar si ya existe una configuración para esta tarea
      final existente = await db.query(
        'configuraciones_aplicacion',
        where: 'foco_id = ? AND fase_id = ? AND tarea_id = ?',
        whereArgs: [
          configuracion['focoId'],
          configuracion['faseId'],
          configuracion['tareaId'],
        ],
      );

      debugPrint('🔍 Configuración existente: ${existente.isNotEmpty ? existente.first : "ninguna"}');

      if (existente.isNotEmpty) {
        // Actualizar configuración existente
        final registrosActualizados = await db.update(
          'configuraciones_aplicacion',
          {
            'nombre_tarea': configuracion['nombreTarea'],
            'fecha_programada': configuracion['fechaProgramada'],
            'frecuencia': configuracion['frecuencia'],
            'repeticiones': configuracion['repeticiones'],
            'recordatorio': configuracion['recordatorio'],
            'completado': (configuracion['completado'] == true || configuracion['completado'] == 1) ? 1 : 0,
            'fecha_creacion': configuracion['fechaCreacion'],
            'observaciones': configuracion['observaciones'],
            'is_synced': 0,
          },
          where: 'id = ?',
          whereArgs: [existente.first['id']],
        );
        debugPrint('✅ Configuración actualizada. Registros afectados: $registrosActualizados, ID: ${existente.first['id']}');
        return existente.first['id'] as int;
      } else {
        // Insertar nueva configuración
        final id = await db.insert(
          'configuraciones_aplicacion',
          {
            'foco_id': configuracion['focoId'],
            'fase_id': configuracion['faseId'],
            'tarea_id': configuracion['tareaId'],
            'nombre_tarea': configuracion['nombreTarea'],
            'fecha_programada': configuracion['fechaProgramada'],
            'frecuencia': configuracion['frecuencia'],
            'repeticiones': configuracion['repeticiones'],
            'recordatorio': configuracion['recordatorio'],
            'completado': (configuracion['completado'] == true || configuracion['completado'] == 1) ? 1 : 0,
            'fecha_creacion': configuracion['fechaCreacion'],
            'observaciones': configuracion['observaciones'],
            'is_synced': 0,
          },
        );
        debugPrint('✅ Nueva configuración insertada con ID: $id');
        return id;
      }
    } catch (e) {
      debugPrint('❌ Error guardando configuración de aplicación: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> obtenerConfiguracionesAplicacion({
    int? focoId,
    int? faseId,
    bool soloSinCompletar = false,
  }) async {
    try {
      final db = await database;
      
      String where = '1=1';
      List<dynamic> whereArgs = [];
      
      if (focoId != null) {
        where += ' AND foco_id = ?';
        whereArgs.add(focoId);
      }
      
      if (faseId != null) {
        where += ' AND fase_id = ?';
        whereArgs.add(faseId);
      }
      
      if (soloSinCompletar) {
        where += ' AND completado = 0';
      }
      
      final List<Map<String, dynamic>> configuraciones = await db.query(
        'configuraciones_aplicacion',
        where: where,
        whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
        orderBy: 'fecha_programada ASC',
      );
      
      debugPrint('📋 Configuraciones encontradas: ${configuraciones.length}');
      return configuraciones;
    } catch (e) {
      debugPrint('❌ Error obteniendo configuraciones de aplicación: $e');
      return [];
    }
  }

  Future<void> marcarConfiguracionCompletada(int id) async {
    try {
      final db = await database;
      await db.update(
        'configuraciones_aplicacion',
        {
          'completado': 1,
          'fecha_completado': DateTime.now().toIso8601String(),
          'is_synced': 0,
        },
        where: 'id = ?',
        whereArgs: [id],
      );
      debugPrint('✅ Configuración marcada como completada: $id');
    } catch (e) {
      debugPrint('❌ Error marcando configuración completada: $e');
      rethrow;
    }
  }

  Future<void> eliminarConfiguracionAplicacion(int id) async {
    try {
      final db = await database;
      await db.delete(
        'configuraciones_aplicacion',
        where: 'id = ?',
        whereArgs: [id],
      );
      debugPrint('✅ Configuración eliminada: $id');
    } catch (e) {
      debugPrint('❌ Error eliminando configuración: $e');
      rethrow;
    }
  }
}
