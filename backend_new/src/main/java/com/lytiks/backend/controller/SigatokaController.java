package com.lytiks.backend.controller;
import com.lytiks.backend.entity.SigatokaAudit;
import com.lytiks.backend.entity.SigatokaParameter;
import com.lytiks.backend.entity.SigatokaPhoto;
import com.lytiks.backend.repository.SigatokaAuditRepository;
import com.lytiks.backend.repository.SigatokaParameterRepository;
import com.lytiks.backend.repository.SigatokaPhotoRepository;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.file.StandardOpenOption;
import java.util.Base64;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/sigatoka")
@CrossOrigin(origins = "*")
public class SigatokaController {

    @Autowired
    private SigatokaPhotoRepository sigatokaPhotoRepository;

    @Autowired
    private SigatokaAuditRepository sigatokaAuditRepository;
    
    @Autowired
    private SigatokaParameterRepository sigatokaParameterRepository;

    // Crear nueva auditoría Sigatoka
    @PostMapping("/create")
    public ResponseEntity<Map<String, Object>> createSigatokaAudit(@RequestBody Map<String, Object> auditData) {
        Map<String, Object> response = new HashMap<>();
        try {
            SigatokaAudit audit = new SigatokaAudit();
            audit.setNivelAnalisis((String) auditData.get("nivelAnalisis"));
            audit.setTipoCultivo((String) auditData.get("tipoCultivo"));
            audit.setHacienda((String) auditData.get("hacienda"));
            audit.setLote((String) auditData.get("lote"));
            audit.setTecnicoId(Long.valueOf(auditData.get("tecnicoId").toString()));
            audit.setObservaciones((String) auditData.get("observaciones"));
            audit.setRecomendaciones((String) auditData.get("recomendaciones"));
            
            if (auditData.get("stoverReal") != null) {
                audit.setStoverReal(Double.valueOf(auditData.get("stoverReal").toString()));
            }
            if (auditData.get("stoverRecomendado") != null) {
                audit.setStoverRecomendado(Double.valueOf(auditData.get("stoverRecomendado").toString()));
            }
            
            audit.setEstadoGeneral((String) auditData.get("estadoGeneral"));
            audit.setFecha(LocalDateTime.now());
            
            SigatokaAudit savedAudit = sigatokaAuditRepository.save(audit);

            // Guardar parámetros
            if (auditData.containsKey("parameters")) {
                @SuppressWarnings("unchecked")
                List<Map<String, Object>> parameters = (List<Map<String, Object>>) auditData.get("parameters");
                for (Map<String, Object> paramData : parameters) {
                    SigatokaParameter parameter = new SigatokaParameter();
                    parameter.setSigatokaAudit(savedAudit);
                    parameter.setParameterName((String) paramData.get("parameterName"));
                    parameter.setWeekNumber(Integer.valueOf(paramData.get("weekNumber").toString()));
                    if (paramData.get("value") != null) {
                        parameter.setValue(Double.valueOf(paramData.get("value").toString()));
                    }
                    sigatokaParameterRepository.save(parameter);
                }
            }

            // Guardar foto si viene en base64
            if (auditData.containsKey("photoBase64") && auditData.get("photoBase64") != null) {
                try {
                    String base64 = (String) auditData.get("photoBase64");
                    byte[] imageBytes = Base64.getDecoder().decode(base64);
                    String folderPath = "photos/sigatoka/";
                    Files.createDirectories(Paths.get(folderPath));
                    String fileName = "sigatoka_" + savedAudit.getId() + "_" + System.currentTimeMillis() + ".jpg";
                    String filePath = folderPath + fileName;
                    Files.write(Paths.get(filePath), imageBytes, StandardOpenOption.CREATE);
                    // Guardar entidad SigatokaPhoto
                    SigatokaPhoto photo = new SigatokaPhoto();
                    photo.setSigatokaAudit(savedAudit);
                    photo.setPhotoPath(filePath);
                    photo.setDescription("Foto evidencia auditoría");
                    photo.setPhotoType("EVIDENCIA");
                    sigatokaPhotoRepository.save(photo);
                } catch (Exception ex) {
                    response.put("photoError", "Error al guardar la foto: " + ex.getMessage());
                }
            }

            response.put("success", true);
            response.put("message", "Auditoría Sigatoka creada exitosamente");
            response.put("auditId", savedAudit.getId());
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "Error al crear auditoría: " + e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }

    // Obtener todas las auditorías Sigatoka
    @GetMapping("/all")
    public ResponseEntity<List<SigatokaAudit>> getAllSigatokaAudits() {
        try {
            List<SigatokaAudit> audits = sigatokaAuditRepository.findAll();
            return ResponseEntity.ok(audits);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }

    // Obtener auditorías por técnico
    @GetMapping("/technician/{tecnicoId}")
    public ResponseEntity<List<SigatokaAudit>> getAuditsByTechnician(@PathVariable Long tecnicoId) {
        try {
            List<SigatokaAudit> audits = sigatokaAuditRepository.findByTecnicoId(tecnicoId);
            return ResponseEntity.ok(audits);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }

    // Obtener auditoría por ID
    @GetMapping("/{id}")
    public ResponseEntity<Map<String, Object>> getSigatokaAuditById(@PathVariable Long id) {
        try {
            Optional<SigatokaAudit> auditOpt = sigatokaAuditRepository.findById(id);
            if (auditOpt.isPresent()) {
                SigatokaAudit audit = auditOpt.get();
                List<SigatokaParameter> parameters = sigatokaParameterRepository.findBySigatokaAuditId(id);
                
                Map<String, Object> response = new HashMap<>();
                response.put("audit", audit);
                response.put("parameters", parameters);
                
                return ResponseEntity.ok(response);
            } else {
                return ResponseEntity.notFound().build();
            }
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }

    // Actualizar estado de auditoría
    @PutMapping("/{id}/status")
    public ResponseEntity<Map<String, Object>> updateAuditStatus(@PathVariable Long id, @RequestBody Map<String, String> statusData) {
        Map<String, Object> response = new HashMap<>();
        try {
            Optional<SigatokaAudit> auditOpt = sigatokaAuditRepository.findById(id);
            if (auditOpt.isPresent()) {
                SigatokaAudit audit = auditOpt.get();
                audit.setEstado(statusData.get("estado"));
                sigatokaAuditRepository.save(audit);

                // Guardar foto si viene en base64
                if (statusData.containsKey("photoBase64") && statusData.get("photoBase64") != null) {
                    try {
                        String base64 = statusData.get("photoBase64");
                        byte[] imageBytes = Base64.getDecoder().decode(base64);
                        String folderPath = "photos/sigatoka/";
                        Files.createDirectories(Paths.get(folderPath));
                        String fileName = "sigatoka_" + audit.getId() + "_" + System.currentTimeMillis() + ".jpg";
                        String filePath = folderPath + fileName;
                        Files.write(Paths.get(filePath), imageBytes, StandardOpenOption.CREATE);
                        // Guardar entidad SigatokaPhoto
                        SigatokaPhoto photo = new SigatokaPhoto();
                        photo.setSigatokaAudit(audit);
                        photo.setPhotoPath(filePath);
                        photo.setDescription("Foto evidencia auditoría");
                        photo.setPhotoType("EVIDENCIA");
                        sigatokaPhotoRepository.save(photo);
                    } catch (Exception ex) {
                        response.put("photoError", "Error al guardar la foto: " + ex.getMessage());
                    }
                }
                
                response.put("success", true);
                response.put("message", "Estado actualizado exitosamente");
                return ResponseEntity.ok(response);
            } else {
                response.put("success", false);
                response.put("message", "Auditoría no encontrada");
                return ResponseEntity.status(404).body(response);
            }
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "Error al actualizar estado: " + e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }

    // Obtener auditorías por tipo de cultivo
    @GetMapping("/crop/{tipoCultivo}")
    public ResponseEntity<List<SigatokaAudit>> getAuditsByCrop(@PathVariable String tipoCultivo) {
        try {
            List<SigatokaAudit> audits = sigatokaAuditRepository.findByTipoCultivo(tipoCultivo);
            return ResponseEntity.ok(audits);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }

    // Obtener auditorías por nivel de análisis
    @GetMapping("/level/{nivelAnalisis}")
    public ResponseEntity<List<SigatokaAudit>> getAuditsByLevel(@PathVariable String nivelAnalisis) {
        try {
            List<SigatokaAudit> audits = sigatokaAuditRepository.findByNivelAnalisis(nivelAnalisis);
            return ResponseEntity.ok(audits);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }
}