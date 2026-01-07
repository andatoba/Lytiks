package com.lytiks.backend.service;

import com.lytiks.backend.entity.*;
import com.lytiks.backend.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import lombok.extern.slf4j.Slf4j;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.List;

/**
 * Servicio para calcular todas las fórmulas de Sigatoka según las especificaciones del Excel:
 * 
 * FÓRMULAS BÁSICAS (a-e): Promedios simples
 * a = Promedio hojas emitidas
 * b = Promedio hojas erectas  
 * c = Promedio hojas con síntomas
 * d = Promedio hoja más joven enferma
 * e = Promedio hoja más joven necrosada
 * 
 * INDICADORES (f-k): Cálculos derivados
 * f = c/a (Incidencia promedio)
 * g = (d/b)×100 (Severidad promedio)
 * h = (b/a)×100 (Índice de hojas erectas)
 * i = Ritmo de emisión (configurable)
 * j = i/a (Velocidad de evolución)
 * k = e/a (Velocidad de necrosis)
 * 
 * ESTADO EVOLUTIVO (EE):
 * EE 3era hoja = f×120×k
 * EE 4ta hoja = f×100×k
 * EE 5ta hoja = f×80×k
 */
@Service
@Slf4j
@Transactional
public class SigatokaCalculationService {
    
    @Autowired
    private SigatokaMuestraRepository muestraRepository;
    
    @Autowired
    private SigatokaResumenRepository resumenRepository;
    
    @Autowired
    private SigatokaIndicadoresRepository indicadoresRepository;
    
    @Autowired
    private SigatokaEstadoEvolutivoRepository estadoEvolutivoRepository;
    
    @Autowired
    private SigatokaStoverPromedioRepository stoverPromedioRepository;
    
    private static final int SCALE = 2;
    private static final RoundingMode ROUNDING = RoundingMode.HALF_UP;
    
    /**
     * Calcula todos los valores para una evaluación completa
     */
    public void calcularTodo(Long evaluacionId, BigDecimal ritmoEmision) {
        log.info("Calculando todos los valores para evaluación {}", evaluacionId);
        
        List<SigatokaMuestra> muestras = muestraRepository.findByEvaluacionIdOrderByNumeroMuestraAsc(evaluacionId);
        
        if (muestras.isEmpty()) {
            log.warn("No hay muestras para la evaluación {}", evaluacionId);
            return;
        }
        
        // 1. Calcular promedios básicos (a-e)
        SigatokaResumen resumen = calcularPromediosBasicos(evaluacionId, muestras);
        
        // 2. Calcular indicadores (f-k)
        SigatokaIndicadores indicadores = calcularIndicadores(evaluacionId, resumen, ritmoEmision);
        
        // 3. Calcular estado evolutivo (EE)
        SigatokaEstadoEvolutivo estadoEvolutivo = calcularEstadoEvolutivo(evaluacionId, indicadores);
        
        // 4. Calcular promedios Stover (si aplica)
        SigatokaStoverPromedio stoverPromedio = calcularStoverPromedio(evaluacionId, muestras);
        
        log.info("Cálculos completados para evaluación {}", evaluacionId);
    }
    
