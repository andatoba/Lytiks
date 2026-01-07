import 'package:flutter/material.dart';

class SigatokaSelectClienteScreen extends StatelessWidget {
  final Function(String clienteId) onClienteSelected;
  const SigatokaSelectClienteScreen({super.key, required this.onClienteSelected});

  @override
  Widget build(BuildContext context) {
    // TODO: Reemplazar por llamada real a API de clientes
    final clientes = [
      {'id': '1', 'nombre': 'Hacienda La Esperanza'},
      {'id': '2', 'nombre': 'Finca El Progreso'},
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Cliente'),
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
      ),
      body: ListView.separated(
        itemCount: clientes.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final cliente = clientes[index];
          return ListTile(
            title: Text(cliente['nombre']!),
            leading: const Icon(Icons.account_circle, color: Color(0xFF2563EB)),
            onTap: () => onClienteSelected(cliente['id']!),
          );
        },
      ),
    );
  }
}
