package com.lytiks.backend.util;

import java.time.LocalDate;
import java.time.temporal.IsoFields;
import java.time.temporal.WeekFields;
import java.util.Locale;

/**
 * Utilidades para cálculos de fechas en Sigatoka
 */
public class SigatokaDateUtil {
    
    /**
     * Obtiene la semana epidemiológica ISO 8601
     * @param fecha Fecha para calcular la semana
     * @return Número de semana ISO (1-53)
     */
    public static int getSemanaEpidemiologicaISO(LocalDate fecha) {
        return fecha.get(IsoFields.WEEK_OF_WEEK_BASED_YEAR);
    }
    
    /**
     * Calcula el período como "Semana X del Mes Y"
     * @param fecha Fecha para calcular el período
     * @return String con el formato "Semana 1 del Mes", "Semana 2 del Mes", etc.
     */
    public static String getPeriodoSemanaDelMes(LocalDate fecha) {
        // Obtener el día del mes
        int diaDelMes = fecha.getDayOfMonth();
        
        // Calcular la semana del mes (1-5)
        int semanaDelMes = ((diaDelMes - 1) / 7) + 1;
        
        // Obtener el nombre del mes en español
        String mes = getMesEnEspanol(fecha.getMonthValue());
        
        return String.format("Semana %d de %s", semanaDelMes, mes);
    }
    
    /**
     * Obtiene la semana del mes (1-5)
     * @param fecha Fecha para calcular
     * @return Número de semana del mes
     */
    public static int getSemanaDelMes(LocalDate fecha) {
        int diaDelMes = fecha.getDayOfMonth();
        return ((diaDelMes - 1) / 7) + 1;
    }
    
    /**
     * Obtiene el nombre del mes en español
     * @param numeroMes Número del mes (1-12)
     * @return Nombre del mes en español
     */
    public static String getMesEnEspanol(int numeroMes) {
        String[] meses = {
            "Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio",
            "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"
        };
        return meses[numeroMes - 1];
    }
    
    /**
     * Obtiene el año de la semana ISO
     * @param fecha Fecha para calcular
     * @return Año de la semana ISO
     */
    public static int getAnioSemanaISO(LocalDate fecha) {
        return fecha.get(IsoFields.WEEK_BASED_YEAR);
    }
    
    /**
     * Formatea una fecha completa con semana ISO y período
     * @param fecha Fecha para formatear
     * @return String con formato: "Semana ISO: X, Período: Semana Y de Mes"
     */
    public static String getFormatoCompleto(LocalDate fecha) {
        int semanaISO = getSemanaEpidemiologicaISO(fecha);
        String periodo = getPeriodoSemanaDelMes(fecha);
        return String.format("Semana ISO: %d, Período: %s", semanaISO, periodo);
    }
}
