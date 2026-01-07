import 'package:flutter/material.dart';

class SigatokaMuestrasScreen extends StatelessWidget {
  final String evaluacionId;
  const SigatokaMuestrasScreen({super.key, required this.evaluacionId});

  @override
  Widget build(BuildContext context) {
    // TODO: Formulario para ingresar muestras y variables manuales
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ingreso de Muestras'),
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Text('Ingreso de muestras para evaluación $evaluacionId'),
      ),
    );
  }
}
