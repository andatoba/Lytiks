package com.lytiks.backend.service;

import com.lytiks.backend.entity.*;
import com.lytiks.backend.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.*;

@Service
public class PlanSeguimientoMokoService {
    
    @Autowired
    private PlanSeguimientoMokoRepository planRepository;
    
    @Autowired
    private ProductoSegMokoRepository productoRepository;
    
    @Autowired
    private ItemsTareasMokoRepository itemsRepository;
    
    @Autowired
    private EjecucionPlanMokoRepository ejecucionPlanRepository;
    
    @Autowired
    private EjecucionTareasMokoRepository ejecucionTareasRepository;
    
    // =====================================================
    // MÉTODOS PARA PLANES/FASES
    // =====================================================
    
    public List<PlanSeguimientoMoko> getAllPlanes() {
        return planRepository.findByActivoTrueOrderByOrdenAsc();
    }
    
    public List<PlanSeguimientoMoko> getPlanesConTareas() {
        return planRepository.findAllWithTareas();
    }
    
    public Optional<PlanSeguimientoMoko> getPlanById(Long id) {
        return planRepository.findById(id);
    }
    
    // =====================================================
    // MÉTODOS PARA PRODUCTOS
    // =====================================================
    
    public List<ProductoSegMoko> getAllProductos() {
        return productoRepository.findByActivoTrueOrderByNombreAsc();
    }
    
    // =====================================================
    // MÉTODOS PARA ITEMS/TAREAS
    // =====================================================
    
    public List<ItemsTareasMoko> getTareasByPlanId(Long planId) {
        return itemsRepository.findByPlanIdWithProducto(planId);
    }
    
    public List<ItemsTareasMoko> getAllTareas() {
        return itemsRepository.findByActivoTrueOrderByOrdenAsc();
    }
    
    // =====================================================
    // MÉTODOS PARA EJECUCIÓN DEL PLAN
    // =====================================================
    
    /**
     * Inicializa el plan de seguimiento para un foco específico
     * Crea registros de ejecución para cada fase y sus tareas
     */
    @Transactional
    public List<EjecucionPlanMoko> inicializarPlanParaFoco(Long focoId) {
        // Verificar si ya existe un plan para este foco
        List<EjecucionPlanMoko> existentes = ejecucionPlanRepository.findByFocoIdOrderByPlanSeguimientoOrdenAsc(focoId);
        if (!existentes.isEmpty()) {
            return existentes;
        }
        
        // Obtener todas las fases activas
        List<PlanSeguimientoMoko> fases = planRepository.findByActivoTrueOrderByOrdenAsc();
        List<EjecucionPlanMoko> ejecuciones = new ArrayList<>();
        
        for (PlanSeguimientoMoko fase : fases) {
            // Crear ejecución del plan para la fase
            EjecucionPlanMoko ejecucionPlan = new EjecucionPlanMoko();
            ejecucionPlan.setFocoId(focoId);
            ejecucionPlan.setPlanSeguimiento(fase);
            ejecucionPlan.setCompletado(false);
            ejecucionPlan.setFechaCreacion(LocalDateTime.now());
            
            ejecucionPlan = ejecucionPlanRepository.save(ejecucionPlan);
            
            // Crear ejecución de tareas para cada item de la fase
            List<ItemsTareasMoko> tareas = itemsRepository.findByPlanSeguimientoIdAndActivoTrueOrderByOrdenAsc(fase.getId());
            List<EjecucionTareasMoko> tareasEjecutadas = new ArrayList<>();
            
            for (ItemsTareasMoko tarea : tareas) {
                EjecucionTareasMoko ejecucionTarea = new EjecucionTareasMoko();
                ejecucionTarea.setEjecucionPlan(ejecucionPlan);
                ejecucionTarea.setItemTarea(tarea);
                ejecucionTarea.setCompletado(false);
                ejecucionTarea.setFechaCreacion(LocalDateTime.now());
                
                tareasEjecutadas.add(ejecucionTareasRepository.save(ejecucionTarea));
            }
            
            ejecucionPlan.setTareasEjecutadas(tareasEjecutadas);
            ejecuciones.add(ejecucionPlan);
        }
        
        return ejecuciones;
    }
    
    /**
     * Obtiene el estado del plan de seguimiento para un foco
     */
    public List<EjecucionPlanMoko> getEstadoPlanFoco(Long focoId) {
        return ejecucionPlanRepository.findByFocoIdWithDetails(focoId);
    }
    
