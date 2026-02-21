package com.lytiks.backend.controller;

import com.lytiks.backend.entity.Hacienda;
import com.lytiks.backend.service.HaciendaService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/haciendas")
@CrossOrigin(origins = "*")
public class HaciendaController {
    
    private static final Logger log = LoggerFactory.getLogger(HaciendaController.class);
    
    @Autowired
    private HaciendaService haciendaService;
    
    @GetMapping
    public ResponseEntity<List<Hacienda>> getAllHaciendas() {
        log.info("GET /api/haciendas - Obtener todas las haciendas");
        List<Hacienda> haciendas = haciendaService.getAllHaciendas();
        return ResponseEntity.ok(haciendas);
    }
    
    @GetMapping("/activas")
    public ResponseEntity<List<Hacienda>> getHaciendasActivas() {
        log.info("GET /api/haciendas/activas - Obtener haciendas activas");
        List<Hacienda> haciendas = haciendaService.getHaciendasActivas();
        return ResponseEntity.ok(haciendas);
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<Hacienda> getHaciendaById(@PathVariable Long id) {
        log.info("GET /api/haciendas/{} - Obtener hacienda por ID", id);
        return haciendaService.getHaciendaById(id)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }
    
    @GetMapping("/cliente/{clienteId}")
    public ResponseEntity<List<Hacienda>> getHaciendasByCliente(@PathVariable Long clienteId) {
        log.info("GET /api/haciendas/cliente/{} - Obtener haciendas por cliente", clienteId);
        List<Hacienda> haciendas = haciendaService.getHaciendasByCliente(clienteId);
        return ResponseEntity.ok(haciendas);
    }
    
    @GetMapping("/search")
    public ResponseEntity<List<Hacienda>> searchHaciendas(@RequestParam String nombre) {
        log.info("GET /api/haciendas/search?nombre={}", nombre);
        List<Hacienda> haciendas = haciendaService.searchHaciendas(nombre);
        return ResponseEntity.ok(haciendas);
    }
    
    @PostMapping
    public ResponseEntity<Map<String, Object>> createHacienda(@RequestBody Hacienda hacienda) {
        log.info("POST /api/haciendas - Crear hacienda: {}", hacienda.getNombre());
        try {
            Hacienda nuevaHacienda = haciendaService.createHacienda(hacienda);
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Hacienda creada exitosamente");
            response.put("data", nuevaHacienda);
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
        } catch (Exception e) {
            log.error("Error creando hacienda", e);
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "Error creando hacienda: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<Map<String, Object>> updateHacienda(@PathVariable Long id, @RequestBody Hacienda hacienda) {
        log.info("PUT /api/haciendas/{} - Actualizar hacienda", id);
        try {
            Hacienda haciendaActualizada = haciendaService.updateHacienda(id, hacienda);
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Hacienda actualizada exitosamente");
            response.put("data", haciendaActualizada);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error actualizando hacienda", e);
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "Error actualizando hacienda: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<Map<String, Object>> deleteHacienda(@PathVariable Long id) {
        log.info("DELETE /api/haciendas/{} - Eliminar hacienda", id);
        try {
            haciendaService.deleteHacienda(id);
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Hacienda eliminada exitosamente");
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error eliminando hacienda", e);
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "Error eliminando hacienda: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }
}
