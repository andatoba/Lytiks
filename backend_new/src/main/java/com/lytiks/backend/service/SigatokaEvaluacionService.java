package com.lytiks.backend.service;

import com.lytiks.backend.entity.*;
import com.lytiks.backend.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import lombok.extern.slf4j.Slf4j;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.*;

/**
 * Servicio para gestionar evaluaciones de Sigatoka
 * Implementa operaciones CRUD y orquesta los cálculos
 */
@Service
@Slf4j
@Transactional
public class SigatokaEvaluacionService {
    
    @Autowired
    private SigatokaEvaluacionRepository evaluacionRepository;
    
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
    
    @Autowired
    private SigatokaCalculationService calculationService;
    
    @Autowired
    private com.lytiks.backend.repository.ClientRepository clientRepository;
    
    /**
     * Crea una nueva evaluación
     */
    public SigatokaEvaluacion crearEvaluacion(
        Long clienteId,
        String hacienda,
        LocalDate fecha,
        Integer semanaEpidemiologica,
        String periodo,
        String evaluador
    ) {
        log.info("Creando nueva evaluación para cliente {} en hacienda {}", clienteId, hacienda);
        
        SigatokaEvaluacion evaluacion = new SigatokaEvaluacion();
        evaluacion.setClienteId(clienteId);
        evaluacion.setHacienda(hacienda);
        evaluacion.setFecha(fecha);
        evaluacion.setSemanaEpidemiologica(semanaEpidemiologica);
        evaluacion.setPeriodo(periodo);
        evaluacion.setEvaluador(evaluador);
        
        evaluacion = evaluacionRepository.save(evaluacion);
        
        log.info("Evaluación creada con ID: {}", evaluacion.getId());
        
        return evaluacion;
    }
    
    /**
     * Agrega una muestra a una evaluación existente
     */
    public SigatokaMuestra agregarMuestra(
        Long evaluacionId,
        Integer numeroMuestra,
        String lote,
        String variedad,
        String edad,
        Integer hojasEmitidas,
        Integer hojasErectas,
        Integer hojasConSintomas,
        Integer hojaMasJovenEnferma,
        Integer hojaMasJovenNecrosada
    ) {
        log.info("Agregando muestra {} a evaluación {}", numeroMuestra, evaluacionId);
        
        SigatokaEvaluacion evaluacion = evaluacionRepository.findById(evaluacionId)
            .orElseThrow(() -> new RuntimeException("Evaluación no encontrada: " + evaluacionId));
        
        SigatokaMuestra muestra = new SigatokaMuestra();
        muestra.setEvaluacion(evaluacion);
        muestra.setNumeroMuestra(numeroMuestra);
        muestra.setLote(lote);
        muestra.setVariedad(variedad);
        muestra.setEdad(edad);
        muestra.setHojasEmitidas(hojasEmitidas);
        muestra.setHojasErectas(hojasErectas);
        muestra.setHojasConSintomas(hojasConSintomas);
        muestra.setHojaMasJovenEnferma(hojaMasJovenEnferma);
        muestra.setHojaMasJovenNecrosada(hojaMasJovenNecrosada);
        
        muestra = muestraRepository.save(muestra);
        
        log.info("Muestra agregada con ID: {}", muestra.getId());
        
        return muestra;
    }
    
    /**
     * Calcula todos los valores de una evaluación
     */
    public void calcularEvaluacion(Long evaluacionId, BigDecimal ritmoEmision) {
        log.info("Calculando evaluación {}", evaluacionId);
        
        SigatokaEvaluacion evaluacion = evaluacionRepository.findById(evaluacionId)
            .orElseThrow(() -> new RuntimeException("Evaluación no encontrada: " + evaluacionId));
        
        // Ejecutar todos los cálculos
        calculationService.calcularTodo(evaluacionId, ritmoEmision);
        
        log.info("Cálculo completado para evaluación {}", evaluacionId);
    }
    
