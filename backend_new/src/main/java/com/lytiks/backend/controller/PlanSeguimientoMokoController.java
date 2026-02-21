package com.lytiks.backend.controller;

import com.lytiks.backend.entity.*;
import com.lytiks.backend.service.PlanSeguimientoMokoService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("moko/plan-seguimiento")
@CrossOrigin(origins = "*")
public class PlanSeguimientoMokoController {

    @Autowired
    private PlanSeguimientoMokoService planService;

    // =====================================================
    // ENDPOINTS PARA FASES/PLANES
    // =====================================================

    /**
     * Obtiene todas las fases del protocolo
     */
    @GetMapping("/fases")
    public ResponseEntity<List<PlanSeguimientoMoko>> getFases() {
        try {
            List<PlanSeguimientoMoko> fases = planService.getAllPlanes();
            return ResponseEntity.ok(fases);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(null);
        }
    }

    /**
     * Obtiene todas las fases con sus tareas incluidas
     */
    @GetMapping("/fases-con-tareas")
    public ResponseEntity<List<PlanSeguimientoMoko>> getFasesConTareas() {
        try {
            List<PlanSeguimientoMoko> fases = planService.getPlanesConTareas();
            return ResponseEntity.ok(fases);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(null);
        }
    }

    /**
     * Obtiene las tareas de una fase específica
     */
    @GetMapping("/fases/{faseId}/tareas")
    public ResponseEntity<List<ItemsTareasMoko>> getTareasPorFase(@PathVariable Long faseId) {
        try {
            List<ItemsTareasMoko> tareas = planService.getTareasByPlanId(faseId);
            return ResponseEntity.ok(tareas);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(null);
        }
    }

    // =====================================================
    // ENDPOINTS PARA PRODUCTOS
    // =====================================================

    /**
     * Obtiene todos los productos del protocolo
     */
    @GetMapping("/productos")
    public ResponseEntity<List<ProductoSegMoko>> getProductos() {
        try {
            List<ProductoSegMoko> productos = planService.getAllProductos();
            return ResponseEntity.ok(productos);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(null);
        }
    }

    // =====================================================
    // ENDPOINTS PARA EJECUCIÓN DEL PLAN
    // =====================================================

    /**
     * Inicializa el plan de seguimiento para un foco
     */
    @PostMapping("/foco/{focoId}/inicializar")
    public ResponseEntity<Map<String, Object>> inicializarPlan(@PathVariable Long focoId) {
        try {
            List<EjecucionPlanMoko> ejecuciones = planService.inicializarPlanParaFoco(focoId);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Plan inicializado correctamente");
            response.put("ejecuciones", ejecuciones);
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            Map<String, Object> error = new HashMap<>();
            error.put("success", false);
            error.put("error", "Error al inicializar plan: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
        }
    }

    /**
     * Obtiene el estado del plan de seguimiento para un foco
     */
    @GetMapping("/foco/{focoId}/estado")
    public ResponseEntity<Map<String, Object>> getEstadoPlan(@PathVariable Long focoId) {
        try {
            List<EjecucionPlanMoko> ejecuciones = planService.getEstadoPlanFoco(focoId);
            Map<String, Object> progreso = planService.getProgresoFoco(focoId);
            
            Map<String, Object> response = new HashMap<>();
            response.put("ejecuciones", ejecuciones);
            response.put("progreso", progreso);
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            Map<String, Object> error = new HashMap<>();
            error.put("error", "Error al obtener estado: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
        }
    }

    /**
     * Obtiene el progreso general del foco
     */
    @GetMapping("/foco/{focoId}/progreso")
    public ResponseEntity<Map<String, Object>> getProgresoFoco(@PathVariable Long focoId) {
        try {
            Map<String, Object> progreso = planService.getProgresoFoco(focoId);
            return ResponseEntity.ok(progreso);
        } catch (Exception e) {
            Map<String, Object> error = new HashMap<>();
            error.put("error", "Error al obtener progreso: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
        }
    }

    /**
     * Obtiene las tareas de una fase en ejecución
     */
    @GetMapping("/ejecucion/{ejecucionPlanId}/tareas")
    public ResponseEntity<List<EjecucionTareasMoko>> getTareasEjecucion(@PathVariable Long ejecucionPlanId) {
        try {
            List<EjecucionTareasMoko> tareas = planService.getTareasPorFase(ejecucionPlanId);
            return ResponseEntity.ok(tareas);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(null);
        }
    }

    /**
     * Actualiza el estado de una tarea específica
     */
    @PutMapping("/tarea/{tareaId}/estado")
    public ResponseEntity<Map<String, Object>> actualizarEstadoTarea(
            @PathVariable Long tareaId,
            @RequestParam boolean completado) {
        try {
            EjecucionTareasMoko tarea = planService.actualizarEstadoTarea(tareaId, completado);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("tarea", tarea);
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            Map<String, Object> error = new HashMap<>();
            error.put("success", false);
            error.put("error", "Error al actualizar tarea: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
        }
    }

    /**
     * Actualiza múltiples tareas de una fase
     */
    @PutMapping("/ejecucion/{ejecucionPlanId}/tareas")
    public ResponseEntity<Map<String, Object>> actualizarTareas(
            @PathVariable Long ejecucionPlanId,
            @RequestBody Map<String, List<Long>> body) {
        try {
            List<Long> tareasCompletadas = body.get("tareasCompletadas");
            if (tareasCompletadas == null) {
                tareasCompletadas = List.of();
            }
            
            List<EjecucionTareasMoko> tareas = planService.actualizarTareas(ejecucionPlanId, tareasCompletadas);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("tareas", tareas);
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            Map<String, Object> error = new HashMap<>();
            error.put("success", false);
            error.put("error", "Error al actualizar tareas: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
        }
    }

    /**
     * Finaliza la revisión de una fase
     */
    @PostMapping("/ejecucion/{ejecucionPlanId}/finalizar")
    public ResponseEntity<Map<String, Object>> finalizarRevision(
            @PathVariable Long ejecucionPlanId,
            @RequestBody(required = false) Map<String, String> body) {
        try {
            String observaciones = body != null ? body.get("observaciones") : null;
            EjecucionPlanMoko plan = planService.finalizarRevisionFase(ejecucionPlanId, observaciones);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Fase finalizada correctamente");
            response.put("plan", plan);
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            Map<String, Object> error = new HashMap<>();
            error.put("success", false);
            error.put("error", "Error al finalizar fase: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
        }
    }
}
