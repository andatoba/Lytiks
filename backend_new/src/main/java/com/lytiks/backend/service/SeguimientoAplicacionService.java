package com.lytiks.backend.service;

import com.lytiks.backend.entity.Aplicacion;
import com.lytiks.backend.entity.SeguimientoAplicacion;
import com.lytiks.backend.repository.AplicacionRepository;
import com.lytiks.backend.repository.SeguimientoAplicacionRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Service
public class SeguimientoAplicacionService {

    @Autowired
    private SeguimientoAplicacionRepository seguimientoRepository;

    @Autowired
    private AplicacionRepository aplicacionRepository;

    // Crear seguimiento automático cuando se guarda una aplicación
    public void crearSeguimientoAutomatico(Aplicacion aplicacion) {
        LocalDateTime fechaInicio = aplicacion.getFechaInicio();
        int frecuenciaDias = aplicacion.getFrecuenciaDias();
        int repeticiones = aplicacion.getRepeticiones();

        for (int i = 0; i < repeticiones; i++) {
            SeguimientoAplicacion seguimiento = new SeguimientoAplicacion();
            seguimiento.setAplicacionId(aplicacion.getId());
            seguimiento.setNumeroAplicacion(i + 1);
            seguimiento.setFechaProgramada(fechaInicio.plusDays((long) i * frecuenciaDias));
            seguimiento.setEstado(i == 0 ? "proxima" : "programada");
            seguimiento.setDosisAplicada(aplicacion.getDosis());
            seguimiento.setLote(aplicacion.getLote());
            seguimiento.setRecordatorioActivo(true);
            seguimiento.setHoraRecordatorio(aplicacion.getRecordatorioHora());
            seguimiento.setFechaCreacion(LocalDateTime.now());
            
            seguimientoRepository.save(seguimiento);
        }
    }

    // Obtener resumen de seguimiento
    public Map<String, Object> getResumenSeguimiento(Long aplicacionId) {
        Optional<Aplicacion> aplicacionOpt = aplicacionRepository.findById(aplicacionId);
        if (!aplicacionOpt.isPresent()) {
            throw new RuntimeException("Aplicación no encontrada");
        }

        Aplicacion aplicacion = aplicacionOpt.get();
        List<SeguimientoAplicacion> seguimientos = seguimientoRepository.findByAplicacionIdOrderByNumeroAplicacionAsc(aplicacionId);
        
        Long completadas = seguimientoRepository.countCompletadasByAplicacionId(aplicacionId);
        Long total = seguimientoRepository.countTotalByAplicacionId(aplicacionId);
        
        double porcentajeCumplimiento = total > 0 ? (completadas * 100.0 / total) : 0;

        Map<String, Object> resumen = new HashMap<>();
        resumen.put("plan", aplicacion.getRepeticiones() + " aplicaciones (cada " + aplicacion.getFrecuenciaDias() + " días)");
        resumen.put("progreso", completadas);
        resumen.put("total", total);
        resumen.put("cumplimiento", Math.round(porcentajeCumplimiento));
        resumen.put("aplicaciones", seguimientos);
        resumen.put("producto", aplicacion);

        return resumen;
    }

    // Marcar aplicación como completada
    public SeguimientoAplicacion marcarCompletada(Long seguimientoId, String observaciones, String fotoEvidencia) {
        Optional<SeguimientoAplicacion> seguimientoOpt = seguimientoRepository.findById(seguimientoId);
        if (!seguimientoOpt.isPresent()) {
            throw new RuntimeException("Seguimiento no encontrado");
        }

        SeguimientoAplicacion seguimiento = seguimientoOpt.get();
        seguimiento.setEstado("completada");
        seguimiento.setFechaAplicada(LocalDateTime.now());
        seguimiento.setObservaciones(observaciones);
        seguimiento.setFotoEvidencia(fotoEvidencia);
        seguimiento.setFechaActualizacion(LocalDateTime.now());

        // Activar la siguiente aplicación si existe
        List<SeguimientoAplicacion> siguientes = seguimientoRepository.findByAplicacionIdAndEstado(seguimiento.getAplicacionId(), "programada");
        if (!siguientes.isEmpty()) {
            SeguimientoAplicacion siguiente = siguientes.get(0);
            siguiente.setEstado("proxima");
            seguimientoRepository.save(siguiente);
        }

        return seguimientoRepository.save(seguimiento);
    }

    // Reprogramar aplicación
    public SeguimientoAplicacion reprogramarAplicacion(Long seguimientoId, LocalDateTime nuevaFecha, String nuevaHora) {
        Optional<SeguimientoAplicacion> seguimientoOpt = seguimientoRepository.findById(seguimientoId);
        if (!seguimientoOpt.isPresent()) {
            throw new RuntimeException("Seguimiento no encontrado");
        }

        SeguimientoAplicacion seguimiento = seguimientoOpt.get();
        seguimiento.setFechaProgramada(nuevaFecha);
        seguimiento.setHoraRecordatorio(nuevaHora);
        seguimiento.setFechaActualizacion(LocalDateTime.now());

        return seguimientoRepository.save(seguimiento);
    }

    // Obtener aplicaciones por estado
    public List<SeguimientoAplicacion> getAplicacionesByEstado(String estado) {
        return seguimientoRepository.findByEstado(estado);
    }

    // Obtener aplicaciones programadas para un rango de fechas
    public List<SeguimientoAplicacion> getAplicacionesByFechaRange(LocalDateTime fechaInicio, LocalDateTime fechaFin) {
        return seguimientoRepository.findByFechaProgramadaBetween(fechaInicio, fechaFin);
    }
}