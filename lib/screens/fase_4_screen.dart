import 'package:flutter/material.dart';
import '../services/plan_seguimiento_moko_service.dart';
import 'fase_detalle_screen.dart';

class Fase4Screen extends StatefulWidget {
  final Map<String, dynamic> fase;
  final Map<String, dynamic>? ejecucion;
  final int focoId;
  final PlanSeguimientoMokoService service;

  const Fase4Screen({
    super.key,
    required this.fase,
    this.ejecucion,
    required this.focoId,
    required this.service,
  });

  @override
  State<Fase4Screen> createState() => _Fase4ScreenState();
}

class _Fase4ScreenState extends State<Fase4Screen> {
  String? _observacionesOverride;

  @override
  void initState() {
    super.initState();
    _observacionesOverride = widget.ejecucion?['observaciones']?.toString();
  }

  void _actualizarObservaciones(String observaciones) {
    setState(() {
      _observacionesOverride = observaciones;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 1,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: const Color(0xFFC62828),
          foregroundColor: Colors.white,
          elevation: 0,
          title: Text('Fase 4 - ${widget.fase['nombre'] ?? ''}'),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Detalles'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            FaseDetalleScreen(
              fase: widget.fase,
              ejecucion: widget.ejecucion,
              focoId: widget.focoId,
              service: widget.service,
              observacionesOverride: _observacionesOverride,
              embedded: true,
            ),
          ],
        ),
      ),
    );
  }
}
