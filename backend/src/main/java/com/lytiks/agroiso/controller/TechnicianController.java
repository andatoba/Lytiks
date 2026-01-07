package com.lytiks.agroiso.controller;

import org.springframework.web.bind.annotation.*;
import org.springframework.http.ResponseEntity;
import java.util.List;
import java.util.Map;
import java.util.ArrayList;

@RestController
@RequestMapping("/api/technician")
@CrossOrigin(origins = "*")
public class TechnicianController {
    
    @GetMapping("/audits")
    public ResponseEntity<?> getAssignedAudits() {
        // Simulando auditorías asignadas al técnico
        List<Map<String, Object>> audits = new ArrayList<>();
        
        audits.add(Map.of(
            "id", 1,
            "title", "Auditoría de Calidad - Finca Los Mangos",
            "client", "Agricola San José",
            "status", "PENDING",
            "dueDate", "2025-10-25",
            "category", "Quality Control",
            "priority", "HIGH"
        ));
        
        audits.add(Map.of(
            "id", 2,
            "title", "Inspección de Seguridad - Cultivo Banano",
            "client", "Hacienda El Progreso",
            "status", "IN_PROGRESS",
            "dueDate", "2025-10-28",
            "category", "Safety",
            "priority", "MEDIUM"
        ));
        
        audits.add(Map.of(
            "id", 3,
            "title", "Auditoría Ambiental - Plantación Palma",
            "client", "Palmas del Norte",
            "status", "COMPLETED",
            "dueDate", "2025-10-20",
            "category", "Environmental",
            "priority", "LOW"
        ));
        
        return ResponseEntity.ok(Map.of(
            "audits", audits,
            "total", audits.size(),
            "pending", 1,
            "inProgress", 1,
            "completed", 1
        ));
    }
    
    @GetMapping("/audit/{auditId}")
    public ResponseEntity<?> getAuditDetails(@PathVariable Long auditId) {
        // Simulando detalles de una auditoría específica
        Map<String, Object> auditDetails = Map.of(
            "id", auditId,
            "title", "Auditoría de Calidad - Finca Los Mangos",
            "client", Map.of(
                "name", "Agricola San José",
                "contact", "Juan Pérez",
                "phone", "+57 300 123 4567",
                "location", "Vereda Los Mangos, Quindío"
            ),
            "category", "Quality Control",
            "status", "PENDING",
            "dueDate", "2025-10-25",
            "priority", "HIGH",
            "description", "Auditoría completa de procesos de calidad en el cultivo de café",
            "checklist", List.of(
                Map.of("id", 1, "item", "Verificar estado de plantaciones", "completed", false),
                Map.of("id", 2, "item", "Revisar proceso de cosecha", "completed", false),
                Map.of("id", 3, "item", "Inspeccionar instalaciones", "completed", false),
                Map.of("id", 4, "item", "Verificar certificaciones", "completed", false)
            )
        );
        
        return ResponseEntity.ok(auditDetails);
    }
    
    @PostMapping("/audit/{auditId}/start")
    public ResponseEntity<?> startAudit(@PathVariable Long auditId) {
        return ResponseEntity.ok(Map.of(
            "message", "Auditoría iniciada correctamente",
            "auditId", auditId,
            "status", "IN_PROGRESS",
            "startedAt", "2025-10-21T21:45:00Z"
        ));
    }
    
    @PostMapping("/audit/{auditId}/complete")
    public ResponseEntity<?> completeAudit(@PathVariable Long auditId, @RequestBody Map<String, Object> auditData) {
        return ResponseEntity.ok(Map.of(
            "message", "Auditoría completada exitosamente",
            "auditId", auditId,
            "status", "COMPLETED",
            "completedAt", "2025-10-21T21:45:00Z"
        ));
    }
    
    @GetMapping("/dashboard")
    public ResponseEntity<?> getTechnicianDashboard() {
        Map<String, Object> dashboard = Map.of(
            "welcomeMessage", "Bienvenido, Técnico",
            "stats", Map.of(
                "totalAudits", 15,
                "pendingAudits", 3,
                "completedThisMonth", 8,
                "averageScore", 92.5
            ),
            "recentActivity", List.of(
                Map.of("activity", "Auditoría completada", "client", "Finca El Paraíso", "date", "2025-10-20"),
                Map.of("activity", "Nuevo cliente asignado", "client", "Hacienda Verde", "date", "2025-10-19"),
                Map.of("activity", "Reporte enviado", "client", "Cultivos del Valle", "date", "2025-10-18")
            )
        );
        
        return ResponseEntity.ok(dashboard);
    }
}