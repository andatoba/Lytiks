package com.lytiks.backend.service;

import com.lytiks.backend.entity.*;
import com.lytiks.backend.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import lombok.extern.slf4j.Slf4j;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.*;

/**
 * Servicio de cálculo completo para evaluaciones de Sigatoka
 * Implementa TODAS las fórmulas del formato Excel
 */
@Service
@Slf4j
@Transactional
public class SigatokaCalculationServiceCompleto {
    
    private static final int SCALE = 2;
    private static final RoundingMode ROUNDING = RoundingMode.HALF_UP;
    
    @Autowired
    private SigatokaResumenRepository resumenRepository;
    
    @Autowired
    private SigatokaIndicadoresRepository indicadoresRepository;
    
    @Autowired
    private SigatokaEstadoEvolutivoRepository estadoEvolutivoRepository;
    
    @Autowired
    private SigatokaMuestraCompletaRepository muestraRepository;
    
    /**
     * Calcula TODOS los indicadores de una evaluación
     */
    public void calcularTodo(Long evaluacionId) {
        log.info("===== INICIANDO CÁLCULOS COMPLETOS PARA EVALUACIÓN {} =====", evaluacionId);
        
        // 1. Obtener todas las muestras
        List<SigatokaMuestraCompleta> muestras = muestraRepository.findByLote_EvaluacionIdOrderByMuestraNumAsc(evaluacionId);
        
        if (muestras.isEmpty()) {
            log.warn("No hay muestras para calcular");
            return;
        }
        
        // 2. Calcular promedios básicos (a-e)
        SigatokaResumen resumen = calcularPromediosBasicos(evaluacionId, muestras);
        log.info("✓ Promedios básicos (a-e) calculados");
        
        // 3. Calcular indicadores (f-k)
        SigatokaIndicadores indicadores = calcularIndicadores(evaluacionId, resumen, muestras);
        log.info("✓ Indicadores (f-k) calculados");
        
        // 4. Calcular Estado Evolutivo (EE)
        SigatokaEstadoEvolutivo estadoEvolutivo = calcularEstadoEvolutivo(evaluacionId, indicadores);
        log.info("✓ Estado Evolutivo (EE) calculado");
        
        // 5. Calcular promedios Stover
        calcularStoverPromedios(evaluacionId, muestras);
        log.info("✓ Promedios Stover calculados");
        
        log.info("===== CÁLCULOS COMPLETADOS =====");
    }
    
    /**
     * SECCIÓN 3: Calcula promedios básicos (a-e)
     */
    public SigatokaResumen calcularPromediosBasicos(Long evaluacionId, List<SigatokaMuestraCompleta> muestras) {
        log.debug("Calculando promedios básicos (a-e)");
        
        int totalMuestras = muestras.size();
        
        // a) Total plantas muestreadas (suma)
        double sumPlantasMuestreadas = muestras.stream()
            .mapToInt(m -> m.getPlantasMuestreadas() != null ? m.getPlantasMuestreadas() : 0)
            .sum();
        double promedioA = totalMuestras > 0 ? sumPlantasMuestreadas / totalMuestras : 0;
        
        // b) Total plantas con lesiones
        double sumPlantasLesiones = muestras.stream()
            .mapToInt(m -> m.getPlantasConLesiones() != null ? m.getPlantasConLesiones() : 0)
            .sum();
        double promedioB = totalMuestras > 0 ? sumPlantasLesiones / totalMuestras : 0;
        
        // c) Total lesiones
        double sumLesiones = muestras.stream()
            .mapToInt(m -> m.getTotalLesiones() != null ? m.getTotalLesiones() : 0)
            .sum();
        double promedioC = totalMuestras > 0 ? sumLesiones / totalMuestras : 0;
        
        // d) Total plantas con 3er estadio
        double sumPlantas3er = muestras.stream()
            .mapToInt(m -> m.getPlantas3erEstadio() != null ? m.getPlantas3erEstadio() : 0)
            .sum();
        double promedioD = totalMuestras > 0 ? sumPlantas3er / totalMuestras : 0;
        
        // e) Total letras
        double sumLetras = muestras.stream()
            .mapToInt(m -> m.getTotalLetras() != null ? m.getTotalLetras() : 0)
            .sum();
        double promedioE = totalMuestras > 0 ? sumLetras / totalMuestras : 0;
        
        // Guardar en base de datos
        SigatokaResumen resumen = resumenRepository.findByEvaluacionId(evaluacionId)
            .orElse(new SigatokaResumen());
        
        SigatokaEvaluacion evaluacion = new SigatokaEvaluacion();
        evaluacion.setId(evaluacionId);
        resumen.setEvaluacion(evaluacion);
        
        resumen.setPromedioHojasEmitidas(BigDecimal.valueOf(promedioA).setScale(SCALE, ROUNDING));
        resumen.setPromedioHojasErectas(BigDecimal.valueOf(promedioB).setScale(SCALE, ROUNDING));
        resumen.setPromedioHojasSintomas(BigDecimal.valueOf(promedioC).setScale(SCALE, ROUNDING));
        resumen.setPromedioHojaJovenEnferma(BigDecimal.valueOf(promedioD).setScale(SCALE, ROUNDING));
        resumen.setPromedioHojaJovenNecrosada(BigDecimal.valueOf(promedioE).setScale(SCALE, ROUNDING));
        
        return resumenRepository.save(resumen);
    }
    
