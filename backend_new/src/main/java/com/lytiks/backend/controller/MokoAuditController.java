package com.lytiks.backend.controller;

import com.lytiks.backend.entity.MokoAudit;
import com.lytiks.backend.entity.MokoAuditDetail;
import com.lytiks.backend.repository.MokoAuditRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.*;

@RestController
@RequestMapping({"/moko-audits", "/api/moko-audits"})
@CrossOrigin(origins = "*")
public class MokoAuditController {  


    @Autowired
    private MokoAuditRepository mokoAuditRepository;

    // Crear nueva auditoría de Moko
    @PostMapping
    public ResponseEntity<Map<String, Object>> createMokoAudit(@RequestBody Map<String, Object> mokoAuditData) {
        Map<String, Object> response = new HashMap<>();
        try {
            MokoAudit audit = new MokoAudit();
            // Mapear clientId a tecnicoId si viene de Flutter
            if (mokoAuditData.get("clientId") != null) {
                audit.setTecnicoId(Long.valueOf(mokoAuditData.get("clientId").toString()));
            } else if (mokoAuditData.get("tecnicoId") != null) {
                audit.setTecnicoId(Long.valueOf(mokoAuditData.get("tecnicoId").toString()));
            }
            audit.setHacienda((String) mokoAuditData.get("hacienda"));
            audit.setLote((String) mokoAuditData.get("lote"));
            audit.setFecha(mokoAuditData.get("auditDate") != null ? LocalDateTime.parse(mokoAuditData.get("auditDate").toString()) : LocalDateTime.now());
            audit.setEstado((String) mokoAuditData.getOrDefault("status", "PENDIENTE"));
            audit.setObservaciones((String) mokoAuditData.get("observations"));
            // Puedes mapear otros campos aquí según tu modelo

            // Guardar detalles si existen
            if (mokoAuditData.containsKey("mokoData")) {
                List<MokoAuditDetail> details = new ArrayList<>();
                Object mokoDataObj = mokoAuditData.get("mokoData");
                if (mokoDataObj instanceof List<?>) {
                    List<?> mokoDataList = (List<?>) mokoDataObj;
                    for (Object detailObj : mokoDataList) {
                        if (detailObj instanceof Map) {
                            @SuppressWarnings("unchecked")
                            Map<String, Object> detailData = (Map<String, Object>) detailObj; // Safe due to runtime check
                            MokoAuditDetail detail = new MokoAuditDetail();
                            detail.setMokoAudit(audit);
                            detail.setCategoria((String) detailData.get("categoria"));
                            detail.setSubcategoria((String) detailData.get("subcategoria"));
                            detail.setPregunta((String) detailData.get("pregunta"));
                            detail.setRespuesta((String) detailData.get("respuesta"));
                            detail.setPuntuacion(detailData.get("puntuacion") != null ? Integer.valueOf(detailData.get("puntuacion").toString()) : null);
                            detail.setPuntuacionMaxima(detailData.get("puntuacionMaxima") != null ? Integer.valueOf(detailData.get("puntuacionMaxima").toString()) : null);
                            detail.setEsCritico(detailData.get("esCritico") != null ? Boolean.valueOf(detailData.get("esCritico").toString()) : false);
                            detail.setObservaciones((String) detailData.get("observaciones"));
                            detail.setRecomendaciones((String) detailData.get("recomendaciones"));
                            details.add(detail);
                        }
                    }
                }
                audit.setDetails(details);
            }

            MokoAudit savedAudit = mokoAuditRepository.save(audit);
            response.put("success", true);
            response.put("message", "Auditoría Moko creada exitosamente");
            response.put("auditId", savedAudit.getId());
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "Error al crear auditoría Moko: " + e.getMessage());
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