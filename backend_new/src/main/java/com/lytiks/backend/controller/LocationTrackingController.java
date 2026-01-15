package com.lytiks.backend.controller;

import com.lytiks.backend.dto.LocationTrackingDTO;
import com.lytiks.backend.entity.LocationTracking;
import com.lytiks.backend.service.LocationTrackingService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/location-tracking")
@CrossOrigin(origins = "*")
public class LocationTrackingController {
    
    @Autowired
    private LocationTrackingService locationTrackingService;
    
    /**
     * Guardar una nueva ubicación del técnico
     * POST /api/location-tracking
     */
    @PostMapping
    public ResponseEntity<Map<String, Object>> saveLocation(@RequestBody LocationTrackingDTO dto) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            // Validar datos requeridos
            if (dto.getUserId() == null || dto.getUserId().isEmpty()) {
                response.put("success", false);
                response.put("message", "El ID de usuario es requerido");
                return ResponseEntity.badRequest().body(response);
            }
            
            if (dto.getLatitude() == null || dto.getLongitude() == null) {
                response.put("success", false);
                response.put("message", "Las coordenadas son requeridas");
                return ResponseEntity.badRequest().body(response);
            }
            
            // Guardar ubicación
            LocationTracking savedLocation = locationTrackingService.saveLocation(dto);
            
            response.put("success", true);
            response.put("message", "Ubicación guardada exitosamente");
            response.put("data", savedLocation);
            
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "Error al guardar la ubicación: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }
    
    /**
     * Obtener todas las ubicaciones de un usuario
     * GET /api/location-tracking/user/{userId}
     */
    @GetMapping("/user/{userId}")
    public ResponseEntity<Map<String, Object>> getLocationsByUserId(@PathVariable String userId) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            List<LocationTracking> locations = locationTrackingService.getLocationsByUserId(userId);
            
            response.put("success", true);
            response.put("count", locations.size());
            response.put("data", locations);
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "Error al obtener ubicaciones: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }
    
    /**
     * Obtener ubicaciones de hoy de un usuario
     * GET /api/location-tracking/user/{userId}/today
     */
    @GetMapping("/user/{userId}/today")
    public ResponseEntity<Map<String, Object>> getTodayLocationsByUserId(@PathVariable String userId) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            List<LocationTracking> locations = locationTrackingService.getTodayLocationsByUserId(userId);
            
            response.put("success", true);
            response.put("count", locations.size());
            response.put("data", locations);
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "Error al obtener ubicaciones de hoy: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }
    
    /**
     * Obtener ubicaciones en horario laboral (8AM-4PM) de un usuario
     * GET /api/location-tracking/user/{userId}/work-hours
     */
    @GetMapping("/user/{userId}/work-hours")
    public ResponseEntity<Map<String, Object>> getWorkHoursLocationsByUserId(@PathVariable String userId) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            List<LocationTracking> locations = locationTrackingService.getWorkHoursLocationsByUserId(userId);
            
            response.put("success", true);
            response.put("count", locations.size());
            response.put("data", locations);
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "Error al obtener ubicaciones: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }
    
    /**
     * Obtener todas las ubicaciones de hoy (todos los usuarios)
     * GET /api/location-tracking/today
     */
    @GetMapping("/today")
    public ResponseEntity<Map<String, Object>> getTodayLocations() {
        Map<String, Object> response = new HashMap<>();
        
        try {
            List<LocationTracking> locations = locationTrackingService.getTodayLocations();
            
            response.put("success", true);
            response.put("count", locations.size());
            response.put("data", locations);
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "Error al obtener ubicaciones: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }
    
    /**
     * Obtener todas las ubicaciones (administración)
     * GET /api/location-tracking
     */
    @GetMapping
    public ResponseEntity<Map<String, Object>> getAllLocations() {
        Map<String, Object> response = new HashMap<>();
        
        try {
            List<LocationTracking> locations = locationTrackingService.getAllLocations();
            
            response.put("success", true);
            response.put("count", locations.size());
            response.put("data", locations);
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "Error al obtener ubicaciones: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }
    
    /**
     * Obtener rango de fechas específico para un usuario
     * GET /api/location-tracking/user/{userId}/range
     */
    @GetMapping("/user/{userId}/range")
    public ResponseEntity<Map<String, Object>> getLocationsByDateRange(
            @PathVariable String userId,
            @RequestParam String startDate,
            @RequestParam String endDate) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            LocalDateTime start = LocalDateTime.parse(startDate);
            LocalDateTime end = LocalDateTime.parse(endDate);
            
            List<LocationTracking> locations = locationTrackingService
                .getLocationsByUserIdAndDateRange(userId, start, end);
            
            response.put("success", true);
            response.put("count", locations.size());
            response.put("data", locations);
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "Error al obtener ubicaciones: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }
    
    /**
     * Limpiar ubicaciones antiguas (más de X días)
     * DELETE /api/location-tracking/cleanup?days=90
     */
    @DeleteMapping("/cleanup")
    public ResponseEntity<Map<String, Object>> cleanupOldLocations(
            @RequestParam(defaultValue = "90") int days) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            int deletedCount = locationTrackingService.cleanOldLocations(days);
            
            response.put("success", true);
            response.put("message", "Limpieza completada");
            response.put("deletedCount", deletedCount);
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "Error al limpiar ubicaciones: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }
}
