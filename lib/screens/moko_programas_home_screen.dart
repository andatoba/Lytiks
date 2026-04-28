import 'package:flutter/material.dart';

import 'agrotecban_moko_contencion.dart';
import 'agrotecban_moko_preventivo.dart';

class MokoProgramasHomeScreen extends StatelessWidget {
  final Map<String, dynamic>? clientData;

  const MokoProgramasHomeScreen({
    super.key,
    this.clientData,
  });

  String _buildClientLabel() {
    if (clientData == null) {
      return 'Sin cliente seleccionado';
    }

    final nombre = clientData!['nombre']?.toString() ?? '';
    final apellidos = clientData!['apellidos']?.toString() ?? '';
    final fullName = '$nombre $apellidos'.trim();

    return fullName.isEmpty ? 'Cliente seleccionado' : fullName;
  }

  int? _resolveFocoId() {
    final dynamic focoId = clientData?['focoId'];
    if (focoId is int) return focoId;
    if (focoId is String) return int.tryParse(focoId);
    return null;
  }

  int? _resolveNumeroFoco() {
    final dynamic numeroFoco =
        clientData?['numeroFoco'] ?? clientData?['numero_foco'];
    if (numeroFoco is int) return numeroFoco;
    if (numeroFoco is String) return int.tryParse(numeroFoco);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF00903E),
        foregroundColor: Colors.white,
        title: const Text('Moko - Programas'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFB7DDBA)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Flujo sugerido',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 6),
                const Text('1) Completar Moko Preventivo'),
                const Text('2) Continuar con Moko Contencion'),
                const SizedBox(height: 8),
                Text(
                  'Cliente: ${_buildClientLabel()}',
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildOptionCard(
            context,
            title: 'Moko Preventivo',
            subtitle:
                'Paso 1: checklist de ciclos, dosis y alertas por atraso.',
            icon: Icons.fact_check,
            color: const Color(0xFF2E7D32),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AgrotecbanMokoPreventivoScreen(
                    focoId: _resolveFocoId(),
                    numeroFoco: _resolveNumeroFoco(),
                    clientData: clientData,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildOptionCard(
            context,
            title: 'Moko Contencion',
            subtitle:
                'Paso 2: bioseguridad, fases 1-3, auditoria por foco y evidencias.',
            icon: Icons.shield,
            color: const Color(0xFFC62828),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AgrotecbanMokoContencionScreen(
                    focoId: _resolveFocoId(),
                    numeroFoco: _resolveNumeroFoco(),
                    clientData: clientData,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.35), width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.12),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: color,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: color),
            ],
          ),
        ),
      ),
    );
  }
}
