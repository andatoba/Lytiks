package com.lytiks.backend.service;

import com.lytiks.backend.dto.*;
import com.lytiks.backend.entity.*;
import com.lytiks.backend.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import lombok.extern.slf4j.Slf4j;

import java.util.*;
import java.util.stream.Collectors;

/**
 * Servicio REDISEÑADO para gestionar evaluaciones de Sigatoka con estructura completa
 */
@Service
@Slf4j
@Transactional
public class SigatokaEvaluacionServiceCompleto {
    
    @Autowired
    private SigatokaEvaluacionRepository evaluacionRepository;
    
    @Autowired
    private SigatokaLoteRepository loteRepository;
    
    @Autowired
    private SigatokaMuestraCompletaRepository muestraRepository;
    
    @Autowired
    private SigatokaResumenRepository resumenRepository;
    
    @Autowired
    private SigatokaIndicadoresRepository indicadoresRepository;
    
    @Autowired
    private SigatokaEstadoEvolutivoRepository estadoEvolutivoRepository;
    
    @Autowired
    private SigatokaStoverPromedioRepository stoverPromedioRepository;
    
    @Autowired
    private SigatokaCalculationServiceCompleto calculationService;
    
    // ========== OPERACIONES DE CREACIÓN ==========
    
    /**
     * Crear encabezado de evaluación
     */
    public SigatokaEvaluacion crearEvaluacion(SigatokaEvaluacionDTO dto) {
        log.info("Creando evaluación: hacienda={}, fecha={}", dto.getHacienda(), dto.getFecha());
        
        SigatokaEvaluacion evaluacion = new SigatokaEvaluacion();
        evaluacion.setClienteId(dto.getClienteId());
        evaluacion.setHacienda(dto.getHacienda());
        evaluacion.setFecha(dto.getFecha());
        evaluacion.setSemanaEpidemiologica(dto.getSemanaEpidemiologica());
        evaluacion.setPeriodo(dto.getPeriodo());
        evaluacion.setEvaluador(dto.getEvaluador());
        
        return evaluacionRepository.save(evaluacion);
    }
    
    /**
     * Agregar lote a evaluación
     */
    public SigatokaLote agregarLote(Long evaluacionId, SigatokaLoteDTO loteDTO) {
        log.info("Agregando lote {} a evaluación {}", loteDTO.getLoteCodigo(), evaluacionId);
        
        SigatokaEvaluacion evaluacion = evaluacionRepository.findById(evaluacionId)
            .orElseThrow(() -> new RuntimeException("Evaluación no encontrada: " + evaluacionId));
        
        SigatokaLote lote = new SigatokaLote();
        lote.setEvaluacion(evaluacion);
        lote.setLoteCodigo(loteDTO.getLoteCodigo());
        
        return loteRepository.save(lote);
    }
    
    /**
     * Agregar muestra completa a lote
     */
    public SigatokaMuestraCompleta agregarMuestra(Long loteId, SigatokaMuestraCompletaDTO dto) {
        log.info("Agregando muestra #{} a lote {}", dto.getMuestraNum(), loteId);
        
        SigatokaLote lote = loteRepository.findById(loteId)
            .orElseThrow(() -> new RuntimeException("Lote no encontrado: " + loteId));
        
        SigatokaMuestraCompleta muestra = new SigatokaMuestraCompleta();
        muestra.setLote(lote);
        muestra.setMuestraNum(dto.getMuestraNum());
        
        // Grados de infección
        muestra.setHoja3era(dto.getHoja3era());
        muestra.setHoja4ta(dto.getHoja4ta());
        muestra.setHoja5ta(dto.getHoja5ta());
        
        // Total hojas
        muestra.setTotalHojas3era(dto.getTotalHojas3era());
        muestra.setTotalHojas4ta(dto.getTotalHojas4ta());
        muestra.setTotalHojas5ta(dto.getTotalHojas5ta());
        
        // Variables a-e
        muestra.setPlantasMuestreadas(dto.getPlantasMuestreadas());
        muestra.setPlantasConLesiones(dto.getPlantasConLesiones());
        muestra.setTotalLesiones(dto.getTotalLesiones());
        muestra.setPlantas3erEstadio(dto.getPlantas3erEstadio());
        muestra.setTotalLetras(dto.getTotalLetras());
        
        // Stover 0w
        muestra.setHvle0w(dto.getHvle0w());
        muestra.setHvlq0w(dto.getHvlq0w());
        muestra.setHvlq5_0w(dto.getHvlq5_0w());
        muestra.setTh0w(dto.getTh0w());
        
        // Stover 10w
        muestra.setHvle10w(dto.getHvle10w());
        muestra.setHvlq10w(dto.getHvlq10w());
        muestra.setHvlq5_10w(dto.getHvlq5_10w());
        muestra.setTh10w(dto.getTh10w());
        
        return muestraRepository.save(muestra);
    }
    
