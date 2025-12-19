import 'package:flutter/material.dart';
import '../services/sigatoka_evaluacion_service.dart';

class ResumenSigatokaScreen extends StatefulWidget {
  final List<Map<String, dynamic>> muestrasSesion;
  final int evaluacionId;

  const ResumenSigatokaScreen({
    Key? key,
    required this.muestrasSesion,
    required this.evaluacionId,
  }) : super(key: key);

  @override
  State<ResumenSigatokaScreen> createState() => _ResumenSigatokaScreenState();
}

class _ResumenSigatokaScreenState extends State<ResumenSigatokaScreen> {
  final SigatokaEvaluacionService _service = SigatokaEvaluacionService();
  bool isLoading = false;

  // Variables calculadas
  late int totalMuestras;
  late int totalHojas3era, totalHojas4ta, totalHojas5ta;
  late int totalLesiones3era, totalLesiones4ta, totalLesiones5ta;
  late int totalPlantas3erEstadio3era, totalPlantas3erEstadio4ta, totalPlantas3erEstadio5ta;
  late int totalPlantasConLesiones3era, totalPlantasConLesiones4ta, totalPlantasConLesiones5ta;
  late int totalLetras3era, totalLetras4ta, totalLetras5ta;
  late double promedioHvle0w, promedioHvlq0w, promedioHvlq5_0w, promedioTh0w;
  late double promedioHvle10w, promedioHvlq10w, promedioHvlq5_10w, promedioTh10w;
  late double promedioLesiones3era, promedioLesiones4ta, promedioLesiones5ta;
  late double porcentaje3erEstadio3era, porcentaje3erEstadio4ta, porcentaje3erEstadio5ta;
  late double porcentajePlantasLesiones3era, porcentajePlantasLesiones4ta, porcentajePlantasLesiones5ta;
  late double promedioHojasFuncionales3era, promedioHojasFuncionales4ta, promedioHojasFuncionales5ta;
  late double promedioLetras3era, promedioLetras4ta, promedioLetras5ta;
  late double ee3era, ee4ta, ee5ta;

  @override
  void initState() {
    super.initState();
    _calcularResumen();
  }

