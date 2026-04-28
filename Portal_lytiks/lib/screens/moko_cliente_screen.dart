// Archivo eliminado, no corresponde a la app principal.

import 'package:flutter/material.dart';
import 'package:lytiks/screens/registro_moko_screen.dart';
import 'package:lytiks/screens/lista_focos_screen.dart';
import 'package:lytiks/screens/plan_seguimiento_moko_screen.dart';

class MokoClienteScreen extends StatelessWidget {
  const MokoClienteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Módulo Moko'),
        backgroundColor: Color(0xFFE53E3E),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.add_circle_outline, color: Color(0xFFE53E3E)),
              title: const Text('Registrar nuevo foco'),
              subtitle: const Text('Crear un nuevo registro de foco de Moko'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegistroMokoScreen()),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.list_alt, color: Color(0xFF38A169)),
              title: const Text('Lista de focos'),
              subtitle: const Text('Ver y gestionar focos registrados'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ListaFocosScreen()),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.assignment_turned_in, color: Color(0xFF2563EB)),
              title: const Text('Plan de seguimiento'),
              subtitle: const Text('Ver y gestionar planes de seguimiento'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PlanSeguimientoMokoScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:lytiks/screens/registro_moko_screen.dart';
import 'package:lytiks/screens/lista_focos_screen.dart';
import 'package:lytiks/screens/plan_seguimiento_moko_screen.dart';

class MokoClienteScreen extends StatelessWidget {
  const MokoClienteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Módulo Moko'),
        backgroundColor: Color(0xFFE53E3E),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.add_circle_outline, color: Color(0xFFE53E3E)),
              title: const Text('Registrar nuevo foco'),
              subtitle: const Text('Crear un nuevo registro de foco de Moko'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegistroMokoScreen()),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.list_alt, color: Color(0xFF38A169)),
              title: const Text('Lista de focos'),
              subtitle: const Text('Ver y gestionar focos registrados'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ListaFocosScreen()),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.assignment_turned_in, color: Color(0xFF2563EB)),
              title: const Text('Plan de seguimiento'),
              subtitle: const Text('Ver y gestionar planes de seguimiento'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PlanSeguimientoMokoScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
