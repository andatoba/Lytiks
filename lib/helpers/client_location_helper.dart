class ClientLocationHelper {
  const ClientLocationHelper._();

  static int? toInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is String) {
      return int.tryParse(value);
    }
    return int.tryParse(value?.toString() ?? '');
  }

  static String formatClientName(
    Map<String, dynamic> client, {
    String fallback = '',
  }) {
    final nombre = client['nombre']?.toString().trim() ?? '';
    final apellidos = client['apellidos']?.toString().trim() ?? '';
    final fullName = '$nombre $apellidos'.trim();
    if (fullName.isNotEmpty) {
      return fullName;
    }

    final nombres = client['nombres']?.toString().trim() ?? '';
    if (nombres.isNotEmpty) {
      return nombres;
    }

    return fallback;
  }

  static String formatFincaName(Map<String, dynamic> client) {
    return client['fincaNombre']?.toString().trim() ??
        client['nombreFinca']?.toString().trim() ??
        client['finca_nombre']?.toString().trim() ??
        client['hacienda']?.toString().trim() ??
        '';
  }

  static int? resolveClienteId(Map<String, dynamic> client) {
    return toInt(client['clienteId']) ??
        toInt(client['id']) ??
        toInt(client['clientId']);
  }

  static String formatHaciendaName(Map<String, dynamic> hacienda) {
    return hacienda['nombre']?.toString().trim() ?? '';
  }

  static String formatLoteName(
    Map<String, dynamic> lote, {
    bool includeCodeWhenAvailable = false,
  }) {
    final codigo = lote['codigo']?.toString().trim() ?? '';
    final nombre = lote['nombre']?.toString().trim() ?? '';
    if (includeCodeWhenAvailable && nombre.isNotEmpty && codigo.isNotEmpty) {
      return '$nombre ($codigo)';
    }
    return nombre.isNotEmpty ? nombre : codigo;
  }

  static int? resolveInitialHaciendaId({
    required List<Map<String, dynamic>> haciendas,
    required String currentHaciendaText,
    int? preferredHaciendaId,
  }) {
    if (preferredHaciendaId != null &&
        haciendas.any((hacienda) => toInt(hacienda['id']) == preferredHaciendaId)) {
      return preferredHaciendaId;
    }

    final currentHacienda = currentHaciendaText.trim().toLowerCase();
    if (currentHacienda.isNotEmpty) {
      for (final hacienda in haciendas) {
        if (formatHaciendaName(hacienda).toLowerCase() == currentHacienda) {
          return toInt(hacienda['id']);
        }
      }
    }

    if (haciendas.isNotEmpty) {
      return toInt(haciendas.first['id']);
    }

    return null;
  }

  static int? resolveInitialLoteId({
    required List<Map<String, dynamic>> lotes,
    required String currentLoteText,
    int? preferredLoteId,
    bool includeCodeWhenAvailable = false,
  }) {
    if (preferredLoteId != null &&
        lotes.any((lote) => toInt(lote['id']) == preferredLoteId)) {
      return preferredLoteId;
    }

    final currentLote = currentLoteText.trim().toLowerCase();
    if (currentLote.isNotEmpty) {
      for (final lote in lotes) {
        if (formatLoteName(
                  lote,
                  includeCodeWhenAvailable: includeCodeWhenAvailable,
                ).toLowerCase() ==
                currentLote ||
            (lote['nombre']?.toString().trim().toLowerCase() ?? '') ==
                currentLote ||
            (lote['codigo']?.toString().trim().toLowerCase() ?? '') ==
                currentLote) {
          return toInt(lote['id']);
        }
      }
    }

    if (lotes.isNotEmpty) {
      return toInt(lotes.first['id']);
    }

    return null;
  }
}