    /**
     * Marca una tarea como completada o no completada
     */
    @Transactional
    public EjecucionTareasMoko actualizarEstadoTarea(Long ejecucionTareaId, boolean completado) {
        Optional<EjecucionTareasMoko> optTarea = ejecucionTareasRepository.findById(ejecucionTareaId);
        if (optTarea.isEmpty()) {
            throw new RuntimeException("Tarea no encontrada: " + ejecucionTareaId);
        }
        
        EjecucionTareasMoko tarea = optTarea.get();
        tarea.setCompletado(completado);
        tarea.setFechaCompletado(completado ? LocalDateTime.now() : null);
        tarea.setFechaModificacion(LocalDateTime.now());
        
        tarea = ejecucionTareasRepository.save(tarea);
        
        // Verificar si todas las tareas de la fase están completadas
        verificarYActualizarFase(tarea.getEjecucionPlan().getId());
        
        return tarea;
    }
    
    /**
     * Actualiza múltiples tareas a la vez
     */
    @Transactional
    public List<EjecucionTareasMoko> actualizarTareas(Long ejecucionPlanId, List<Long> tareasCompletadas) {
        List<EjecucionTareasMoko> tareas = ejecucionTareasRepository.findByEjecucionPlanIdWithTarea(ejecucionPlanId);
        
        for (EjecucionTareasMoko tarea : tareas) {
            boolean completada = tareasCompletadas.contains(tarea.getId());
            tarea.setCompletado(completada);
            tarea.setFechaCompletado(completada ? LocalDateTime.now() : null);
            tarea.setFechaModificacion(LocalDateTime.now());
            ejecucionTareasRepository.save(tarea);
        }
        
        // Verificar si todas las tareas están completadas
        verificarYActualizarFase(ejecucionPlanId);
        
        return ejecucionTareasRepository.findByEjecucionPlanIdWithTarea(ejecucionPlanId);
    }
    
    /**
     * Verifica si todas las tareas de una fase están completadas y actualiza el estado de la fase
     */
    private void verificarYActualizarFase(Long ejecucionPlanId) {
        Long totalTareas = ejecucionTareasRepository.countTotalByEjecucionPlanId(ejecucionPlanId);
        Long tareasCompletadas = ejecucionTareasRepository.countCompletadasByEjecucionPlanId(ejecucionPlanId);
        
        Optional<EjecucionPlanMoko> optPlan = ejecucionPlanRepository.findById(ejecucionPlanId);
        if (optPlan.isPresent()) {
            EjecucionPlanMoko plan = optPlan.get();
            boolean todasCompletadas = totalTareas.equals(tareasCompletadas) && totalTareas > 0;
            
            if (todasCompletadas && !plan.getCompletado()) {
                plan.setCompletado(true);
                plan.setFechaCompletado(LocalDateTime.now());
            } else if (!todasCompletadas && plan.getCompletado()) {
                plan.setCompletado(false);
                plan.setFechaCompletado(null);
            }
            
            plan.setFechaModificacion(LocalDateTime.now());
            ejecucionPlanRepository.save(plan);
        }
    }
    
    /**
     * Finaliza una revisión de fase (marca la fase como completada manualmente)
     */
    @Transactional
    public EjecucionPlanMoko finalizarRevisionFase(Long ejecucionPlanId, String observaciones) {
        Optional<EjecucionPlanMoko> optPlan = ejecucionPlanRepository.findById(ejecucionPlanId);
        if (optPlan.isEmpty()) {
            throw new RuntimeException("Plan de ejecución no encontrado: " + ejecucionPlanId);
        }
        
        EjecucionPlanMoko plan = optPlan.get();
        plan.setCompletado(true);
        plan.setFechaCompletado(LocalDateTime.now());
        plan.setObservaciones(observaciones);
        plan.setFechaModificacion(LocalDateTime.now());
        
        // Si no hay fecha de inicio, establecerla
        if (plan.getFechaInicio() == null) {
            plan.setFechaInicio(LocalDateTime.now());
        }
        
        return ejecucionPlanRepository.save(plan);
    }
    
    /**
     * Obtiene las tareas de una fase específica
     */
    public List<EjecucionTareasMoko> getTareasPorFase(Long ejecucionPlanId) {
        return ejecucionTareasRepository.findByEjecucionPlanIdWithTarea(ejecucionPlanId);
    }
    
    /**
     * Obtiene el progreso general del plan para un foco
     */
    public Map<String, Object> getProgresoFoco(Long focoId) {
        List<EjecucionPlanMoko> ejecuciones = ejecucionPlanRepository.findByFocoIdOrderByPlanSeguimientoOrdenAsc(focoId);
        
        int totalFases = ejecuciones.size();
        int fasesCompletadas = (int) ejecuciones.stream().filter(EjecucionPlanMoko::getCompletado).count();
        
        Map<String, Object> progreso = new HashMap<>();
        progreso.put("totalFases", totalFases);
        progreso.put("fasesCompletadas", fasesCompletadas);
        progreso.put("porcentaje", totalFases > 0 ? (fasesCompletadas * 100 / totalFases) : 0);
        progreso.put("completado", fasesCompletadas == totalFases && totalFases > 0);
        
        return progreso;
    }
}