    /**
     * Calcula los promedios básicos (a-e) del resumen general
     */
    private SigatokaResumen calcularPromediosBasicos(Long evaluacionId, List<SigatokaMuestra> muestras) {
        log.debug("Calculando promedios básicos para {} muestras", muestras.size());
        
        // Sumar todos los valores
        int sumaHojasEmitidas = 0;
        int sumaHojasErectas = 0;
        int sumaHojasSintomas = 0;
        int sumaHojaJovenEnferma = 0;
        int sumaHojaJovenNecrosada = 0;
        
        for (SigatokaMuestra m : muestras) {
            sumaHojasEmitidas += (m.getHojasEmitidas() != null ? m.getHojasEmitidas() : 0);
            sumaHojasErectas += (m.getHojasErectas() != null ? m.getHojasErectas() : 0);
            sumaHojasSintomas += (m.getHojasConSintomas() != null ? m.getHojasConSintomas() : 0);
            sumaHojaJovenEnferma += (m.getHojaMasJovenEnferma() != null ? m.getHojaMasJovenEnferma() : 0);
            sumaHojaJovenNecrosada += (m.getHojaMasJovenNecrosada() != null ? m.getHojaMasJovenNecrosada() : 0);
        }
        
        int totalMuestras = muestras.size();
        
        // Calcular promedios
        BigDecimal a = BigDecimal.valueOf(sumaHojasEmitidas).divide(BigDecimal.valueOf(totalMuestras), SCALE, ROUNDING);
        BigDecimal b = BigDecimal.valueOf(sumaHojasErectas).divide(BigDecimal.valueOf(totalMuestras), SCALE, ROUNDING);
        BigDecimal c = BigDecimal.valueOf(sumaHojasSintomas).divide(BigDecimal.valueOf(totalMuestras), SCALE, ROUNDING);
        BigDecimal d = BigDecimal.valueOf(sumaHojaJovenEnferma).divide(BigDecimal.valueOf(totalMuestras), SCALE, ROUNDING);
        BigDecimal e = BigDecimal.valueOf(sumaHojaJovenNecrosada).divide(BigDecimal.valueOf(totalMuestras), SCALE, ROUNDING);
        
        // Buscar o crear el resumen
        SigatokaResumen resumen = resumenRepository.findByEvaluacionId(evaluacionId)
            .orElse(new SigatokaResumen());
        
        resumen.setPromedioHojasEmitidas(a);
        resumen.setPromedioHojasErectas(b);
        resumen.setPromedioHojasSintomas(c);
        resumen.setPromedioHojaJovenEnferma(d);
        resumen.setPromedioHojaJovenNecrosada(e);
        
        resumen = resumenRepository.save(resumen);
        
        log.debug("Promedios básicos: a={}, b={}, c={}, d={}, e={}", a, b, c, d, e);
        
        return resumen;
    }
    
    /**
     * Calcula los indicadores (f-k)
     */
    private SigatokaIndicadores calcularIndicadores(Long evaluacionId, SigatokaResumen resumen, BigDecimal ritmoEmision) {
        log.debug("Calculando indicadores");
        
        BigDecimal a = resumen.getPromedioHojasEmitidas();
        BigDecimal b = resumen.getPromedioHojasErectas();
        BigDecimal c = resumen.getPromedioHojasSintomas();
        BigDecimal d = resumen.getPromedioHojaJovenEnferma();
        BigDecimal e = resumen.getPromedioHojaJovenNecrosada();
        
        // f = c/a (Incidencia promedio)
        BigDecimal f = a.compareTo(BigDecimal.ZERO) > 0 
            ? c.divide(a, SCALE, ROUNDING) 
            : BigDecimal.ZERO;
        
        // g = (d/b)×100 (Severidad promedio)
        BigDecimal g = b.compareTo(BigDecimal.ZERO) > 0 
            ? d.divide(b, SCALE, ROUNDING).multiply(BigDecimal.valueOf(100)) 
            : BigDecimal.ZERO;
        
        // h = (b/a)×100 (Índice de hojas erectas)
        BigDecimal h = a.compareTo(BigDecimal.ZERO) > 0 
            ? b.divide(a, SCALE, ROUNDING).multiply(BigDecimal.valueOf(100)) 
            : BigDecimal.ZERO;
        
        // i = Ritmo de emisión (proporcionado como parámetro)
        BigDecimal i = ritmoEmision != null ? ritmoEmision : BigDecimal.ONE;
        
        // j = i/a (Velocidad de evolución)
        BigDecimal j = a.compareTo(BigDecimal.ZERO) > 0 
            ? i.divide(a, SCALE, ROUNDING) 
            : BigDecimal.ZERO;
        
        // k = e/a (Velocidad de necrosis)
        BigDecimal k = a.compareTo(BigDecimal.ZERO) > 0 
            ? e.divide(a, SCALE, ROUNDING) 
            : BigDecimal.ZERO;
        
        // Buscar o crear indicadores
        SigatokaIndicadores indicadores = indicadoresRepository.findByEvaluacionId(evaluacionId)
            .orElse(new SigatokaIndicadores());
        
        indicadores.setIncidenciaPromedio(f);
        indicadores.setSeveridadPromedio(g);
        indicadores.setIndiceHojasErectas(h);
        indicadores.setRitmoEmision(i);
        indicadores.setVelocidadEvolucion(j);
        indicadores.setVelocidadNecrosis(k);
        
        indicadores = indicadoresRepository.save(indicadores);
        
        log.debug("Indicadores: f={}, g={}, h={}, i={}, j={}, k={}", f, g, h, i, j, k);
        
        return indicadores;
    }
    
