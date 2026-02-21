package com.lytiks.backend.controller;

import com.lytiks.backend.dto.*;
import com.lytiks.backend.entity.*;
import com.lytiks.backend.service.SigatokaEvaluacionServiceCompleto;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Controlador REST para evaluaciones de Sigatoka (REDISEÑADO - Estructura Excel Completa)
 * 
 * Endpoints disponibles (con context-path /api):
 * POST   /api/sigatoka/crear-evaluacion           - Crear encabezado evaluación
 * POST   /api/sigatoka/{id}/lotes                 - Agregar lote a evaluación
 * POST   /api/sigatoka/lotes/{id}/muestras        - Agregar muestra a lote
 * POST   /api/sigatoka/lotes/{id}/muestras/bulk   - Agregar múltiples muestras
 * GET    /api/sigatoka/{id}                       - Obtener evaluación completa
 * GET    /api/sigatoka/evaluaciones               - Obtener todas las evaluaciones
 * GET    /api/sigatoka/cliente/{id}               - Obtener evaluaciones por cliente
 * GET    /api/sigatoka/{id}/lotes                 - Obtener lotes de evaluación
 * GET    /api/sigatoka/lotes/{id}/muestras        - Obtener muestras de lote
 * GET    /api/sigatoka/{id}/todas-muestras        - Obtener todas las muestras
 * GET    /api/sigatoka/{id}/resumen               - Calcular resumen (a-e)
 * GET    /api/sigatoka/{id}/indicadores           - Calcular indicadores (f-k)
 * GET    /api/sigatoka/{id}/estado-evolutivo      - Calcular EE
 * GET    /api/sigatoka/{id}/stover                - Calcular Stover
 * POST   /api/sigatoka/{id}/calcular-todo         - Calcular todo de una vez
 * PUT    /api/sigatoka/{id}                       - Actualizar evaluación
 * DELETE /api/sigatoka/{id}                       - Eliminar evaluación
 * DELETE /api/sigatoka/lotes/{id}                 - Eliminar lote
 * DELETE /api/sigatoka/muestras/{id}              - Eliminar muestra
 */
@RestController
@RequestMapping("/sigatoka")
@CrossOrigin(origins = "*")
public class SigatokaEvaluacionController {
    
    private static final Logger log = LoggerFactory.getLogger(SigatokaEvaluacionController.class);
    
    @Autowired
    private SigatokaEvaluacionServiceCompleto evaluacionService;
    
