package com.lytiks.backend.controller;

import com.lytiks.backend.entity.Lote;
import com.lytiks.backend.service.LoteService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/lotes")
@Slf4j
@CrossOrigin(origins = "*")
public class LoteController {
    
    @Autowired
    private LoteService loteService;
    
    @GetMapping
    public ResponseEntity<List<Lote>> getAllLotes() {
        log.info("GET /api/lotes - Obtener todos los lotes");
        List<Lote> lotes = loteService.getAllLotes();
        return ResponseEntity.ok(lotes);
    }
    
    @GetMapping("/activos")
    public ResponseEntity<List<Lote>> getLotesActivos() {
        log.info("GET /api/lotes/activos - Obtener lotes activos");
        List<Lote> lotes = loteService.getLotesActivos();
        return ResponseEntity.ok(lotes);
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<Lote> getLoteById(@PathVariable Long id) {
        log.info("GET /api/lotes/{} - Obtener lote por ID", id);
        return loteService.getLoteById(id)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }
    
    @GetMapping("/hacienda/{haciendaId}")
    public ResponseEntity<List<Lote>> getLotesByHacienda(@PathVariable Long haciendaId) {
        log.info("GET /api/lotes/hacienda/{} - Obtener lotes por hacienda", haciendaId);
        List<Lote> lotes = loteService.getLotesByHacienda(haciendaId);
        return ResponseEntity.ok(lotes);
    }
    
    @GetMapping("/search")
    public ResponseEntity<List<Lote>> searchLotes(@RequestParam String nombre) {
        log.info("GET /api/lotes/search?nombre={}", nombre);
        List<Lote> lotes = loteService.searchLotes(nombre);
        return ResponseEntity.ok(lotes);
    }
    
    @GetMapping("/search/codigo")
    public ResponseEntity<List<Lote>> searchLotesByCodigo(@RequestParam String codigo) {
        log.info("GET /api/lotes/search/codigo?codigo={}", codigo);
        List<Lote> lotes = loteService.searchLotesByCodigo(codigo);
        return ResponseEntity.ok(lotes);
    }
    
    @PostMapping
    public ResponseEntity<Map<String, Object>> createLote(@RequestBody Lote lote) {
        log.info("POST /api/lotes - Crear lote: {}", lote.getNombre());
        try {
            Lote nuevoLote = loteService.createLote(lote);
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Lote creado exitosamente");
            response.put("data", nuevoLote);
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
        } catch (Exception e) {
            log.error("Error creando lote", e);
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "Error creando lote: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<Map<String, Object>> updateLote(@PathVariable Long id, @RequestBody Lote lote) {
        log.info("PUT /api/lotes/{} - Actualizar lote", id);
        try {
            Lote loteActualizado = loteService.updateLote(id, lote);
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Lote actualizado exitosamente");
            response.put("data", loteActualizado);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error actualizando lote", e);
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "Error actualizando lote: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<Map<String, Object>> deleteLote(@PathVariable Long id) {
        log.info("DELETE /api/lotes/{} - Eliminar lote", id);
        try {
            loteService.deleteLote(id);
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Lote eliminado exitosamente");
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error eliminando lote", e);
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "Error eliminando lote: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }
}