    /**
     * Calcula el estado evolutivo (EE)
     */
    private SigatokaEstadoEvolutivo calcularEstadoEvolutivo(Long evaluacionId, SigatokaIndicadores indicadores) {
        log.debug("Calculando estado evolutivo");
        
        BigDecimal f = indicadores.getIncidenciaPromedio();
        BigDecimal k = indicadores.getVelocidadNecrosis();
        
        // EE 3era hoja = f×120×k
        BigDecimal ee3era = f.multiply(BigDecimal.valueOf(120)).multiply(k).setScale(SCALE, ROUNDING);
        
        // EE 4ta hoja = f×100×k
        BigDecimal ee4ta = f.multiply(BigDecimal.valueOf(100)).multiply(k).setScale(SCALE, ROUNDING);
        
        // EE 5ta hoja = f×80×k
        BigDecimal ee5ta = f.multiply(BigDecimal.valueOf(80)).multiply(k).setScale(SCALE, ROUNDING);
        
        // Determinar nivel de infección basado en los valores EE
        String nivelInfeccion = determinarNivelInfeccion(ee3era, ee4ta, ee5ta);
        
        // Buscar o crear estado evolutivo
        SigatokaEstadoEvolutivo estado = estadoEvolutivoRepository.findByEvaluacionId(evaluacionId)
            .orElse(new SigatokaEstadoEvolutivo());
        
        estado.setEe3eraHoja(ee3era);
        estado.setEe4taHoja(ee4ta);
        estado.setEe5taHoja(ee5ta);
        estado.setNivelInfeccion(nivelInfeccion);
        
        estado = estadoEvolutivoRepository.save(estado);
        
        log.debug("Estado evolutivo: EE3era={}, EE4ta={}, EE5ta={}, Nivel={}", ee3era, ee4ta, ee5ta, nivelInfeccion);
        
        return estado;
    }
    
    /**
     * Calcula los promedios Stover
     */
    private SigatokaStoverPromedio calcularStoverPromedio(Long evaluacionId, List<SigatokaMuestra> muestras) {
        log.debug("Calculando promedios Stover");
        
        // Por ahora, este cálculo está simplificado
        // En el futuro se puede agregar lógica más compleja basada en las muestras
        
        SigatokaStoverPromedio stover = stoverPromedioRepository.findByEvaluacionId(evaluacionId)
            .orElse(new SigatokaStoverPromedio());
        
        // Estos valores se calcularían basándose en datos adicionales
        // Por ahora los inicializamos en cero
        stover.setStover3eraHoja(BigDecimal.ZERO);
        stover.setStover4taHoja(BigDecimal.ZERO);
        stover.setStover5taHoja(BigDecimal.ZERO);
        stover.setStoverPromedio(BigDecimal.ZERO);
        stover.setNivelInfeccion("Sin datos");
        
        stover = stoverPromedioRepository.save(stover);
        
        return stover;
    }
    
    /**
     * Determina el nivel de infección basado en los valores EE
     */
    private String determinarNivelInfeccion(BigDecimal ee3era, BigDecimal ee4ta, BigDecimal ee5ta) {
        // Promedio de los tres valores EE
        BigDecimal promedio = ee3era.add(ee4ta).add(ee5ta)
            .divide(BigDecimal.valueOf(3), SCALE, ROUNDING);
        
        // Criterios de clasificación (ajustar según necesidad)
        if (promedio.compareTo(BigDecimal.valueOf(10)) < 0) {
            return "Bajo";
        } else if (promedio.compareTo(BigDecimal.valueOf(20)) < 0) {
            return "Medio";
        } else if (promedio.compareTo(BigDecimal.valueOf(30)) < 0) {
            return "Alto";
        } else {
            return "Muy Alto";
        }
    }
}