    /**
     * Crear nueva evaluación (solo encabezado)
     */
    @PostMapping("/crear-evaluacion")
    public ResponseEntity<SigatokaEvaluacion> crearEvaluacion(@RequestBody SigatokaEvaluacionDTO dto) {
        log.info("Creando evaluación: hacienda={}, fecha={}", dto.getHacienda(), dto.getFecha());
        SigatokaEvaluacion evaluacion = evaluacionService.crearEvaluacion(dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(evaluacion);
    }

    /**
     * Agregar lote a una evaluación
     */
    @PostMapping("/{evaluacionId}/lotes")
    public ResponseEntity<SigatokaLote> agregarLote(
            @PathVariable Long evaluacionId,
            @RequestBody SigatokaLoteDTO loteDTO) {
        log.info("Agregando lote {} a evaluación {}", loteDTO.getLoteCodigo(), evaluacionId);
        SigatokaLote lote = evaluacionService.agregarLote(evaluacionId, loteDTO);
        return ResponseEntity.ok(lote);
    }

    /**
     * Agregar muestra completa a un lote
     */
    @PostMapping("/lotes/{loteId}/muestras")
    public ResponseEntity<SigatokaMuestraCompleta> agregarMuestra(
            @PathVariable Long loteId,
            @RequestBody SigatokaMuestraCompletaDTO muestraDTO) {
        log.info("Agregando muestra #{} a lote {}", muestraDTO.getMuestraNum(), loteId);
        SigatokaMuestraCompleta muestra = evaluacionService.agregarMuestra(loteId, muestraDTO);
        return ResponseEntity.ok(muestra);
    }

    /**
     * Agregar múltiples muestras a un lote de una vez
     */
    @PostMapping("/lotes/{loteId}/muestras/bulk")
    public ResponseEntity<List<SigatokaMuestraCompleta>> agregarMuestrasMultiples(
            @PathVariable Long loteId,
            @RequestBody List<SigatokaMuestraCompletaDTO> muestrasDTO) {
        log.info("Agregando {} muestras a lote {}", muestrasDTO.size(), loteId);
        List<SigatokaMuestraCompleta> muestras = evaluacionService.agregarMuestrasMultiples(loteId, muestrasDTO);
        return ResponseEntity.ok(muestras);
    }

    /**
     * Obtener evaluación con todos los lotes y muestras
     */
    @GetMapping("/{evaluacionId}")
    public ResponseEntity<SigatokaEvaluacion> obtenerEvaluacion(@PathVariable Long evaluacionId) {
        log.info("Obteniendo evaluación {}", evaluacionId);
        SigatokaEvaluacion evaluacion = evaluacionService.obtenerEvaluacionCompleta(evaluacionId);
        return ResponseEntity.ok(evaluacion);
    }

    /**
     * Obtener todas las evaluaciones (opcional filtrar por clienteId)
     */
    @GetMapping("/evaluaciones")
    public ResponseEntity<List<SigatokaEvaluacion>> obtenerEvaluaciones(
            @RequestParam(required = false) Long clienteId) {
        if (clienteId != null) {
            log.info("Obteniendo evaluaciones del cliente {}", clienteId);
            return ResponseEntity.ok(evaluacionService.obtenerEvaluacionesPorCliente(clienteId));
        }
        log.info("Obteniendo todas las evaluaciones");
        return ResponseEntity.ok(evaluacionService.obtenerTodasEvaluaciones());
    }

    /**
     * Obtener todas las evaluaciones de un cliente
     */
    @GetMapping("/cliente/{clienteId}")
    public ResponseEntity<List<SigatokaEvaluacion>> obtenerEvaluacionesPorCliente(@PathVariable Long clienteId) {
        log.info("Obteniendo evaluaciones del cliente {}", clienteId);
        List<SigatokaEvaluacion> evaluaciones = evaluacionService.obtenerEvaluacionesPorCliente(clienteId);
        return ResponseEntity.ok(evaluaciones);
    }

    /**
     * Obtener lotes de una evaluación
     */
    @GetMapping("/{evaluacionId}/lotes")
    public ResponseEntity<List<SigatokaLote>> obtenerLotes(@PathVariable Long evaluacionId) {
        log.info("Obteniendo lotes de evaluación {}", evaluacionId);
        List<SigatokaLote> lotes = evaluacionService.obtenerLotesPorEvaluacion(evaluacionId);
        return ResponseEntity.ok(lotes);
    }

    /**
     * Obtener muestras de un lote específico
     */
    @GetMapping("/lotes/{loteId}/muestras")
    public ResponseEntity<List<SigatokaMuestraCompleta>> obtenerMuestrasPorLote(@PathVariable Long loteId) {
        log.info("Obteniendo muestras del lote {}", loteId);
        List<SigatokaMuestraCompleta> muestras = evaluacionService.obtenerMuestrasPorLote(loteId);
        return ResponseEntity.ok(muestras);
    }

    /**
     * Obtener TODAS las muestras de una evaluación (agrupadas por lote)
     */
    @GetMapping("/{evaluacionId}/todas-muestras")
    public ResponseEntity<List<SigatokaMuestraCompleta>> obtenerTodasMuestras(@PathVariable Long evaluacionId) {
        log.info("Obteniendo todas las muestras de evaluación {}", evaluacionId);
        List<SigatokaMuestraCompleta> muestras = evaluacionService.obtenerTodasMuestrasPorEvaluacion(evaluacionId);
        return ResponseEntity.ok(muestras);
    }

    /**
     * Calcular y obtener resumen (promedios a-e)
     */
    @GetMapping("/{evaluacionId}/resumen")
    public ResponseEntity<SigatokaResumen> obtenerResumen(@PathVariable Long evaluacionId) {
        log.info("Calculando resumen para evaluación {}", evaluacionId);
        SigatokaResumen resumen = evaluacionService.calcularResumen(evaluacionId);
        return ResponseEntity.ok(resumen);
    }

    /**
     * Calcular y obtener indicadores (f-k)
     */
    @GetMapping("/{evaluacionId}/indicadores")
    public ResponseEntity<SigatokaIndicadores> obtenerIndicadores(@PathVariable Long evaluacionId) {
        log.info("Calculando indicadores para evaluación {}", evaluacionId);
        SigatokaIndicadores indicadores = evaluacionService.calcularIndicadores(evaluacionId);
        return ResponseEntity.ok(indicadores);
    }

    /**
     * Calcular y obtener estado evolutivo (EE)
     */
    @GetMapping("/{evaluacionId}/estado-evolutivo")
    public ResponseEntity<SigatokaEstadoEvolutivo> obtenerEstadoEvolutivo(@PathVariable Long evaluacionId) {
        log.info("Calculando estado evolutivo para evaluación {}", evaluacionId);
        SigatokaEstadoEvolutivo estado = evaluacionService.calcularEstadoEvolutivo(evaluacionId);
        return ResponseEntity.ok(estado);
    }

    /**
     * Calcular y obtener promedios Stover
     */
    @GetMapping("/{evaluacionId}/stover")
    public ResponseEntity<SigatokaStoverPromedio> obtenerStover(@PathVariable Long evaluacionId) {
        log.info("Calculando Stover para evaluación {}", evaluacionId);
        SigatokaStoverPromedio stover = evaluacionService.calcularStover(evaluacionId);
        return ResponseEntity.ok(stover);
    }

    /**
     * Calcular TODO de una vez (resumen, indicadores, estado evolutivo, stover)
     */
    @PostMapping("/{evaluacionId}/calcular-todo")
    public ResponseEntity<SigatokaReporteCompletoDTO> calcularTodo(@PathVariable Long evaluacionId) {
        log.info("Calculando TODO para evaluación {}", evaluacionId);
        SigatokaReporteCompletoDTO reporte = evaluacionService.calcularTodo(evaluacionId);
        return ResponseEntity.ok(reporte);
    }

    /**
     * Actualizar evaluación
     */
    @PutMapping("/{evaluacionId}")
    public ResponseEntity<SigatokaEvaluacion> actualizarEvaluacion(
            @PathVariable Long evaluacionId,
            @RequestBody SigatokaEvaluacionDTO dto) {
        log.info("Actualizando evaluación {}", evaluacionId);
        SigatokaEvaluacion evaluacion = evaluacionService.actualizarEvaluacion(evaluacionId, dto);
        return ResponseEntity.ok(evaluacion);
    }

    /**
     * Eliminar evaluación (cascada elimina lotes y muestras)
     */
    @DeleteMapping("/{evaluacionId}")
    public ResponseEntity<Void> eliminarEvaluacion(@PathVariable Long evaluacionId) {
        log.info("Eliminando evaluación {}", evaluacionId);
        evaluacionService.eliminarEvaluacion(evaluacionId);
        return ResponseEntity.noContent().build();
    }

    /**
     * Eliminar lote (cascada elimina muestras)
     */
    @DeleteMapping("/lotes/{loteId}")
    public ResponseEntity<Void> eliminarLote(@PathVariable Long loteId) {
        log.info("Eliminando lote {}", loteId);
        evaluacionService.eliminarLote(loteId);
        return ResponseEntity.noContent().build();
    }

    /**
     * Eliminar muestra individual
     */
    @DeleteMapping("/muestras/{muestraId}")
    public ResponseEntity<Void> eliminarMuestra(@PathVariable Long muestraId) {
        log.info("Eliminando muestra {}", muestraId);
        evaluacionService.eliminarMuestra(muestraId);
        return ResponseEntity.noContent().build();
    }
}
