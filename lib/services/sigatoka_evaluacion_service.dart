import 'dart:convert';
import 'package:http/http.dart' as http;

/**
 * Servicio para gestionar evaluaciones de Sigatoka
 * Conecta con el backend REST API
 */
class SigatokaEvaluacionService {
  // URL del servidor backend (puerto 8081 con context-path /api)
  static const String baseUrl = 'http://5.161.198.89:8081/api/sigatoka';
  
  /**
   * Crea una nueva evaluación
   */
  Future<Map<String, dynamic>> crearEvaluacion({
    required int clienteId,
    required String hacienda,
    required String fecha, // formato: yyyy-MM-dd
    int? semanaEpidemiologica,
    String? periodo,
    required String evaluador,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/crear-evaluacion'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'clienteId': clienteId,
          'hacienda': hacienda,
          'fecha': fecha,
          'semanaEpidemiologica': semanaEpidemiologica,
          'periodo': periodo,
          'evaluador': evaluador,
        }),
      );
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('Error al crear evaluación: ${utf8.decode(response.bodyBytes)}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
  
  /**
   * Crea un lote dentro de una evaluación
   */
  Future<Map<String, dynamic>> crearLote({
    required int evaluacionId,
    required String codigo,
    double? latitud,
    double? longitud,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$evaluacionId/lotes'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'loteCodigo': codigo,
          if (latitud != null) 'latitud': latitud,
          if (longitud != null) 'longitud': longitud,
        }),
      );
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('Error al crear lote: ${utf8.decode(response.bodyBytes)}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  /**
   * Agrega una muestra COMPLETA (formato Excel con todos los campos)
   * Automáticamente crea el lote si no existe
   */
  Future<Map<String, dynamic>> agregarMuestraCompleta({
    required int evaluacionId,
    required int numeroMuestra,
    required String lote,
    double? loteLatitud,
    double? loteLongitud,
    // Grados de infección
    String? hoja3era,
    String? hoja4ta,
    String? hoja5ta,
    // Total hojas
    int? totalHojas3era,
    int? totalHojas4ta,
    int? totalHojas5ta,
    // Variables b-e
    required int plantasConLesiones,
    required int totalLesiones,
    required int plantas3erEstadio,
    required int totalLetras,
    // Stover 0 semanas
    double? hvle0w,
    double? hvlq0w,
    double? hvlq5_0w,
    double? th0w,
    // Stover 10 semanas
    double? hvle10w,
    double? hvlq10w,
    double? hvlq5_10w,
    double? th10w,
  }) async {
    try {
      // Primero, obtener o crear el lote
      Map<String, dynamic> loteData;
      try {
        loteData = await crearLote(
          evaluacionId: evaluacionId,
          codigo: lote,
          latitud: loteLatitud,
          longitud: loteLongitud,
        );
      } catch (e) {
        // Si falla (probablemente lote duplicado), buscar el lote existente
        print('⚠️ Lote ya existe, buscando...: $e');
        try {
          final evalResponse = await http.get(
            Uri.parse('$baseUrl/$evaluacionId'),
            headers: {'Content-Type': 'application/json'},
          );
          if (evalResponse.statusCode == 200) {
            final evalData = jsonDecode(evalResponse.body);
            final lotes = evalData['lotes'] as List;
            final loteExistente = lotes.firstWhere(
              (l) => l['loteCodigo'] == lote,
              orElse: () => null,
            );
            if (loteExistente != null) {
              loteData = loteExistente;
              print('✅ Lote encontrado: ${loteData['id']}');
            } else {
              return {
                'success': false,
                'message': 'No se pudo crear ni encontrar el lote: $lote',
              };
            }
          } else {
            return {
              'success': false,
              'message': 'Error al buscar lote: ${evalResponse.statusCode}',
            };
          }
        } catch (searchError) {
          return {
            'success': false,
            'message': 'Error al buscar lote existente: $searchError',
          };
        }
      }
      
      final loteId = loteData['id'];
      print('📦 Guardando muestra en lote ID: $loteId');
      
      // Ahora agregar la muestra al lote
      final response = await http.post(
        Uri.parse('$baseUrl/lotes/$loteId/muestras'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'muestraNum': numeroMuestra,
          'hoja3era': hoja3era,
          'hoja4ta': hoja4ta,
          'hoja5ta': hoja5ta,
          'totalHojas3era': totalHojas3era,
          'totalHojas4ta': totalHojas4ta,
          'totalHojas5ta': totalHojas5ta,
          'plantasConLesiones': plantasConLesiones,
          'totalLesiones': totalLesiones,
          'plantas3erEstadio': plantas3erEstadio,
          'totalLetras': totalLetras,
          'hvle0w': hvle0w,
          'hvlq0w': hvlq0w,
          'hvlq5_0w': hvlq5_0w,
          'th0w': th0w,
          'hvle10w': hvle10w,
          'hvlq10w': hvlq10w,
          'hvlq5_10w': hvlq5_10w,
          'th10w': th10w,
        }),
      );
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        final muestraGuardada = jsonDecode(response.body);
        print('✅ Muestra guardada en BD: ID=${muestraGuardada['id']}');
        return {
          'success': true,
          'message': 'Muestra guardada en la base de datos',
          'data': muestraGuardada,
        };
      } else {
        print('❌ Error HTTP: ${response.statusCode} - ${response.body}');
        return {
          'success': false,
          'message': 'Error al guardar muestra: ${response.statusCode}\n${response.body}',
        };
      }
    } catch (e) {
      print('❌ Excepción: $e');
      return {
        'success': false,
        'message': 'Error de conexión: $e',
      };
    }
  }
  
  /**
   * Agrega una muestra a una evaluación (MÉTODO VIEJO - mantener para compatibilidad)
   */
  Future<Map<String, dynamic>> agregarMuestra({
    required int evaluacionId,
    required int numeroMuestra,
    required String lote,
    String? variedad,
    String? edad,
    required int hojasEmitidas,
    required int hojasErectas,
    required int hojasConSintomas,
    required int hojaMasJovenEnferma,
    required int hojaMasJovenNecrosada,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/evaluaciones/$evaluacionId/muestras'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'numeroMuestra': numeroMuestra,
          'lote': lote,
          'variedad': variedad,
          'edad': edad,
          'hojasEmitidas': hojasEmitidas,
          'hojasErectas': hojasErectas,
          'hojasConSintomas': hojasConSintomas,
          'hojaMasJovenEnferma': hojaMasJovenEnferma,
          'hojaMasJovenNecrosada': hojaMasJovenNecrosada,
        }),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al agregar muestra: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
  
  /**
   * Ejecuta los cálculos para una evaluación
   */
  Future<Map<String, dynamic>> calcularEvaluacion({
    required int evaluacionId,
    double ritmoEmision = 1.0,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/evaluaciones/$evaluacionId/calcular'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'ritmoEmision': ritmoEmision,
        }),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al calcular evaluación: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
  
  /**
   * Obtiene el reporte completo de una evaluación
   */
  Future<Map<String, dynamic>> obtenerReporte(int evaluacionId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/evaluaciones/$evaluacionId/reporte'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al obtener reporte: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
  
  /**
   * Lista todas las evaluaciones
   */
  Future<List<dynamic>> listarEvaluaciones({int? clienteId}) async {
    try {
      String url = '$baseUrl/evaluaciones';
      if (clienteId != null) {
        url += '?clienteId=$clienteId';
      }
      
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['evaluaciones'] as List<dynamic>;
      } else {
        throw Exception('Error al listar evaluaciones: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
  
  /**
   * Obtiene una evaluación específica
   */
  Future<Map<String, dynamic>> obtenerEvaluacion(int evaluacionId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/evaluaciones/$evaluacionId'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al obtener evaluación: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
  
  /**
   * Actualiza una evaluación
   */
  Future<Map<String, dynamic>> actualizarEvaluacion({
    required int evaluacionId,
    String? hacienda,
    String? fecha,
    int? semanaEpidemiologica,
    String? periodo,
    String? evaluador,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (hacienda != null) body['hacienda'] = hacienda;
      if (fecha != null) body['fecha'] = fecha;
      if (semanaEpidemiologica != null) body['semanaEpidemiologica'] = semanaEpidemiologica;
      if (periodo != null) body['periodo'] = periodo;
      if (evaluador != null) body['evaluador'] = evaluador;
      
      final response = await http.put(
        Uri.parse('$baseUrl/evaluaciones/$evaluacionId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al actualizar evaluación: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
  
  /**
   * Guarda el resumen completo (resumen, indicadores, stover)
   */
  Future<Map<String, dynamic>> guardarResumenCompleto(
    int evaluacionId,
    Map<String, dynamic> resumenData,
    Map<String, dynamic> indicadoresData,
    Map<String, dynamic> stoverData,
  ) async {
    try {
      print('📊 Guardando resumen calculado en FRONTEND (no recalcular en backend)');
      
      // Guardar resumen
      final resumenResponse = await http.post(
        Uri.parse('$baseUrl/evaluaciones/$evaluacionId/resumen'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(resumenData),
      );
      
      if (resumenResponse.statusCode != 200 && resumenResponse.statusCode != 201) {
        return {
          'success': false,
          'message': 'Error al guardar resumen: ${resumenResponse.body}',
        };
      }
      print('✅ Resumen guardado');
      
      // Guardar indicadores (Estado Evolutivo)
      final indicadoresResponse = await http.post(
        Uri.parse('$baseUrl/evaluaciones/$evaluacionId/indicadores'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(indicadoresData),
      );
      
      if (indicadoresResponse.statusCode != 200 && indicadoresResponse.statusCode != 201) {
        return {
          'success': false,
          'message': 'Error al guardar indicadores: ${indicadoresResponse.body}',
        };
      }
      print('✅ Indicadores guardados');
      
      // Guardar Stover promedio
      final stoverResponse = await http.post(
        Uri.parse('$baseUrl/evaluaciones/$evaluacionId/stover-promedio'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(stoverData),
      );
      
      if (stoverResponse.statusCode != 200 && stoverResponse.statusCode != 201) {
        return {
          'success': false,
          'message': 'Error al guardar Stover: ${stoverResponse.body}',
        };
      }
      print('✅ Stover guardado');
      
      return {
        'success': true,
        'message': 'Resumen guardado correctamente (calculado en app)',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: $e',
      };
    }
  }
  
  /**
   * Elimina una evaluación
   */
  Future<Map<String, dynamic>> eliminarEvaluacion(int evaluacionId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/evaluaciones/$evaluacionId'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al eliminar evaluación: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}
