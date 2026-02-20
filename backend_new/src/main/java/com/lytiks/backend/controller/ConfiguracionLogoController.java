package com.lytiks.backend.controller;

import com.lytiks.backend.entity.ConfiguracionLogo;
import com.lytiks.backend.service.ConfiguracionLogoService;
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
@RequestMapping("/api/logo")
@CrossOrigin(origins = "*")
public class ConfiguracionLogoController {
    
    private static final Logger log = LoggerFactory.getLogger(ConfiguracionLogoController.class);
    
    @Autowired
    private ConfiguracionLogoService logoService;
    
    @GetMapping("/activo")
    public ResponseEntity<ConfiguracionLogo> getLogoActivo(@RequestParam(required = false) Integer idEmpresa) {
        log.info("GET /api/logo/activo - Obtener logo activo para empresa: {}", idEmpresa);
        ConfiguracionLogo logo;
        
        if (idEmpresa != null) {
            logo = logoService.getLogoActivoByEmpresa(idEmpresa);
        } else {
            logo = logoService.getLogoActivo();
        }
        
        if (logo != null) {
            return ResponseEntity.ok(logo);
        }
        return ResponseEntity.notFound().build();
    }
    
    @GetMapping
    public ResponseEntity<List<ConfiguracionLogo>> getAllLogos(@RequestParam(required = false) Integer idEmpresa) {
        log.info("GET /api/logo - Obtener todos los logos para empresa: {}", idEmpresa);
        
        List<ConfiguracionLogo> logos;
        if (idEmpresa != null) {
            logos = logoService.getLogosByEmpresa(idEmpresa);
        } else {
            logos = logoService.getAllLogos();
        }
        
        return ResponseEntity.ok(logos);
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<ConfiguracionLogo> getLogoById(@PathVariable Long id) {
        log.info("GET /api/logo/{} - Obtener logo por ID", id);
        return logoService.getLogoById(id)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }
    
    @PostMapping
    public ResponseEntity<Map<String, Object>> createLogo(@RequestBody ConfiguracionLogo logo) {
        log.info("POST /api/logo - Crear logo: {}", logo.getNombre());
        try {
            ConfiguracionLogo nuevoLogo = logoService.createLogo(logo);
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Logo creado exitosamente");
            response.put("data", nuevoLogo);
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
        } catch (Exception e) {
            log.error("Error creando logo", e);
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "Error creando logo: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<Map<String, Object>> updateLogo(@PathVariable Long id, @RequestBody ConfiguracionLogo logo) {
        log.info("PUT /api/logo/{} - Actualizar logo", id);
        try {
            ConfiguracionLogo logoActualizado = logoService.updateLogo(id, logo);
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Logo actualizado exitosamente");
            response.put("data", logoActualizado);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error actualizando logo", e);
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "Error actualizando logo: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }
    
    @PutMapping("/{id}/activar")
    public ResponseEntity<Map<String, Object>> activarLogo(@PathVariable Long id) {
        log.info("PUT /api/logo/{}/activar - Activar logo", id);
        try {
            logoService.activarLogo(id);
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Logo activado exitosamente");
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error activando logo", e);
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "Error activando logo: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<Map<String, Object>> deleteLogo(@PathVariable Long id) {
        log.info("DELETE /api/logo/{} - Eliminar logo", id);
        try {
            logoService.deleteLogo(id);
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Logo eliminado exitosamente");
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error eliminando logo", e);
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "Error eliminando logo: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }
}