    /**
     * Obtiene una evaluación completa con todos sus datos calculados
     */
    public Map<String, Object> obtenerReporteCompleto(Long evaluacionId) {
        log.info("Obteniendo reporte completo para evaluación {}", evaluacionId);
        
        SigatokaEvaluacion evaluacion = evaluacionRepository.findById(evaluacionId)
            .orElseThrow(() -> new RuntimeException("Evaluación no encontrada: " + evaluacionId));
        
        List<SigatokaMuestra> muestras = muestraRepository.findByEvaluacionIdOrderByNumeroMuestraAsc(evaluacionId);
        
        Optional<SigatokaResumen> resumen = resumenRepository.findByEvaluacionId(evaluacionId);
        Optional<SigatokaIndicadores> indicadores = indicadoresRepository.findByEvaluacionId(evaluacionId);
        Optional<SigatokaEstadoEvolutivo> estadoEvolutivo = estadoEvolutivoRepository.findByEvaluacionId(evaluacionId);
        Optional<SigatokaStoverPromedio> stoverPromedio = stoverPromedioRepository.findByEvaluacionId(evaluacionId);
        
        Map<String, Object> reporte = new HashMap<>();
        
        // Sección 1: Encabezado
        Map<String, Object> encabezado = new HashMap<>();
        encabezado.put("clienteId", evaluacion.getClienteId());
        encabezado.put("hacienda", evaluacion.getHacienda());
        encabezado.put("fecha", evaluacion.getFecha());
        encabezado.put("semanaEpidemiologica", evaluacion.getSemanaEpidemiologica());
        encabezado.put("periodo", evaluacion.getPeriodo());
        encabezado.put("evaluador", evaluacion.getEvaluador());
        reporte.put("encabezado", encabezado);
        
        // Sección 2: Tabla de Muestras
        List<Map<String, Object>> muestrasData = new ArrayList<>();
        for (SigatokaMuestra m : muestras) {
            Map<String, Object> muestraData = new HashMap<>();
            muestraData.put("numeroMuestra", m.getNumeroMuestra());
            muestraData.put("lote", m.getLote());
            muestraData.put("variedad", m.getVariedad());
            muestraData.put("edad", m.getEdad());
            muestraData.put("hojasEmitidas", m.getHojasEmitidas());
            muestraData.put("hojasErectas", m.getHojasErectas());
            muestraData.put("hojasConSintomas", m.getHojasConSintomas());
            muestraData.put("hojaMasJovenEnferma", m.getHojaMasJovenEnferma());
            muestraData.put("hojaMasJovenNecrosada", m.getHojaMasJovenNecrosada());
            muestrasData.add(muestraData);
        }
        reporte.put("muestras", muestrasData);
        
        // Sección 3: Resumen General (a-e)
        if (resumen.isPresent()) {
            Map<String, Object> resumenData = new HashMap<>();
            resumenData.put("promedioHojasEmitidas", resumen.get().getPromedioHojasEmitidas());
            resumenData.put("promedioHojasErectas", resumen.get().getPromedioHojasErectas());
            resumenData.put("promedioHojasSintomas", resumen.get().getPromedioHojasSintomas());
            resumenData.put("promedioHojaJovenEnferma", resumen.get().getPromedioHojaJovenEnferma());
            resumenData.put("promedioHojaJovenNecrosada", resumen.get().getPromedioHojaJovenNecrosada());
            reporte.put("resumen", resumenData);
        }
        
        // Sección 4: Indicadores (f-k)
        if (indicadores.isPresent()) {
            Map<String, Object> indicadoresData = new HashMap<>();
            indicadoresData.put("incidenciaPromedio", indicadores.get().getIncidenciaPromedio());
            indicadoresData.put("severidadPromedio", indicadores.get().getSeveridadPromedio());
            indicadoresData.put("indiceHojasErectas", indicadores.get().getIndiceHojasErectas());
            indicadoresData.put("ritmoEmision", indicadores.get().getRitmoEmision());
            indicadoresData.put("velocidadEvolucion", indicadores.get().getVelocidadEvolucion());
            indicadoresData.put("velocidadNecrosis", indicadores.get().getVelocidadNecrosis());
            reporte.put("indicadores", indicadoresData);
        }
        
        // Sección 5: Estado Evolutivo e Interpretación
        if (estadoEvolutivo.isPresent()) {
            Map<String, Object> estadoData = new HashMap<>();
            estadoData.put("ee3eraHoja", estadoEvolutivo.get().getEe3eraHoja());
            estadoData.put("ee4taHoja", estadoEvolutivo.get().getEe4taHoja());
            estadoData.put("ee5taHoja", estadoEvolutivo.get().getEe5taHoja());
            estadoData.put("nivelInfeccion", estadoEvolutivo.get().getNivelInfeccion());
            reporte.put("estadoEvolutivo", estadoData);
        }
        
        // Stover (si está disponible)
        if (stoverPromedio.isPresent()) {
            Map<String, Object> stoverData = new HashMap<>();
            stoverData.put("stover3eraHoja", stoverPromedio.get().getStover3eraHoja());
            stoverData.put("stover4taHoja", stoverPromedio.get().getStover4taHoja());
            stoverData.put("stover5taHoja", stoverPromedio.get().getStover5taHoja());
            stoverData.put("stoverPromedio", stoverPromedio.get().getStoverPromedio());
            stoverData.put("nivelInfeccion", stoverPromedio.get().getNivelInfeccion());
            reporte.put("stover", stoverData);
        }
        
        log.info("Reporte completo generado para evaluación {}", evaluacionId);
        
        return reporte;
    }
    