  void _calcularResumen() {
    // Usar las muestras de la sesión actual
    List<Map<String, dynamic>> todasLasMuestras = widget.muestrasSesion;

    totalMuestras = todasLasMuestras.length;
    totalHojas3era = 0;
    totalHojas4ta = 0;
    totalHojas5ta = 0;
    totalLesiones3era = 0;
    totalLesiones4ta = 0;
    totalLesiones5ta = 0;
    totalPlantas3erEstadio3era = 0;
    totalPlantas3erEstadio4ta = 0;
    totalPlantas3erEstadio5ta = 0;
    totalPlantasConLesiones3era = 0;
    totalPlantasConLesiones4ta = 0;
    totalPlantasConLesiones5ta = 0;
    totalLetras3era = 0;
    totalLetras4ta = 0;
    totalLetras5ta = 0;

    double sumaHvle0w = 0, sumaHvlq0w = 0, sumaHvlq5_0w = 0, sumaTh0w = 0;
    double sumaHvle10w = 0, sumaHvlq10w = 0, sumaHvlq5_10w = 0, sumaTh10w = 0;
    int contadorStover = 0;

    for (var muestra in todasLasMuestras) {
      totalHojas3era += (muestra['totalHojas3era'] ?? 0) as int;
      totalHojas4ta += (muestra['totalHojas4ta'] ?? 0) as int;
      totalHojas5ta += (muestra['totalHojas5ta'] ?? 0) as int;

      // Procesar 3era hoja
      if (muestra['hoja3era'] != null) {
        String grado = muestra['hoja3era'].toString();
        int? numero = int.tryParse(grado.replaceAll(RegExp(r'[^0-9]'), ''));
        if (numero != null) {
          totalLesiones3era += numero;
          if (numero == 3) totalPlantas3erEstadio3era++;
          if (numero > 0) totalPlantasConLesiones3era++;
        }
        String letras = grado.replaceAll(RegExp(r'[0-9]'), '');
        totalLetras3era += letras.length;
      }

      // Procesar 4ta hoja
      if (muestra['hoja4ta'] != null) {
        String grado = muestra['hoja4ta'].toString();
        int? numero = int.tryParse(grado.replaceAll(RegExp(r'[^0-9]'), ''));
        if (numero != null) {
          totalLesiones4ta += numero;
          if (numero == 3) totalPlantas3erEstadio4ta++;
          if (numero > 0) totalPlantasConLesiones4ta++;
        }
        String letras = grado.replaceAll(RegExp(r'[0-9]'), '');
        totalLetras4ta += letras.length;
      }

      // Procesar 5ta hoja
      if (muestra['hoja5ta'] != null) {
        String grado = muestra['hoja5ta'].toString();
        int? numero = int.tryParse(grado.replaceAll(RegExp(r'[^0-9]'), ''));
        if (numero != null) {
          totalLesiones5ta += numero;
          if (numero == 3) totalPlantas3erEstadio5ta++;
          if (numero > 0) totalPlantasConLesiones5ta++;
        }
        String letras = grado.replaceAll(RegExp(r'[0-9]'), '');
        totalLetras5ta += letras.length;
      }

      // Sumar Stover 0w
      if (muestra['hvle0w'] != null) {
        sumaHvle0w += (muestra['hvle0w'] is int) ? (muestra['hvle0w'] as int).toDouble() : (muestra['hvle0w'] as double);
      }
      if (muestra['hvlq0w'] != null) {
        sumaHvlq0w += (muestra['hvlq0w'] is int) ? (muestra['hvlq0w'] as int).toDouble() : (muestra['hvlq0w'] as double);
      }
      if (muestra['hvlq5_0w'] != null || muestra['hvlq50w'] != null) {
        var val = muestra['hvlq5_0w'] ?? muestra['hvlq50w'];
        sumaHvlq5_0w += (val is int) ? (val as int).toDouble() : (val as double);
      }
      if (muestra['th0w'] != null) {
        sumaTh0w += (muestra['th0w'] is int) ? (muestra['th0w'] as int).toDouble() : (muestra['th0w'] as double);
      }

      // Sumar Stover 10w
      if (muestra['hvle10w'] != null) {
        sumaHvle10w += (muestra['hvle10w'] is int) ? (muestra['hvle10w'] as int).toDouble() : (muestra['hvle10w'] as double);
      }
      if (muestra['hvlq10w'] != null) {
        sumaHvlq10w += (muestra['hvlq10w'] is int) ? (muestra['hvlq10w'] as int).toDouble() : (muestra['hvlq10w'] as double);
      }
      if (muestra['hvlq5_10w'] != null || muestra['hvlq510w'] != null) {
        var val = muestra['hvlq5_10w'] ?? muestra['hvlq510w'];
        sumaHvlq5_10w += (val is int) ? (val as int).toDouble() : (val as double);
      }
      if (muestra['th10w'] != null) {
        sumaTh10w += (muestra['th10w'] is int) ? (muestra['th10w'] as int).toDouble() : (muestra['th10w'] as double);
      }

      contadorStover++;
    }

    // Calcular promedios
    promedioHvle0w = contadorStover > 0 ? sumaHvle0w / contadorStover : 0;
    promedioHvlq0w = contadorStover > 0 ? sumaHvlq0w / contadorStover : 0;
    promedioHvlq5_0w = contadorStover > 0 ? sumaHvlq5_0w / contadorStover : 0;
    promedioTh0w = contadorStover > 0 ? sumaTh0w / contadorStover : 0;

    promedioHvle10w = contadorStover > 0 ? sumaHvle10w / contadorStover : 0;
    promedioHvlq10w = contadorStover > 0 ? sumaHvlq10w / contadorStover : 0;
    promedioHvlq5_10w = contadorStover > 0 ? sumaHvlq5_10w / contadorStover : 0;
    promedioTh10w = contadorStover > 0 ? sumaTh10w / contadorStover : 0;

    promedioLesiones3era = totalMuestras > 0 ? totalLesiones3era / totalMuestras : 0;
    promedioLesiones4ta = totalMuestras > 0 ? totalLesiones4ta / totalMuestras : 0;
    promedioLesiones5ta = totalMuestras > 0 ? totalLesiones5ta / totalMuestras : 0;

    porcentaje3erEstadio3era = totalMuestras > 0 ? (totalPlantas3erEstadio3era / totalMuestras) * 100 : 0;
    porcentaje3erEstadio4ta = totalMuestras > 0 ? (totalPlantas3erEstadio4ta / totalMuestras) * 100 : 0;
    porcentaje3erEstadio5ta = totalMuestras > 0 ? (totalPlantas3erEstadio5ta / totalMuestras) * 100 : 0;

    porcentajePlantasLesiones3era = totalMuestras > 0 ? (totalPlantasConLesiones3era / totalMuestras) * 100 : 0;
    porcentajePlantasLesiones4ta = totalMuestras > 0 ? (totalPlantasConLesiones4ta / totalMuestras) * 100 : 0;
    porcentajePlantasLesiones5ta = totalMuestras > 0 ? (totalPlantasConLesiones5ta / totalMuestras) * 100 : 0;

    promedioHojasFuncionales3era = totalMuestras > 0 ? totalHojas3era / totalMuestras : 0;
    promedioHojasFuncionales4ta = totalMuestras > 0 ? totalHojas4ta / totalMuestras : 0;
    promedioHojasFuncionales5ta = totalMuestras > 0 ? totalHojas5ta / totalMuestras : 0;

    promedioLetras3era = totalMuestras > 0 ? totalLetras3era / totalMuestras : 0;
    promedioLetras4ta = totalMuestras > 0 ? totalLetras4ta / totalMuestras : 0;
    promedioLetras5ta = totalMuestras > 0 ? totalLetras5ta / totalMuestras : 0;

    // Calcular Estado Evolutivo
    ee3era = promedioLesiones3era * 120 * promedioLetras3era;
    ee4ta = promedioLesiones4ta * 100 * promedioLetras4ta;
    ee5ta = promedioLesiones5ta * 80 * promedioLetras5ta;
  }

