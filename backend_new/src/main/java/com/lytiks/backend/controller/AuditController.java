package com.lytiks.backend.controller;

import com.lytiks.backend.entity.Audit;
import com.lytiks.backend.entity.AuditScore;
import com.lytiks.backend.entity.AuditPhoto;
import com.lytiks.backend.entity.MokoAudit;
import com.lytiks.backend.repository.AuditRepository;
import com.lytiks.backend.repository.AuditScoreRepository;
import com.lytiks.backend.repository.AuditPhotoRepository;
import com.lytiks.backend.repository.MokoAuditRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/audits")
@CrossOrigin(origins = "*")
public class AuditController {

    @Autowired
    private AuditRepository auditRepository;
    
    @Autowired
    private AuditScoreRepository auditScoreRepository;
    
    @Autowired
    private AuditPhotoRepository auditPhotoRepository;
    
    @Autowired
    private MokoAuditRepository mokoAuditRepository;

    // Crear nueva auditoría
    @PostMapping("/create")
public ResponseEntity<Map<String, Object>> createAudit(@RequestBody Map<String, Object> auditData) {
    Map<String, Object> response = new HashMap<>();
    try {
        Audit audit = new Audit();
        audit.setHacienda(auditData.get("hacienda") != null ? auditData.get("hacienda").toString() : null);
        audit.setCultivo(auditData.get("cultivo") != null ? auditData.get("cultivo").toString() : null);
        audit.setFecha(auditData.get("fecha") != null ? LocalDateTime.parse(auditData.get("fecha").toString()) : LocalDateTime.now());
        audit.setTecnicoId(auditData.get("tecnicoId") != null ? Long.valueOf(auditData.get("tecnicoId").toString()) : null);
        audit.setEstado(auditData.get("estado") != null ? auditData.get("estado").toString() : "PENDIENTE");
        audit.setObservaciones((String) auditData.get("observaciones"));
        // Si tu entidad Audit tiene estos campos, agrégalos:
       // if (auditData.get("foto") != null) {
       //     audit.setFoto(auditData.get("foto").toString());
       // }

        Audit savedAudit = auditRepository.save(audit);

        // Guardar puntuaciones si existen
        if (auditData.containsKey("scores")) {
            @SuppressWarnings("unchecked")
            List<Map<String, Object>> scores = (List<Map<String, Object>>) auditData.get("scores");
            for (Map<String, Object> scoreData : scores) {
                AuditScore score = new AuditScore();
                score.setAudit(savedAudit);
                score.setCategoria((String) scoreData.get("categoria"));
                score.setPuntuacion(Integer.valueOf(scoreData.get("puntuacion").toString()));
                score.setObservaciones((String) scoreData.get("observaciones"));
                auditScoreRepository.save(score);
            }
        }

        response.put("success", true);
        response.put("message", "Auditoría creada exitosamente");
        response.put("auditId", savedAudit.getId());
        return ResponseEntity.ok(response);

    } catch (Exception e) {
        response.put("success", false);
        response.put("message", "Error al crear auditoría: " + e.getMessage());
        return ResponseEntity.badRequest().body(response);
    }
}

    // Obtener auditorías por técnico
    @GetMapping("/technician/{tecnicoId}")
    public ResponseEntity<List<Audit>> getAuditsByTechnician(@PathVariable Long tecnicoId) {
        List<Audit> audits = auditRepository.findByTecnicoId(tecnicoId);
        return ResponseEntity.ok(audits);
    }

    // Obtener auditoría por ID
    @GetMapping("/{id}")
    public ResponseEntity<Audit> getAuditById(@PathVariable Long id) {
        Optional<Audit> audit = auditRepository.findById(id);
        return audit.map(ResponseEntity::ok).orElse(ResponseEntity.notFound().build());
    }

    // Obtener todas las auditorías
    @GetMapping("/all")
    public ResponseEntity<List<Audit>> getAllAudits() {
        List<Audit> audits = auditRepository.findAll();
        return ResponseEntity.ok(audits);
    }

    // Obtener puntuaciones de una auditoría
    @GetMapping("/{auditId}/scores")
    public ResponseEntity<List<AuditScore>> getAuditScores(@PathVariable Long auditId) {
        List<AuditScore> scores = auditScoreRepository.findByAuditId(auditId);
        return ResponseEntity.ok(scores);
    }

