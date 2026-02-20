import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PlanSeguimientoMokoService {
  static const String _host = '5.161.198.89';
  static const int _port = 8081;
  static const String _basePath = '/api/moko/plan-seguimiento';
  final storage = const FlutterSecureStorage();

  Future<Uri> get baseUri async {
    final savedUrl = await storage.read(key: 'server_url');
    if (savedUrl != null && savedUrl.isNotEmpty) {
      return Uri.parse(savedUrl).replace(path: _basePath);
    }
    return Uri(scheme: 'http', host: _host, port: _port, path: _basePath);
  }

  /// Obtiene todas las fases del protocolo
  Future<List<Map<String, dynamic>>> getFases() async {
    try {
      final base = await baseUri;
      final response = await http.get(
        base.replace(path: '${base.path}/fases'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Error al obtener fases: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error al obtener fases: $e');
      // Datos de fallback
      return _getFasesFallback();
    }
  }

  /// Obtiene las fases con sus tareas incluidas
  Future<List<Map<String, dynamic>>> getFasesConTareas() async {
    try {
      final base = await baseUri;
      final response = await http.get(
        base.replace(path: '${base.path}/fases-con-tareas'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Error al obtener fases con tareas: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error al obtener fases con tareas: $e');
      return _getFasesFallback();
    }
  }

  /// Obtiene las tareas de una fase específica
  Future<List<Map<String, dynamic>>> getTareasPorFase(int faseId) async {
    try {
      final base = await baseUri;
      final response = await http.get(
        base.replace(path: '${base.path}/fases/$faseId/tareas'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Error al obtener tareas: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error al obtener tareas de fase: $e');
      return [];
    }
  }

  /// Inicializa el plan de seguimiento para un foco
  Future<Map<String, dynamic>> inicializarPlan(int focoId) async {
    try {
      final base = await baseUri;
      final response = await http.post(
        base.replace(path: '${base.path}/foco/$focoId/inicializar'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('Error al inicializar plan: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error al inicializar plan: $e');
      rethrow;
    }
  }

  /// Obtiene el estado del plan para un foco
  Future<Map<String, dynamic>> getEstadoPlan(int focoId) async {
    try {
      final base = await baseUri;
      final response = await http.get(
        base.replace(path: '${base.path}/foco/$focoId/estado'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('Error al obtener estado: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error al obtener estado del plan: $e');
      rethrow;
    }
  }

  /// Obtiene el progreso del foco
  Future<Map<String, dynamic>> getProgresoFoco(int focoId) async {
    try {
      final base = await baseUri;
      final response = await http.get(
        base.replace(path: '${base.path}/foco/$focoId/progreso'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('Error al obtener progreso: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error al obtener progreso: $e');
      return {'totalFases': 0, 'fasesCompletadas': 0, 'porcentaje': 0, 'completado': false};
    }
  }

  /// Obtiene las tareas de una ejecución de plan
  Future<List<Map<String, dynamic>>> getTareasEjecucion(int ejecucionPlanId) async {
    try {
      final base = await baseUri;
      final response = await http.get(
        base.replace(path: '${base.path}/ejecucion/$ejecucionPlanId/tareas'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Error al obtener tareas de ejecución: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error al obtener tareas de ejecución: $e');
      return [];
    }
  }

  /// Actualiza el estado de una tarea
  Future<Map<String, dynamic>> actualizarEstadoTarea(int tareaId, bool completado) async {
    try {
      final base = await baseUri;
      final response = await http.put(
        base.replace(
          path: '${base.path}/tarea/$tareaId/estado',
          queryParameters: {'completado': completado.toString()},
        ),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('Error al actualizar tarea: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error al actualizar tarea: $e');
      rethrow;
    }
  }

  /// Actualiza múltiples tareas de una fase
  Future<Map<String, dynamic>> actualizarTareas(int ejecucionPlanId, List<int> tareasCompletadas) async {
    try {
      final base = await baseUri;
      final response = await http.put(
        base.replace(path: '${base.path}/ejecucion/$ejecucionPlanId/tareas'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'tareasCompletadas': tareasCompletadas}),
      );

      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('Error al actualizar tareas: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error al actualizar tareas: $e');
      rethrow;
    }
  }

  /// Finaliza la revisión de una fase
  Future<Map<String, dynamic>> finalizarRevision(int ejecucionPlanId, {String? observaciones}) async {
    try {
      final base = await baseUri;
      final response = await http.post(
        base.replace(path: '${base.path}/ejecucion/$ejecucionPlanId/finalizar'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'observaciones': observaciones}),
      );

      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('Error al finalizar revisión: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error al finalizar revisión: $e');
      rethrow;
    }
  }

  /// Datos de fallback para modo offline
  List<Map<String, dynamic>> _getFasesFallback() {
    return [
      {
        'id': 1,
        'nombre': 'LABORES EN FOCOS',
        'detalle': 'Eliminación segura de plantas infectadas y reducción rápida del patógeno en el suelo.',
        'orden': 1,
        'tareas': [
          {'id': 1, 'nombre': 'INYECCIÓN CON GLIFOSATO', 'dosis': '50CC/UNIDAD BIOLÓGICA'},
          {'id': 2, 'nombre': 'ACELERACIÓN DE DESCOMPOSICIÓN DEGRADEX + SAFERSOIL', 'dosis': '2 LT'},
          {'id': 3, 'nombre': 'APLICACIÓN SAFERSOIL', 'dosis': '200 GR'},
        ],
      },
      {
        'id': 2,
        'nombre': 'VACÍO BIOLÓGICO',
        'detalle': 'Periodo para disminuir la presencia del Moko y reforzar la desinfección del área.',
        'orden': 2,
        'tareas': [
          {'id': 4, 'nombre': 'PRIMER VACÍO - YODOSAFER', 'dosis': '3 LT'},
          {'id': 5, 'nombre': 'PRIMER VACÍO - CUPROSPOR', 'dosis': '3 LT'},
          {'id': 6, 'nombre': 'SEGUNDO VACÍO - YODOSAFER', 'dosis': '3 LT'},
          {'id': 7, 'nombre': 'SEGUNDO VACÍO - CUPROSPOR', 'dosis': '3 LT'},
          {'id': 8, 'nombre': 'TERCER VACÍO - YODOSAFER', 'dosis': '3 LT'},
          {'id': 9, 'nombre': 'TERCER VACÍO - CUPROSPOR', 'dosis': '3 LT'},
        ],
      },
      {
        'id': 3,
        'nombre': 'ACTIVACIÓN SAR',
        'detalle': 'Fortalecimiento de la defensa natural de las plantas sanas mediante bioestimulantes.',
        'orden': 3,
        'tareas': [
          {'id': 10, 'nombre': 'CICLO 1 - ARMORUX', 'dosis': '1 L'},
          {'id': 11, 'nombre': 'CICLO 1 - AMINOALEXIN', 'dosis': '0.5'},
          {'id': 12, 'nombre': 'CICLO 2 - SINERJET CU', 'dosis': '0.5'},
          {'id': 13, 'nombre': 'CICLO 2 - AMINOALEXIN', 'dosis': '0.5'},
          {'id': 14, 'nombre': 'CICLO 3 - ARMORUX', 'dosis': '1 L'},
          {'id': 15, 'nombre': 'CICLO 3 - AMINOALEXIN', 'dosis': '0.5'},
        ],
      },
      {
        'id': 4,
        'nombre': 'SUELOS SUPRESIVOS',
        'detalle': 'Recuperación del suelo con microorganismos benéficos que reducen el riesgo de reinfección.',
        'orden': 4,
        'tareas': [
          {'id': 16, 'nombre': 'PRIMER CICLO - APLICACIÓN DE CHOQUE', 'dosis': '3LT'},
          {'id': 17, 'nombre': 'PRIMER CICLO - SAFERBACTER', 'dosis': '250 GR'},
          {'id': 18, 'nombre': 'SEGUNDO CICLO - SAFERBACTER', 'dosis': '250 GR'},
          {'id': 19, 'nombre': 'TERCER CICLO - SAFERSOIL', 'dosis': '250 GR'},
          {'id': 20, 'nombre': 'CUARTO CICLO - SAFERBACTER', 'dosis': '250 GR'},
        ],
      },
    ];
  }
}
