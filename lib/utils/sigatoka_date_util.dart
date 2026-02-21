/// Utilidad para calcular semana epidemiológica ISO y período del mes
class SigatokaDateUtil {
  /// Obtiene la semana epidemiológica ISO 8601
  /// La semana 1 es aquella que contiene el primer jueves del año
  /// Las semanas empiezan en lunes
  static int getSemanaEpidemiologicaISO(DateTime fecha) {
    // Encontrar el lunes de la semana actual
    // En Dart: Monday = 1, Sunday = 7
    int diasDesdeElLunes = fecha.weekday - 1;
    DateTime lunesDeLaSemana = fecha.subtract(Duration(days: diasDesdeElLunes));
    
    // Encontrar el primer jueves del año
    // La semana 1 es la que contiene el primer jueves
    DateTime primerEnero = DateTime(lunesDeLaSemana.year, 1, 1);
    int diasHastaJueves = (DateTime.thursday - primerEnero.weekday + 7) % 7;
    DateTime primerJueves = primerEnero.add(Duration(days: diasHastaJueves));
    
    // Encontrar el lunes de la semana del primer jueves
    DateTime lunesDeSemana1 = primerJueves.subtract(Duration(days: primerJueves.weekday - 1));
    
    // Si la fecha es antes del lunes de la semana 1, pertenece al año anterior
    if (lunesDeLaSemana.isBefore(lunesDeSemana1)) {
      // Calcular semana del año anterior
      return getSemanaEpidemiologicaISO(DateTime(lunesDeLaSemana.year - 1, 12, 28));
    }
    
    // Calcular número de semana
    int diasDesdeSemana1 = lunesDeLaSemana.difference(lunesDeSemana1).inDays;
    int numeroSemana = (diasDesdeSemana1 / 7).floor() + 1;
    
    // Si es semana 53, verificar si realmente existe o es semana 1 del siguiente año
    if (numeroSemana == 53) {
      DateTime primerEneroSiguiente = DateTime(lunesDeLaSemana.year + 1, 1, 1);
      int diasHastaJuevesSiguiente = (DateTime.thursday - primerEneroSiguiente.weekday + 7) % 7;
      DateTime primerJuevesSiguiente = primerEneroSiguiente.add(Duration(days: diasHastaJuevesSiguiente));
      DateTime lunesDeSemana1Siguiente = primerJuevesSiguiente.subtract(Duration(days: primerJuevesSiguiente.weekday - 1));
      
      if (lunesDeLaSemana.isAtSameMomentAs(lunesDeSemana1Siguiente) || 
          lunesDeLaSemana.isAfter(lunesDeSemana1Siguiente)) {
        return 1;
      }
    }
    
    return numeroSemana;
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
