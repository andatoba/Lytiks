package com.lytiks.backend.controller;

import com.lytiks.backend.entity.*;
import com.lytiks.backend.service.PlanSeguimientoMokoService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("moko/plan-seguimiento")
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

    /**
     * Actualiza observaciones de una fase sin finalizarla
     */
    @PutMapping("/ejecucion/{ejecucionPlanId}/observaciones")
    public ResponseEntity<Map<String, Object>> actualizarObservaciones(
            @PathVariable Long ejecucionPlanId,
            @RequestBody(required = false) Map<String, String> body) {
        try {
            String observaciones = body != null ? body.get("observaciones") : null;
            EjecucionPlanMoko plan = planService.actualizarObservacionesFase(ejecucionPlanId, observaciones);

            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Observaciones actualizadas correctamente");
            response.put("plan", plan);

            return ResponseEntity.ok(response);
        } catch (Exception e) {
            Map<String, Object> error = new HashMap<>();
            error.put("success", false);
            error.put("error", "Error al actualizar observaciones: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
        }
    }

    // =====================================================
    // ENDPOINTS PARA CONFIGURACIONES DE APLICACIÓN
    // =====================================================

    /**
     * Guarda o actualiza una configuración de aplicación
     */
    @PostMapping("/configuracion-aplicacion")
    public ResponseEntity<Map<String, Object>> guardarConfiguracionAplicacion(
            @RequestBody ConfiguracionAplicacion configuracion) {
        try {
            ConfiguracionAplicacion saved = planService.guardarConfiguracionAplicacion(configuracion);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Configuración guardada correctamente");
            response.put("configuracion", saved);
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            Map<String, Object> error = new HashMap<>();
            error.put("success", false);
            error.put("error", "Error al guardar configuración: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
        }
    }

    /**
     * Guarda o actualiza múltiples configuraciones de aplicación.
     */
    @PostMapping("/configuracion-aplicacion/bulk")
    public ResponseEntity<Map<String, Object>> guardarConfiguracionesAplicacionBulk(
            @RequestBody List<ConfiguracionAplicacion> configuraciones) {
        try {
            List<ConfiguracionAplicacion> guardadas =
                    planService.guardarConfiguracionesAplicacionBulk(configuraciones);

            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Configuraciones guardadas correctamente");
            response.put("total", guardadas.size());
            response.put("configuraciones", guardadas);

            return ResponseEntity.ok(response);
        } catch (Exception e) {
            Map<String, Object> error = new HashMap<>();
            error.put("success", false);
            error.put("error", "Error al guardar configuraciones: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
        }
    }

    /**
     * Obtiene todas las configuraciones de un foco
     */
    @GetMapping("/foco/{focoId}/configuraciones")
    public ResponseEntity<List<ConfiguracionAplicacion>> getConfiguracionesByFoco(@PathVariable Long focoId) {
        try {
            List<ConfiguracionAplicacion> configuraciones = planService.getConfiguracionesByFoco(focoId);
            return ResponseEntity.ok(configuraciones);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(null);
        }
    }

    /**
     * Obtiene las configuraciones de un foco y fase específica
     */
    @GetMapping("/foco/{focoId}/fase/{faseId}/configuraciones")
    public ResponseEntity<List<ConfiguracionAplicacion>> getConfiguracionesByFocoYFase(
            @PathVariable Long focoId,
            @PathVariable Long faseId) {
        try {
            List<ConfiguracionAplicacion> configuraciones = planService.getConfiguracionesByFocoYFase(focoId, faseId);
            return ResponseEntity.ok(configuraciones);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(null);
        }
    }

    /**
     * Obtiene configuraciones pendientes de un foco
     */
    @GetMapping("/foco/{focoId}/configuraciones/pendientes")
    public ResponseEntity<List<ConfiguracionAplicacion>> getConfiguracionesPendientes(@PathVariable Long focoId) {
        try {
            List<ConfiguracionAplicacion> configuraciones = planService.getConfiguracionesPendientes(focoId);
            return ResponseEntity.ok(configuraciones);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(null);
        }
    }

    /**
     * Marca una configuración como completada
     */
    @PutMapping("/configuracion-aplicacion/{id}/completar")
    public ResponseEntity<Map<String, Object>> completarConfiguracion(@PathVariable Long id) {
        try {
            ConfiguracionAplicacion config = planService.marcarConfiguracionCompletada(id);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Configuración marcada como completada");
            response.put("configuracion", config);
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            Map<String, Object> error = new HashMap<>();
            error.put("success", false);
            error.put("error", "Error al completar configuración: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
        }
    }

    /**
     * Elimina una configuración
     */
    @DeleteMapping("/configuracion-aplicacion/{id}")
    public ResponseEntity<Map<String, Object>> eliminarConfiguracion(@PathVariable Long id) {
        try {
            planService.eliminarConfiguracion(id);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Configuración eliminada correctamente");
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            Map<String, Object> error = new HashMap<>();
            error.put("success", false);
            error.put("error", "Error al eliminar configuración: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
        }
    }

    /**
     * Cuenta las configuraciones pendientes de un foco
     */
    @GetMapping("/foco/{focoId}/configuraciones/pendientes/count")
    public ResponseEntity<Map<String, Object>> contarConfiguracionesPendientes(@PathVariable Long focoId) {
        try {
            Long count = planService.contarConfiguracionesPendientes(focoId);
            
            Map<String, Object> response = new HashMap<>();
            response.put("count", count);
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            Map<String, Object> error = new HashMap<>();
            error.put("error", "Error al contar configuraciones: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
        }
    }

    @PostMapping("/preventivo/guardar-completo")
    public ResponseEntity<Map<String, Object>> guardarPreventivoCompleto(
            @RequestBody Map<String, Object> payload) {
        try {
            Long focoId = toLong(payload.get("focoId"));
            Integer numeroFoco = toInteger(payload.get("numeroFoco"));
            LocalDateTime fechaInicioPlan = toDateTime(payload.get("fechaInicioPlan"));

            if (focoId == null) {
                Map<String, Object> error = new HashMap<>();
                error.put("success", false);
                error.put("error", "focoId es obligatorio");
                return ResponseEntity.badRequest().body(error);
            }

            MokoPreventivoAuditoria auditoria = planService.guardarProgramaPreventivoCompleto(
                    focoId,
                    numeroFoco,
                    fechaInicioPlan,
                    payload
            );

            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Programa preventivo guardado correctamente");
            response.put("auditoria", auditoria);
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
        } catch (Exception e) {
            Map<String, Object> error = new HashMap<>();
            error.put("success", false);
            error.put("error", "Error al guardar preventivo completo: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
        }
    }

    @GetMapping("/foco/{focoId}/preventivo/ultima-auditoria")
    public ResponseEntity<Map<String, Object>> getUltimaAuditoriaPreventivo(@PathVariable Long focoId) {
        return planService.getUltimoPreventivoPorFoco(focoId)
                .<ResponseEntity<Map<String, Object>>>map(auditoria -> {
                    Map<String, Object> response = new HashMap<>();
                    response.put("success", true);
                    response.put("auditoria", auditoria);
                    return ResponseEntity.ok(response);
                })
                .orElseGet(() -> {
                    Map<String, Object> response = new HashMap<>();
                    response.put("success", false);
                    response.put("message", "No existe auditoría preventiva para el foco");
                    return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
                });
    }

    private Long toLong(Object value) {
        if (value == null) {
            return null;
        }
        if (value instanceof Number number) {
            return number.longValue();
        }
        try {
            return Long.parseLong(value.toString());
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private Integer toInteger(Object value) {
        if (value == null) {
            return null;
        }
        if (value instanceof Number number) {
            return number.intValue();
        }
        try {
            return Integer.parseInt(value.toString());
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private LocalDateTime toDateTime(Object value) {
        if (value == null) {
            return null;
        }
        try {
            return LocalDateTime.parse(value.toString());
        } catch (Exception e) {
            return null;
        }
    }
}