    /**
     * SECCIÓN 3: Calcula indicadores (f-k)
     */
    public SigatokaIndicadores calcularIndicadores(Long evaluacionId, SigatokaResumen resumen, List<SigatokaMuestraCompleta> muestras) {
        log.debug("Calculando indicadores (f-k)");
        
        double a = resumen.getPromedioHojasEmitidas().doubleValue(); // Plantas muestreadas
        double b = resumen.getPromedioHojasErectas().doubleValue(); // Plantas con lesiones
        double c = resumen.getPromedioHojasSintomas().doubleValue(); // Total lesiones
        double d = resumen.getPromedioHojaJovenEnferma().doubleValue(); // Plantas 3er estadio
        double e = resumen.getPromedioHojaJovenNecrosada().doubleValue(); // Total letras
        
        // f) Promedio de lesiones por planta = c / a
        double f = a > 0 ? c / a : 0;
        
        // g) % de plantas con 3eros estadios = (d / b) * 100
        double g = b > 0 ? (d / b) * 100 : 0;
        
        // h) % de plantas con lesiones = (b / a) * 100
        double h = a > 0 ? (b / a) * 100 : 0;
        
        // i) Total hojas funcionales (suma de todas las hojas sin necrosis)
        double i = muestras.stream()
            .mapToInt(m -> {
                int hojas3 = m.getTotalHojas3era() != null ? m.getTotalHojas3era() : 0;
                int hojas4 = m.getTotalHojas4ta() != null ? m.getTotalHojas4ta() : 0;
                int hojas5 = m.getTotalHojas5ta() != null ? m.getTotalHojas5ta() : 0;
                return hojas3 + hojas4 + hojas5;
            })
            .average()
            .orElse(0);
        
        // j) Hojas funcionales / plantas
        double j = a > 0 ? i / a : 0;
        
        // k) Promedio de letras = e / a
        double k = a > 0 ? e / a : 0;
        
        // Guardar en base de datos
        SigatokaIndicadores indicadores = indicadoresRepository.findByEvaluacionId(evaluacionId)
            .orElse(new SigatokaIndicadores());
        
        SigatokaEvaluacion evaluacion = new SigatokaEvaluacion();
        evaluacion.setId(evaluacionId);
        indicadores.setEvaluacion(evaluacion);
        
        indicadores.setIncidenciaPromedio(BigDecimal.valueOf(f).setScale(SCALE, ROUNDING));
        indicadores.setSeveridadPromedio(BigDecimal.valueOf(g).setScale(SCALE, ROUNDING));
        indicadores.setIndiceHojasErectas(BigDecimal.valueOf(h).setScale(SCALE, ROUNDING));
        indicadores.setRitmoEmision(BigDecimal.valueOf(i).setScale(SCALE, ROUNDING));
        indicadores.setVelocidadEvolucion(BigDecimal.valueOf(j).setScale(SCALE, ROUNDING));
        indicadores.setVelocidadNecrosis(BigDecimal.valueOf(k).setScale(SCALE, ROUNDING));
        
        return indicadoresRepository.save(indicadores);
    }
    