    /**
     * Agregar múltiples muestras de una vez
     */
    public List<SigatokaMuestraCompleta> agregarMuestrasMultiples(Long loteId, List<SigatokaMuestraCompletaDTO> muestrasDTO) {
        log.info("Agregando {} muestras a lote {}", muestrasDTO.size(), loteId);
        
        return muestrasDTO.stream()
            .map(dto -> agregarMuestra(loteId, dto))
            .collect(Collectors.toList());
    }
    
    // ========== OPERACIONES DE CONSULTA ==========
    
    /**
     * Obtener evaluación completa con lotes y muestras
     */
    public SigatokaEvaluacion obtenerEvaluacionCompleta(Long evaluacionId) {
        return evaluacionRepository.findById(evaluacionId)
            .orElseThrow(() -> new RuntimeException("Evaluación no encontrada: " + evaluacionId));
    }
    
    /**
     * Obtener evaluaciones por cliente
     */
    public List<SigatokaEvaluacion> obtenerEvaluacionesPorCliente(Long clienteId) {
        return evaluacionRepository.findByClienteIdOrderByFechaDesc(clienteId);
    }

    /**
     * Obtener todas las evaluaciones
     */
    public List<SigatokaEvaluacion> obtenerTodasEvaluaciones() {
        return evaluacionRepository.findAll(Sort.by(Sort.Direction.DESC, "fecha"));
    }
    
    /**
     * Obtener lotes de una evaluación
     */
    public List<SigatokaLote> obtenerLotesPorEvaluacion(Long evaluacionId) {
        return loteRepository.findByEvaluacionIdOrderById(evaluacionId);
    }
    
    /**
     * Obtener muestras de un lote
     */
    public List<SigatokaMuestraCompleta> obtenerMuestrasPorLote(Long loteId) {
        return muestraRepository.findByLoteIdOrderByMuestraNumAsc(loteId);
    }
    
    /**
     * Obtener TODAS las muestras de una evaluación
     */
    public List<SigatokaMuestraCompleta> obtenerTodasMuestrasPorEvaluacion(Long evaluacionId) {
        return muestraRepository.findByLote_EvaluacionIdOrderByMuestraNumAsc(evaluacionId);
    }
    
    // ========== OPERACIONES DE CÁLCULO ==========
    
    /**
     * Calcular resumen (promedios a-e)
     */
    public SigatokaResumen calcularResumen(Long evaluacionId) {
        log.info("Calculando resumen para evaluación {}", evaluacionId);
        
        List<SigatokaMuestraCompleta> muestras = obtenerTodasMuestrasPorEvaluacion(evaluacionId);
        SigatokaResumen resumen = calculationService.calcularPromediosBasicos(evaluacionId, muestras);
        
        // Buscar si ya existe
        SigatokaEvaluacion evaluacion = obtenerEvaluacionCompleta(evaluacionId);
        SigatokaResumen existente = resumenRepository.findByEvaluacionId(evaluacionId).orElse(null);
        
        if (existente != null) {
            // Actualizar el existente
            existente.setPromedioHojasEmitidas(resumen.getPromedioHojasEmitidas());
            existente.setPromedioHojasErectas(resumen.getPromedioHojasErectas());
            existente.setPromedioHojasSintomas(resumen.getPromedioHojasSintomas());
            existente.setPromedioHojaJovenEnferma(resumen.getPromedioHojaJovenEnferma());
            existente.setPromedioHojaJovenNecrosada(resumen.getPromedioHojaJovenNecrosada());
            return resumenRepository.save(existente);
        } else {
            // Crear nuevo
            resumen.setEvaluacion(evaluacion);
            return resumenRepository.save(resumen);
        }
    }
    
