import 'package:flutter/material.dart';

class SigatokaResultadoScreen extends StatelessWidget {
  final String evaluacionId;
  const SigatokaResultadoScreen({super.key, required this.evaluacionId});

  @override
  Widget build(BuildContext context) {
    // TODO: Visualización de cálculos, tablas, estado evolutivo y colores
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultados Sigatoka'),
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Text('Resultados para evaluación $evaluacionId'),
      ),
    );
  }
}