    // Obtener fotos de una auditoría
    @GetMapping("/{auditId}/photos")
    public ResponseEntity<List<AuditPhoto>> getAuditPhotos(@PathVariable Long auditId) {
        List<AuditPhoto> photos = auditPhotoRepository.findByAuditId(auditId);
        return ResponseEntity.ok(photos);
    }

    // Actualizar estado de auditoría
    @PutMapping("/{id}/status")
    public ResponseEntity<Map<String, Object>> updateAuditStatus(
            @PathVariable Long id, 
            @RequestBody Map<String, String> statusData) {
        
        Map<String, Object> response = new HashMap<>();
        try {
            Optional<Audit> auditOpt = auditRepository.findById(id);
            if (auditOpt.isPresent()) {
                Audit audit = auditOpt.get();
                audit.setEstado(statusData.get("estado"));
                auditRepository.save(audit);
                
                response.put("success", true);
                response.put("message", "Estado actualizado exitosamente");
                return ResponseEntity.ok(response);
            } else {
                response.put("success", false);
                response.put("message", "Auditoría no encontrada");
                return ResponseEntity.notFound().build();
            }
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "Error al actualizar estado: " + e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }

    // Obtener estadísticas del dashboard para técnico
    @GetMapping("/dashboard/{tecnicoId}")
    public ResponseEntity<Map<String, Object>> getTechnicianDashboard(@PathVariable Long tecnicoId) {
        Map<String, Object> dashboard = new HashMap<>();
        
        try {
            // Contar auditorías totales
            long totalAudits = auditRepository.countByTecnicoId(tecnicoId);
            
            // Contar auditorías de hoy
            long todayAudits = auditRepository.countTodayAuditsByTecnico(tecnicoId);
            
            // Contar auditorías pendientes
            long pendingAudits = auditRepository.findByTecnicoIdAndEstado(tecnicoId, "PENDIENTE").size();
            
            // Contar auditorías completadas
            long completedAudits = auditRepository.findByTecnicoIdAndEstado(tecnicoId, "COMPLETADA").size();
            
            // Estadísticas de auditorías Moko
            long totalMokoAudits = mokoAuditRepository.countByTecnicoId(tecnicoId);
            long todayMokoAudits = mokoAuditRepository.countTodayMokoAuditsByTecnico(tecnicoId);
            Double avgCumplimientoMoko = mokoAuditRepository.getAverageCumplimientoByTecnico(tecnicoId);
            if (avgCumplimientoMoko == null) avgCumplimientoMoko = 0.0;
            
            // Obtener auditorías recientes
            List<Audit> recentAudits = auditRepository.findRecentAuditsByTecnico(tecnicoId)
                    .stream().limit(3).toList();
            
            // Obtener auditorías Moko recientes
            List<MokoAudit> recentMokoAudits = mokoAuditRepository.findRecentMokoAuditsByTecnico(tecnicoId)
                    .stream().limit(2).toList();
            
            dashboard.put("totalAudits", totalAudits);
            dashboard.put("todayAudits", todayAudits);
            dashboard.put("pendingAudits", pendingAudits);
            dashboard.put("completedAudits", completedAudits);
            dashboard.put("totalMokoAudits", totalMokoAudits);
            dashboard.put("todayMokoAudits", todayMokoAudits);
            dashboard.put("avgCumplimientoMoko", Math.round(avgCumplimientoMoko * 100.0) / 100.0);
            dashboard.put("recentAudits", recentAudits);
            dashboard.put("recentMokoAudits", recentMokoAudits);
            dashboard.put("welcomeMessage", "Bienvenido, Técnico");
            
            return ResponseEntity.ok(dashboard);
            
        } catch (Exception e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("error", "Error al obtener dashboard: " + e.getMessage());
            return ResponseEntity.badRequest().body(errorResponse);
        }
    }

    // Eliminar auditoría
    @DeleteMapping("/{id}")
    public ResponseEntity<Map<String, Object>> deleteAudit(@PathVariable Long id) {
        Map<String, Object> response = new HashMap<>();
        try {
            if (auditRepository.existsById(id)) {
                auditRepository.deleteById(id);
                response.put("success", true);
                response.put("message", "Auditoría eliminada exitosamente");
                return ResponseEntity.ok(response);
            } else {
                response.put("success", false);
                response.put("message", "Auditoría no encontrada");
                return ResponseEntity.notFound().build();
            }
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "Error al eliminar auditoría: " + e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }
}