    /**
     * SECCIÓN 5: Calcula Estado Evolutivo (EE)
     */
    public SigatokaEstadoEvolutivo calcularEstadoEvolutivo(Long evaluacionId, SigatokaIndicadores indicadores) {
        log.debug("Calculando Estado Evolutivo");
        
        double f = indicadores.getIncidenciaPromedio().doubleValue();
        double k = indicadores.getVelocidadNecrosis().doubleValue();
        
        // Fórmulas del Excel:
        // 3era Hoja EE = f × 120 × k
        double ee3era = f * 120 * k;
        
        // 4ta Hoja EE = f × 100 × k
        double ee4ta = f * 100 * k;
        
        // 5ta Hoja EE = f × 80 × k
        double ee5ta = f * 80 * k;
        
        // Determinar nivel de infección según rangos
        String nivelInfeccion = determinarNivelInfeccion(ee3era, ee4ta, ee5ta);
        
        // Guardar en base de datos
        SigatokaEstadoEvolutivo estado = estadoEvolutivoRepository.findByEvaluacionId(evaluacionId)
            .orElse(new SigatokaEstadoEvolutivo());
        
        SigatokaEvaluacion evaluacion = new SigatokaEvaluacion();
        evaluacion.setId(evaluacionId);
        estado.setEvaluacion(evaluacion);
        
        estado.setEe3eraHoja(BigDecimal.valueOf(ee3era).setScale(SCALE, ROUNDING));
        estado.setEe4taHoja(BigDecimal.valueOf(ee4ta).setScale(SCALE, ROUNDING));
        estado.setEe5taHoja(BigDecimal.valueOf(ee5ta).setScale(SCALE, ROUNDING));
        estado.setNivelInfeccion(nivelInfeccion);
        
        return estadoEvolutivoRepository.save(estado);
    }
    
    /**
     * Determina el nivel de infección según los valores EE
     */
    private String determinarNivelInfeccion(double ee3era, double ee4ta, double ee5ta) {
        double eePromedio = (ee3era + ee4ta + ee5ta) / 3;
        
        if (eePromedio < 300) {
            return "BAJO";
        } else if (eePromedio >= 300 && eePromedio <= 400) {
            return "MODERADO";
        } else if (eePromedio > 400 && eePromedio <= 500) {
            return "ALTO";
        } else {
            return "MUY ALTO";
        }
    }
    
    /**
     * Calcula los promedios Stover (0 y 10 semanas)
     */
    public void calcularStoverPromedios(Long evaluacionId, List<SigatokaMuestraCompleta> muestras) {
        log.debug("Calculando promedios Stover");
        
        int n = muestras.size();
        if (n == 0) return;
        
        // Promedios 0 semanas
        double avgHvle0 = muestras.stream()
            .filter(m -> m.getHvle0w() != null)
            .mapToDouble(m -> m.getHvle0w().doubleValue())
            .average()
            .orElse(0);
        
        double avgHvlq0 = muestras.stream()
            .filter(m -> m.getHvlq0w() != null)
            .mapToDouble(m -> m.getHvlq0w().doubleValue())
            .average()
            .orElse(0);
        
        double avgHvlq5_0 = muestras.stream()
            .filter(m -> m.getHvlq5_0w() != null)
            .mapToDouble(m -> m.getHvlq5_0w().doubleValue())
            .average()
            .orElse(0);
        
        double avgTh0 = muestras.stream()
            .filter(m -> m.getTh0w() != null)
            .mapToDouble(m -> m.getTh0w().doubleValue())
            .average()
            .orElse(0);
        
        // Promedios 10 semanas
        double avgHvle10 = muestras.stream()
            .filter(m -> m.getHvle10w() != null)
            .mapToDouble(m -> m.getHvle10w().doubleValue())
            .average()
            .orElse(0);
        
        double avgHvlq10 = muestras.stream()
            .filter(m -> m.getHvlq10w() != null)
            .mapToDouble(m -> m.getHvlq10w().doubleValue())
            .average()
            .orElse(0);
        
        double avgHvlq5_10 = muestras.stream()
            .filter(m -> m.getHvlq5_10w() != null)
            .mapToDouble(m -> m.getHvlq5_10w().doubleValue())
            .average()
            .orElse(0);
        
        double avgTh10 = muestras.stream()
            .filter(m -> m.getTh10w() != null)
            .mapToDouble(m -> m.getTh10w().doubleValue())
            .average()
            .orElse(0);
        
        log.info("Promedios Stover 0w: HVLE={}, HVLQ={}, HVLQ5={}, TH={}", avgHvle0, avgHvlq0, avgHvlq5_0, avgTh0);
        log.info("Promedios Stover 10w: HVLE={}, HVLQ={}, HVLQ5={}, TH={}", avgHvle10, avgHvlq10, avgHvlq5_10, avgTh10);
    }
}
