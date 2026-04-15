import 'package:flutter/material.dart';

import 'agrotecban_moko_muestra_form.dart';

class AgrotecbanMokoMuestrasScreen extends StatelessWidget {
  final Map<String, dynamic>? clientData;

  const AgrotecbanMokoMuestrasScreen({
    super.key,
    this.clientData,
  });

  String _clienteLabel() {
    final cliente = clientData?['cliente']?.toString().trim() ?? '';
    return cliente.isEmpty ? 'Sin cliente seleccionado' : cliente;
  }

  String _loteLabel() {
    final lote = clientData?['lote']?.toString().trim() ?? '';
    return lote.isEmpty ? 'Sin lote seleccionado' : lote;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF00695C),
        foregroundColor: Colors.white,
        title: const Text('Toma de muestras'),
      ),
      backgroundColor: const Color(0xFFF7FAF2),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFD4E5D7)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Contexto seleccionado',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('Cliente: ${_clienteLabel()}'),
                const SizedBox(height: 4),
                Text('Lote: ${_loteLabel()}'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _MuestraOptionCard(
            title: 'Toma muestra areas libres',
            subtitle:
                'Registrar la toma realizada en zonas libres del lote seleccionado.',
            icon: Icons.eco_outlined,
            color: const Color(0xFF2E7D32),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AgrotecbanMokoMuestraFormScreen(
                    clientData: clientData,
                    tipoMuestra: 'AREA_LIBRE',
                    titulo: 'Toma muestra areas libres',
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _MuestraOptionCard(
            title: 'Toma de muestra en foco',
            subtitle:
                'Registrar la toma realizada directamente sobre un foco del lote.',
            icon: Icons.location_searching_outlined,
            color: const Color(0xFFC62828),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AgrotecbanMokoMuestraFormScreen(
                    clientData: clientData,
                    tipoMuestra: 'FOCO',
                    titulo: 'Toma de muestra en foco',
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MuestraOptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _MuestraOptionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.25)),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: color),
            ],
          ),
        ),
      ),
    );
  }
}