    /**
     * Lista todas las evaluaciones
     */
    public List<SigatokaEvaluacion> listarEvaluaciones() {
        return evaluacionRepository.findAll();
    }
    
    /**
     * Lista evaluaciones por cliente (usando clienteId)
     */
    public List<SigatokaEvaluacion> listarEvaluacionesPorCliente(Long clienteId) {
        return evaluacionRepository.findAll().stream()
            .filter(e -> e.getClienteId().equals(clienteId))
            .toList();
    }
    
    /**
     * Lista evaluaciones por cédula del cliente
     */
    public List<SigatokaEvaluacion> listarEvaluacionesPorCliente(String cedula) {
        // Buscar el cliente por cédula
        Optional<com.lytiks.backend.entity.Client> cliente = clientRepository.findByCedula(cedula);
        
        if (cliente.isEmpty()) {
            log.warn("Cliente con cédula {} no encontrado", cedula);
            return new ArrayList<>();
        }
        
        Long clienteId = cliente.get().getId();
        
        // Filtrar evaluaciones por clienteId
        return evaluacionRepository.findAll().stream()
            .filter(e -> e.getClienteId().equals(clienteId))
            .toList();
    }
    
    /**
     * Elimina una evaluación y todos sus datos relacionados
     */
    public void eliminarEvaluacion(Long evaluacionId) {
        log.info("Eliminando evaluación {}", evaluacionId);
        
        // Cascade debería eliminar automáticamente todo lo relacionado
        evaluacionRepository.deleteById(evaluacionId);
        
        log.info("Evaluación {} eliminada", evaluacionId);
    }
    
    /**
     * Actualiza los datos básicos de una evaluación
     */
    public SigatokaEvaluacion actualizarEvaluacion(
        Long evaluacionId,
        String hacienda,
        LocalDate fecha,
        Integer semanaEpidemiologica,
        String periodo,
        String evaluador
    ) {
        log.info("Actualizando evaluación {}", evaluacionId);
        
        SigatokaEvaluacion evaluacion = evaluacionRepository.findById(evaluacionId)
            .orElseThrow(() -> new RuntimeException("Evaluación no encontrada: " + evaluacionId));
        
        if (hacienda != null) evaluacion.setHacienda(hacienda);
        if (fecha != null) evaluacion.setFecha(fecha);
        if (semanaEpidemiologica != null) evaluacion.setSemanaEpidemiologica(semanaEpidemiologica);
        if (periodo != null) evaluacion.setPeriodo(periodo);
        if (evaluador != null) evaluacion.setEvaluador(evaluador);
        
        evaluacion = evaluacionRepository.save(evaluacion);
        
        log.info("Evaluación {} actualizada", evaluacionId);
        
        return evaluacion;
    }
}