    /**
     * Calcular indicadores (f-k)
     */
    public SigatokaIndicadores calcularIndicadores(Long evaluacionId) {
        log.info("Calculando indicadores para evaluación {}", evaluacionId);
        
        // Primero necesitamos el resumen
        SigatokaResumen resumen = calcularResumen(evaluacionId);
        
        List<SigatokaMuestraCompleta> muestras = obtenerTodasMuestrasPorEvaluacion(evaluacionId);
        SigatokaIndicadores indicadores = calculationService.calcularIndicadores(evaluacionId, resumen, muestras);
        
        // Buscar si ya existe
        SigatokaEvaluacion evaluacion = obtenerEvaluacionCompleta(evaluacionId);
        SigatokaIndicadores existente = indicadoresRepository.findByEvaluacionId(evaluacionId).orElse(null);
        
        if (existente != null) {
            // Actualizar el existente
            existente.setIncidenciaPromedio(indicadores.getIncidenciaPromedio());
            existente.setSeveridadPromedio(indicadores.getSeveridadPromedio());
            existente.setIndiceHojasErectas(indicadores.getIndiceHojasErectas());
            existente.setRitmoEmision(indicadores.getRitmoEmision());
            existente.setVelocidadEvolucion(indicadores.getVelocidadEvolucion());
            existente.setVelocidadNecrosis(indicadores.getVelocidadNecrosis());
            return indicadoresRepository.save(existente);
        } else {
            // Crear nuevo
            indicadores.setEvaluacion(evaluacion);
            return indicadoresRepository.save(indicadores);
        }
    }
    
    /**
     * Calcular estado evolutivo (EE)
     */
    public SigatokaEstadoEvolutivo calcularEstadoEvolutivo(Long evaluacionId) {
        log.info("Calculando estado evolutivo para evaluación {}", evaluacionId);
        
        // Necesitamos indicadores primero
        SigatokaIndicadores indicadores = calcularIndicadores(evaluacionId);
        
        SigatokaEstadoEvolutivo estado = calculationService.calcularEstadoEvolutivo(evaluacionId, indicadores);
        
        // Buscar si ya existe
        SigatokaEvaluacion evaluacion = obtenerEvaluacionCompleta(evaluacionId);
        SigatokaEstadoEvolutivo existente = estadoEvolutivoRepository.findByEvaluacionId(evaluacionId).orElse(null);
        
        if (existente != null) {
            // Actualizar el existente
            existente.setEe3eraHoja(estado.getEe3eraHoja());
            existente.setEe4taHoja(estado.getEe4taHoja());
            existente.setEe5taHoja(estado.getEe5taHoja());
            existente.setNivelInfeccion(estado.getNivelInfeccion());
            return estadoEvolutivoRepository.save(existente);
        } else {
            // Crear nuevo
            estado.setEvaluacion(evaluacion);
            return estadoEvolutivoRepository.save(estado);
        }
    }
    