  Future<void> _guardarResumen() async {
    setState(() => isLoading = true);

    try {
      final resumenData = {
        'totalMuestras': totalMuestras,
        'totalPlantasConLesiones3era': totalPlantasConLesiones3era,
        'totalPlantasConLesiones4ta': totalPlantasConLesiones4ta,
        'totalPlantasConLesiones5ta': totalPlantasConLesiones5ta,
        'totalLesiones3era': totalLesiones3era,
        'totalLesiones4ta': totalLesiones4ta,
        'totalLesiones5ta': totalLesiones5ta,
        'totalPlantas3erEstadio3era': totalPlantas3erEstadio3era,
        'totalPlantas3erEstadio4ta': totalPlantas3erEstadio4ta,
        'totalPlantas3erEstadio5ta': totalPlantas3erEstadio5ta,
        'totalLetras3era': totalLetras3era,
        'totalLetras4ta': totalLetras4ta,
        'totalLetras5ta': totalLetras5ta,
        'promedioLesiones3era': promedioLesiones3era,
        'promedioLesiones4ta': promedioLesiones4ta,
        'promedioLesiones5ta': promedioLesiones5ta,
        'porcentaje3erEstadio3era': porcentaje3erEstadio3era,
        'porcentaje3erEstadio4ta': porcentaje3erEstadio4ta,
        'porcentaje3erEstadio5ta': porcentaje3erEstadio5ta,
        'porcentajePlantasLesiones3era': porcentajePlantasLesiones3era,
        'porcentajePlantasLesiones4ta': porcentajePlantasLesiones4ta,
        'porcentajePlantasLesiones5ta': porcentajePlantasLesiones5ta,
        'totalHojas3era': totalHojas3era,
        'totalHojas4ta': totalHojas4ta,
        'totalHojas5ta': totalHojas5ta,
        'promedioHojasFuncionales3era': promedioHojasFuncionales3era,
        'promedioHojasFuncionales4ta': promedioHojasFuncionales4ta,
        'promedioHojasFuncionales5ta': promedioHojasFuncionales5ta,
        'promedioLetras3era': promedioLetras3era,
        'promedioLetras4ta': promedioLetras4ta,
        'promedioLetras5ta': promedioLetras5ta,
      };

      final indicadoresData = {
        'ee3era': ee3era,
        'ee4ta': ee4ta,
        'ee5ta': ee5ta,
      };

      final stoverData = {
        'hvle0w': promedioHvle0w,
        'hvlq0w': promedioHvlq0w,
        'hvlq5_0w': promedioHvlq5_0w,
        'th0w': promedioTh0w,
        'hvle10w': promedioHvle10w,
        'hvlq10w': promedioHvlq10w,
        'hvlq5_10w': promedioHvlq5_10w,
        'th10w': promedioTh10w,
      };

      // Guardar en la base de datos
      final result = await _service.guardarResumenCompleto(
        widget.evaluacionId,
        resumenData,
        indicadoresData,
        stoverData,
      );

      setState(() => isLoading = false);

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${result['message']}'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${result['message']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar resumen: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 Resumen Sigatoka'),
        backgroundColor: Colors.blue[700],
        actions: [
          if (isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              tooltip: 'Guardar Resumen',
              onPressed: _guardarResumen,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildVariablesTable(),
            const SizedBox(height: 24),
            _buildEstadoEvolutivo(),
            const SizedBox(height: 24),
            _buildNivelesStoverRecomendados(),
            const SizedBox(height: 24),
            _buildStoverPromedioReal(),
          ],
        ),
      ),
    );
  }

  Widget _buildVariablesTable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.table_chart, color: Colors.blue[700], size: 24),
            const SizedBox(width: 8),
            Text(
              '📋 VARIABLES DE EVALUACIÓN',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue[700],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              // Header
              Container(
                decoration: BoxDecoration(
                  color: Colors.blue[700],
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(7)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          'Variable',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '3era.H',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '4ta.H',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '5ta.H',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: Colors.grey[300]),
              _buildTablaFila('a) Total Plantas Muestreadas', totalMuestras.toString(), totalMuestras.toString(), totalMuestras.toString(), Colors.brown[50]!),
              Divider(height: 1, color: Colors.grey[300]),
              _buildTablaFila('b) Total Plantas con Lesiones', totalMuestras.toString(), totalMuestras.toString(), totalMuestras.toString(), Colors.white),
              Divider(height: 1, color: Colors.grey[300]),
              _buildTablaFila('c) Total Lesiones', totalLesiones3era.toString(), totalLesiones4ta.toString(), totalLesiones5ta.toString(), Colors.brown[50]!),
              Divider(height: 1, color: Colors.grey[300]),
              _buildTablaFila('d) Total Plantas 3er Estadio', totalPlantas3erEstadio3era.toString(), totalPlantas3erEstadio4ta.toString(), totalPlantas3erEstadio5ta.toString(), Colors.white),
              Divider(height: 1, color: Colors.grey[300]),
              _buildTablaFila('e) Total de Letras', totalLetras3era.toString(), totalLetras4ta.toString(), totalLetras5ta.toString(), Colors.brown[50]!),
              Divider(height: 1, color: Colors.grey[300]),
              _buildTablaFilaDecimal('f) Promedio de Lesiones', promedioLesiones3era, promedioLesiones4ta, promedioLesiones5ta, Colors.white),
              Divider(height: 1, color: Colors.grey[300]),
              _buildTablaFilaDecimal('g) % Plantas 3er Estadio', porcentaje3erEstadio3era, porcentaje3erEstadio4ta, porcentaje3erEstadio5ta, Colors.brown[50]!),
              Divider(height: 1, color: Colors.grey[300]),
              _buildTablaFilaDecimal('h) % Plantas con Lesiones', porcentajePlantasLesiones3era, porcentajePlantasLesiones4ta, porcentajePlantasLesiones5ta, Colors.white),
              Divider(height: 1, color: Colors.grey[300]),
              _buildTablaFila('i) Total Hojas Funcionales', totalHojas3era.toString(), totalHojas4ta.toString(), totalHojas5ta.toString(), Colors.brown[50]!),
              Divider(height: 1, color: Colors.grey[300]),
              _buildTablaFilaDecimal('j) Promedio Hojas Func. x Planta', promedioHojasFuncionales3era, promedioHojasFuncionales4ta, promedioHojasFuncionales5ta, Colors.white),
              Divider(height: 1, color: Colors.grey[300]),
              _buildTablaFilaDecimal('k) Promedio de Letras', promedioLetras3era, promedioLetras4ta, promedioLetras5ta, Colors.brown[50]!),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEstadoEvolutivo() {
    String nivel3era = ee3era < 300 ? 'BAJO' : (ee3era < 600 ? 'MODERADO' : 'ALTO');
    Color color3era = ee3era < 300 ? Colors.green : (ee3era < 600 ? Colors.orange : Colors.red);

    String nivel4ta = ee4ta < 400 ? 'BAJO' : (ee4ta < 800 ? 'MODERADO' : 'ALTO');
    Color color4ta = ee4ta < 400 ? Colors.green : (ee4ta < 800 ? Colors.orange : Colors.red);

    String nivel5ta = ee5ta < 500 ? 'BAJO' : (ee5ta < 1000 ? 'MODERADO' : 'ALTO');
    Color color5ta = ee5ta < 500 ? Colors.green : (ee5ta < 1000 ? Colors.orange : Colors.red);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.assessment, color: Colors.red[700], size: 24),
            const SizedBox(width: 8),
            Text(
              '🔴 ESTADO EVOLUTIVO',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Table(
            border: TableBorder.symmetric(inside: BorderSide(color: Colors.grey[300]!)),
            columnWidths: const {
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(1),
              2: FlexColumnWidth(1.5),
            },
            children: [
              TableRow(
                decoration: BoxDecoration(color: Colors.blue[700]),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text('ESTADO EVOLUTIVO', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text('VALOR', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text('NIVEL', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                  ),
                ],
              ),
              TableRow(
                children: [
                  Padding(padding: const EdgeInsets.all(10.0), child: Text('3era Hoja EE = f x 120 x k', style: TextStyle(fontSize: 13))),
                  Padding(padding: const EdgeInsets.all(10.0), child: Text(ee3era.toStringAsFixed(0), textAlign: TextAlign.center, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold))),
                  Container(color: color3era, padding: const EdgeInsets.all(10.0), child: Text(nivel3era, textAlign: TextAlign.center, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white))),
                ],
              ),
              TableRow(
                children: [
                  Padding(padding: const EdgeInsets.all(10.0), child: Text('4ta Hoja EE = f x 100 x k', style: TextStyle(fontSize: 13))),
                  Padding(padding: const EdgeInsets.all(10.0), child: Text(ee4ta.toStringAsFixed(0), textAlign: TextAlign.center, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold))),
                  Container(color: color4ta, padding: const EdgeInsets.all(10.0), child: Text(nivel4ta, textAlign: TextAlign.center, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white))),
                ],
              ),
              TableRow(
                children: [
                  Padding(padding: const EdgeInsets.all(10.0), child: Text('5ta Hoja EE = f x 80 x k', style: TextStyle(fontSize: 13))),
                  Padding(padding: const EdgeInsets.all(10.0), child: Text(ee5ta.toStringAsFixed(0), textAlign: TextAlign.center, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold))),
                  Container(color: color5ta, padding: const EdgeInsets.all(10.0), child: Text(nivel5ta, textAlign: TextAlign.center, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white))),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNivelesStoverRecomendados() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.eco, color: Colors.green[700], size: 24),
            const SizedBox(width: 8),
            Text(
              '🌿 NIVELES STOVER RECOMEDADOS',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Table(
            border: TableBorder.symmetric(inside: BorderSide(color: Colors.grey[300]!)),
            columnWidths: const {
              0: FlexColumnWidth(1.5),
              1: FlexColumnWidth(1),
              2: FlexColumnWidth(1),
              3: FlexColumnWidth(1.2),
              4: FlexColumnWidth(1),
            },
            children: [
              TableRow(
                decoration: BoxDecoration(color: Colors.green[700]),
                children: [
                  Padding(padding: const EdgeInsets.all(10.0), child: Text('PLANTAS', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white))),
                  Padding(padding: const EdgeInsets.all(10.0), child: Text('H.V.L.E.', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white))),
                  Padding(padding: const EdgeInsets.all(10.0), child: Text('H.V.L.Q.', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white))),
                  Padding(padding: const EdgeInsets.all(10.0), child: Text('H.V.L.Q 5%', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white))),
                  Padding(padding: const EdgeInsets.all(10.0), child: Text('T.H.', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white))),
                ],
              ),
              TableRow(
                decoration: BoxDecoration(color: Colors.white),
                children: [
                  Padding(padding: const EdgeInsets.all(10.0), child: Text('6° Semana', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
                  Padding(padding: const EdgeInsets.all(10.0), child: Text('6,0', textAlign: TextAlign.center, style: TextStyle(fontSize: 13))),
                  Padding(padding: const EdgeInsets.all(10.0), child: Text('1,0', textAlign: TextAlign.center, style: TextStyle(fontSize: 13))),
                  Padding(padding: const EdgeInsets.all(10.0), child: Text('12,5', textAlign: TextAlign.center, style: TextStyle(fontSize: 13))),
                  Padding(padding: const EdgeInsets.all(10.0), child: Text('13,5', textAlign: TextAlign.center, style: TextStyle(fontSize: 13))),
                ],
              ),
              TableRow(
                decoration: BoxDecoration(color: Colors.grey[50]),
                children: [
                  Padding(padding: const EdgeInsets.all(10.0), child: Text('10° Semana', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
                  Padding(padding: const EdgeInsets.all(10.0), child: Text('0,0', textAlign: TextAlign.center, style: TextStyle(fontSize: 13))),
                  Padding(padding: const EdgeInsets.all(10.0), child: Text('5,0', textAlign: TextAlign.center, style: TextStyle(fontSize: 13))),
                  Padding(padding: const EdgeInsets.all(10.0), child: Text('8,5', textAlign: TextAlign.center, style: TextStyle(fontSize: 13))),
                  Padding(padding: const EdgeInsets.all(10.0), child: Text('9,0', textAlign: TextAlign.center, style: TextStyle(fontSize: 13))),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStoverPromedioReal() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.analytics, color: Colors.teal[700], size: 24),
            const SizedBox(width: 8),
            Text(
              '📊 STOVER PROMEDIO REAL',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.teal[700],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Table(
            border: TableBorder.symmetric(inside: BorderSide(color: Colors.grey[300]!)),
            columnWidths: const {
              0: FlexColumnWidth(1.5),
              1: FlexColumnWidth(1),
              2: FlexColumnWidth(1),
              3: FlexColumnWidth(1.2),
              4: FlexColumnWidth(1),
            },
            children: [
              TableRow(
                decoration: BoxDecoration(color: Colors.teal[700]),
                children: [
                  Padding(padding: const EdgeInsets.all(10.0), child: Text('PLANTAS', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white))),
                  Padding(padding: const EdgeInsets.all(10.0), child: Text('H.V.L.E.', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white))),
                  Padding(padding: const EdgeInsets.all(10.0), child: Text('H.V.L.Q.', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white))),
                  Padding(padding: const EdgeInsets.all(10.0), child: Text('H.V.L.Q 5%', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white))),
                  Padding(padding: const EdgeInsets.all(10.0), child: Text('T.H.', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white))),
                ],
              ),
              TableRow(
                decoration: BoxDecoration(color: Colors.white),
                children: [
                  Padding(padding: const EdgeInsets.all(10.0), child: Text('6° Semana', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
                  Padding(padding: const EdgeInsets.all(10.0), child: Text(promedioHvle0w.toStringAsFixed(1), textAlign: TextAlign.center, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold))),
                  Padding(padding: const EdgeInsets.all(10.0), child: Text(promedioHvlq0w.toStringAsFixed(1), textAlign: TextAlign.center, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold))),
                  Padding(padding: const EdgeInsets.all(10.0), child: Text(promedioHvlq5_0w.toStringAsFixed(1), textAlign: TextAlign.center, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold))),
                  Padding(padding: const EdgeInsets.all(10.0), child: Text(promedioTh0w.toStringAsFixed(1), textAlign: TextAlign.center, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold))),
                ],
              ),
              TableRow(
                decoration: BoxDecoration(color: Colors.grey[50]),
                children: [
                  Padding(padding: const EdgeInsets.all(10.0), child: Text('10° Semana', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
                  Padding(padding: const EdgeInsets.all(10.0), child: Text(promedioHvle10w.toStringAsFixed(1), textAlign: TextAlign.center, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold))),
                  Padding(padding: const EdgeInsets.all(10.0), child: Text(promedioHvlq10w.toStringAsFixed(1), textAlign: TextAlign.center, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold))),
                  Padding(padding: const EdgeInsets.all(10.0), child: Text(promedioHvlq5_10w.toStringAsFixed(1), textAlign: TextAlign.center, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold))),
                  Padding(padding: const EdgeInsets.all(10.0), child: Text(promedioTh10w.toStringAsFixed(1), textAlign: TextAlign.center, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold))),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTablaFila(String label, String val3era, String val4ta, String val5ta, Color bgColor) {
    return Container(
      color: bgColor,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(label, style: const TextStyle(fontSize: 13)),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(val3era, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(val4ta, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(val5ta, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTablaFilaDecimal(String label, double val3era, double val4ta, double val5ta, Color bgColor) {
    return Container(
      color: bgColor,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(label, style: const TextStyle(fontSize: 13)),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(val3era.toStringAsFixed(2), textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(val4ta.toStringAsFixed(2), textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(val5ta.toStringAsFixed(2), textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
