import 'package:flutter/material.dart';

class ProductiveIndicatorsScreen extends StatelessWidget {
  final Map<String, dynamic>? clientData;

  const ProductiveIndicatorsScreen({super.key, this.clientData});

  @override
  Widget build(BuildContext context) {
    final clientName =
        '${clientData?['nombre'] ?? ''} ${clientData?['apellidos'] ?? ''}'
            .trim();
    final finca = (clientData?['fincaNombre'] ??
            clientData?['nombreFinca'] ??
            'Sin finca seleccionada')
        .toString();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Indicadores productivos'),
        backgroundColor: const Color(0xFF00903E),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF004B63), Color(0xFF00903E)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nuevo modulo',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Indicadores productivos',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  clientName.isEmpty
                      ? 'Puede abrir este modulo sin cliente y luego completar los indicadores.'
                      : 'Cliente actual: $clientName\nFinca: $finca',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _IndicatorCard(
            title: 'Rendimiento esperado',
            value: '--',
            subtitle: 'Espacio listo para cargar cajas, racimos o toneladas.',
            color: const Color(0xFF004B63),
            icon: Icons.insights,
          ),
          const SizedBox(height: 12),
          _IndicatorCard(
            title: 'Eficiencia de seleccion',
            value: '--',
            subtitle: 'Puede conectarse luego con la auditoria de campo.',
            color: const Color(0xFF00903E),
            icon: Icons.track_changes,
          ),
          const SizedBox(height: 12),
          _IndicatorCard(
            title: 'Estado del modulo',
            value: 'Inicial',
            subtitle: 'Tarjeta y pantalla habilitadas para seguir creciendo.',
            color: const Color(0xFFFF9800),
            icon: Icons.construction,
          ),
        ],
      ),
    );
  }
}

class _IndicatorCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color color;
  final IconData icon;

  const _IndicatorCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF004B63),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Colors.black54)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