    /**
     * Calcular promedios Stover
     */
    public SigatokaStoverPromedio calcularStover(Long evaluacionId) {
        log.info("Calculando Stover para evaluación {}", evaluacionId);
        
        List<SigatokaMuestraCompleta> muestras = obtenerTodasMuestrasPorEvaluacion(evaluacionId);
        calculationService.calcularStoverPromedios(evaluacionId, muestras);
        
        // Buscar si ya existe
        SigatokaEvaluacion evaluacion = obtenerEvaluacionCompleta(evaluacionId);
        SigatokaStoverPromedio existente = stoverPromedioRepository.findByEvaluacionId(evaluacionId).orElse(null);
        
        if (existente != null) {
            // Ya existe, retornar el existente (los valores ya fueron actualizados por calcularStoverPromedios)
            return existente;
        } else {
            // Crear nuevo
            SigatokaStoverPromedio stover = new SigatokaStoverPromedio();
            stover.setEvaluacion(evaluacion);
            return stoverPromedioRepository.save(stover);
        }
    }
    
    /**
     * Calcular TODO de una vez
     */
    public SigatokaReporteCompletoDTO calcularTodo(Long evaluacionId) {
        log.info("Calculando TODO para evaluación {}", evaluacionId);
        
        SigatokaReporteCompletoDTO reporte = new SigatokaReporteCompletoDTO();
        
        // Obtener datos básicos
        SigatokaEvaluacion evaluacion = obtenerEvaluacionCompleta(evaluacionId);
        List<SigatokaLote> lotes = obtenerLotesPorEvaluacion(evaluacionId);
        List<SigatokaMuestraCompleta> muestras = obtenerTodasMuestrasPorEvaluacion(evaluacionId);
        
        // Realizar todos los cálculos
        SigatokaResumen resumen = calcularResumen(evaluacionId);
        SigatokaIndicadores indicadores = calcularIndicadores(evaluacionId);
        SigatokaEstadoEvolutivo estado = calcularEstadoEvolutivo(evaluacionId);
        SigatokaStoverPromedio stover = calcularStover(evaluacionId);
        
        // Llenar el reporte
        reporte.setEvaluacion(evaluacion);
        reporte.setLotes(lotes);
        reporte.setMuestras(muestras);
        reporte.setResumen(resumen);
        reporte.setIndicadores(indicadores);
        reporte.setEstadoEvolutivo(estado);
        reporte.setStoverPromedio(stover);
        
        return reporte;
    }
    
    // ========== OPERACIONES DE ACTUALIZACIÓN ==========
    
    /**
     * Actualizar evaluación
     */
    public SigatokaEvaluacion actualizarEvaluacion(Long evaluacionId, SigatokaEvaluacionDTO dto) {
        log.info("Actualizando evaluación {}", evaluacionId);
        
        SigatokaEvaluacion evaluacion = obtenerEvaluacionCompleta(evaluacionId);
        
        if (dto.getHacienda() != null) evaluacion.setHacienda(dto.getHacienda());
        if (dto.getFecha() != null) evaluacion.setFecha(dto.getFecha());
        if (dto.getSemanaEpidemiologica() != null) evaluacion.setSemanaEpidemiologica(dto.getSemanaEpidemiologica());
        if (dto.getPeriodo() != null) evaluacion.setPeriodo(dto.getPeriodo());
        if (dto.getEvaluador() != null) evaluacion.setEvaluador(dto.getEvaluador());
        
        return evaluacionRepository.save(evaluacion);
    }
    
    // ========== OPERACIONES DE ELIMINACIÓN ==========
    
    /**
     * Eliminar evaluación (cascada elimina todo)
     */
    public void eliminarEvaluacion(Long evaluacionId) {
        log.info("Eliminando evaluación {}", evaluacionId);
        evaluacionRepository.deleteById(evaluacionId);
    }
    
    /**
     * Eliminar lote (cascada elimina muestras)
     */
    public void eliminarLote(Long loteId) {
        log.info("Eliminando lote {}", loteId);
        loteRepository.deleteById(loteId);
    }
    
    /**
     * Eliminar muestra individual
     */
    public void eliminarMuestra(Long muestraId) {
        log.info("Eliminando muestra {}", muestraId);
        muestraRepository.deleteById(muestraId);
    }
}
