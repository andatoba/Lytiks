package com.lytiks.backend.controller;

import com.lytiks.backend.entity.MokoAudit;
import com.lytiks.backend.entity.MokoAuditDetail;
import com.lytiks.backend.repository.MokoAuditRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/moko-audits")
@CrossOrigin(origins = "*")
public class MokoAuditController {

    @Autowired
    private MokoAuditRepository mokoAuditRepository;

    // Crear nueva auditoría de Moko
    @PostMapping("/create")
    public ResponseEntity<Map<String, Object>> createMokoAudit(@RequestBody Map<String, Object> auditData) {
        Map<String, Object> response = new HashMap<>();
        try {
            MokoAudit mokoAudit = new MokoAudit();
            mokoAudit.setHacienda((String) auditData.get("hacienda"));
            mokoAudit.setLote((String) auditData.get("lote"));
            mokoAudit.setFecha(LocalDateTime.now());
            mokoAudit.setTecnicoId(Long.valueOf(auditData.get("tecnicoId").toString()));
            mokoAudit.setEstado("PENDIENTE");
            
            // Datos específicos del resumen Moko
            if (auditData.containsKey("evaluacionesTotales")) {
                mokoAudit.setEvaluacionesTotales(Integer.valueOf(auditData.get("evaluacionesTotales").toString()));
            }
            
            if (auditData.containsKey("programaManejoScore")) {
                mokoAudit.setProgramaManejoScore(Integer.valueOf(auditData.get("programaManejoScore").toString()));
            }
            
            if (auditData.containsKey("programaManejoTotal")) {
                mokoAudit.setProgramaManejoTotal(Integer.valueOf(auditData.get("programaManejoTotal").toString()));
            }
            
            if (auditData.containsKey("laboresMokoScore")) {
                mokoAudit.setLaboresMokoScore(Integer.valueOf(auditData.get("laboresMokoScore").toString()));
            }
            
            if (auditData.containsKey("laboresMokoTotal")) {
                mokoAudit.setLaboresMokoTotal(Integer.valueOf(auditData.get("laboresMokoTotal").toString()));
            }
            
            if (auditData.containsKey("cumplimientoGeneral")) {
                mokoAudit.setCumplimientoGeneral(Double.valueOf(auditData.get("cumplimientoGeneral").toString()));
            }
            
            if (auditData.containsKey("estadoImplementacion")) {
                mokoAudit.setEstadoImplementacion((String) auditData.get("estadoImplementacion"));
            }
            
            mokoAudit.setObservaciones((String) auditData.get("observaciones"));
            
            MokoAudit savedAudit = mokoAuditRepository.save(mokoAudit);
            
            response.put("success", true);
            response.put("message", "Auditoría de Moko creada exitosamente");
            response.put("auditId", savedAudit.getId());
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "Error al crear auditoría de Moko: " + e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }

    // Obtener auditorías de Moko por técnico
    @GetMapping("/technician/{tecnicoId}")
    public ResponseEntity<List<MokoAudit>> getMokoAuditsByTechnician(@PathVariable Long tecnicoId) {
        List<MokoAudit> audits = mokoAuditRepository.findByTecnicoId(tecnicoId);
        return ResponseEntity.ok(audits);
    }

    // Obtener auditoría de Moko por ID
    @GetMapping("/{id}")
    public ResponseEntity<MokoAudit> getMokoAuditById(@PathVariable Long id) {
        Optional<MokoAudit> audit = mokoAuditRepository.findById(id);
        return audit.map(ResponseEntity::ok).orElse(ResponseEntity.notFound().build());
    }

    // Obtener todas las auditorías de Moko
    @GetMapping("/all")
    public ResponseEntity<List<MokoAudit>> getAllMokoAudits() {
        List<MokoAudit> audits = mokoAuditRepository.findAll();
        return ResponseEntity.ok(audits);
    }

    // Actualizar estado de auditoría de Moko
    @PutMapping("/{id}/status")
    public ResponseEntity<Map<String, Object>> updateMokoAuditStatus(
            @PathVariable Long id, 
            @RequestBody Map<String, String> statusData) {
        
        Map<String, Object> response = new HashMap<>();
        try {
            Optional<MokoAudit> auditOpt = mokoAuditRepository.findById(id);
            if (auditOpt.isPresent()) {
                MokoAudit audit = auditOpt.get();
                audit.setEstado(statusData.get("estado"));
                mokoAuditRepository.save(audit);
                
                response.put("success", true);
                response.put("message", "Estado actualizado exitosamente");
                return ResponseEntity.ok(response);
            } else {
                response.put("success", false);
                response.put("message", "Auditoría de Moko no encontrada");
                return ResponseEntity.notFound().build();
            }
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "Error al actualizar estado: " + e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }

    // Obtener estadísticas de Moko para el dashboard
    @GetMapping("/dashboard/{tecnicoId}")
    public ResponseEntity<Map<String, Object>> getMokoDashboard(@PathVariable Long tecnicoId) {
        Map<String, Object> dashboard = new HashMap<>();
        
        try {
            // Contar auditorías de Moko totales
            long totalMokoAudits = mokoAuditRepository.countByTecnicoId(tecnicoId);
            
            // Contar auditorías de Moko de hoy
            long todayMokoAudits = mokoAuditRepository.countTodayMokoAuditsByTecnico(tecnicoId);
            
            // Promedio de cumplimiento
            Double avgCumplimiento = mokoAuditRepository.getAverageCumplimientoByTecnico(tecnicoId);
            if (avgCumplimiento == null) avgCumplimiento = 0.0;
            
            // Auditorías con cumplimiento bajo (menos del 80%)
            long lowCumplimientoAudits = mokoAuditRepository.findLowCumplimientoAudits(80.0).size();
            
            // Obtener auditorías recientes
            List<MokoAudit> recentMokoAudits = mokoAuditRepository.findRecentMokoAuditsByTecnico(tecnicoId)
                    .stream().limit(5).toList();
            
            dashboard.put("totalMokoAudits", totalMokoAudits);
            dashboard.put("todayMokoAudits", todayMokoAudits);
            dashboard.put("avgCumplimiento", Math.round(avgCumplimiento * 100.0) / 100.0);
            dashboard.put("lowCumplimientoAudits", lowCumplimientoAudits);
            dashboard.put("recentMokoAudits", recentMokoAudits);
            
            return ResponseEntity.ok(dashboard);
            
        } catch (Exception e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("error", "Error al obtener dashboard de Moko: " + e.getMessage());
            return ResponseEntity.badRequest().body(errorResponse);
        }
    }

    // Eliminar auditoría de Moko
    @DeleteMapping("/{id}")
    public ResponseEntity<Map<String, Object>> deleteMokoAudit(@PathVariable Long id) {
        Map<String, Object> response = new HashMap<>();
        try {
            if (mokoAuditRepository.existsById(id)) {
                mokoAuditRepository.deleteById(id);
                response.put("success", true);
                response.put("message", "Auditoría de Moko eliminada exitosamente");
                return ResponseEntity.ok(response);
            } else {
                response.put("success", false);
                response.put("message", "Auditoría de Moko no encontrada");
                return ResponseEntity.notFound().build();
            }
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "Error al eliminar auditoría de Moko: " + e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }
}