// Script para corregir la codificación UTF-8 en todos los servicios
// Ejecutar con: dart fix_utf8_services.dart

import 'dart:io';

void main() {
  final servicios = [
    'lib/services/hacienda_service.dart',
    'lib/services/lote_service.dart',
    'lib/services/logo_service.dart',
    'lib/services/audit_categoria_service.dart',
    'lib/services/sigatoka_evaluacion_service.dart',
    'lib/services/sigatoka_service.dart',
    'lib/services/seguimiento_moko_service.dart',
  ];

  for (final servicio in servicios) {
    final file = File(servicio);
    if (!file.existsSync()) {
      print('❌ No existe: $servicio');
      continue;
    }

    String content = file.readAsStringSync();
    
    // Reemplazar json.decode(response.body) por jsonDecode(utf8.decode(response.bodyBytes))
    content = content.replaceAll(
      'json.decode(response.body)',
      'jsonDecode(utf8.decode(response.bodyBytes))'
    );
    
    // Asegurar que json.encode siga sin cambios (ya está bien)
    // Agregar import de dart:convert si no está
    if (!content.contains("import 'dart:convert';")) {
      content = "import 'dart:convert';\n$content";
    }
    
    file.writeAsStringSync(content);
    print('✅ Corregido: $servicio');
  }
  
  print('\n✅ Proceso completado. Ahora las tildes deberían mostrarse correctamente.');
}
