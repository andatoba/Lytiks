/// Utilidad para calcular semana epidemiológica ISO y período del mes
class SigatokaDateUtil {
  /// Obtiene la semana epidemiológica ISO 8601
  static int getSemanaEpidemiologicaISO(DateTime fecha) {
    // Obtener el día del año
    int dayOfYear = fecha.difference(DateTime(fecha.year, 1, 1)).inDays + 1;
    
    // Encuentra el primer jueves del año
    DateTime firstThursday = DateTime(fecha.year, 1, 1);
    while (firstThursday.weekday != DateTime.thursday) {
      firstThursday = firstThursday.add(const Duration(days: 1));
    }
    
    // Calcula la semana ISO
    int weekNumber = ((dayOfYear - firstThursday.day + 10) / 7).floor();
    
    // Verifica si pertenece al año anterior o siguiente
    if (weekNumber < 1) {
      return 52; // Última semana del año anterior
    } else if (weekNumber > 52) {
      return 1; // Primera semana del siguiente año
    }
    
    return weekNumber;
  }
  
  /// Calcula el período como "Semana X de Mes Y"
  static String getPeriodoSemanaDelMes(DateTime fecha) {
    final int diaDelMes = fecha.day;
    final int semanaDelMes = ((diaDelMes - 1) ~/ 7) + 1;
    final String mes = getMesEnEspanol(fecha.month);
    
    return 'Semana $semanaDelMes de $mes';
  }
  
  /// Obtiene la semana del mes (1-5)
  static int getSemanaDelMes(DateTime fecha) {
    final int diaDelMes = fecha.day;
    return ((diaDelMes - 1) ~/ 7) + 1;
  }
  
  /// Obtiene el nombre del mes en español
  static String getMesEnEspanol(int numeroMes) {
    const List<String> meses = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return meses[numeroMes - 1];
  }
  
  /// Formatea una fecha completa con semana ISO y período
  static String getFormatoCompleto(DateTime fecha) {
    final int semanaISO = getSemanaEpidemiologicaISO(fecha);
    final String periodo = getPeriodoSemanaDelMes(fecha);
    return 'Semana ISO: $semanaISO, Período: $periodo';
  }
}
