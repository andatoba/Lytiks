package com.lytiks.backend.controller;

import com.lytiks.backend.entity.Audit;
import com.lytiks.backend.entity.AuditScore;
import com.lytiks.backend.entity.AuditPhoto;
import com.lytiks.backend.repository.AuditRepository;
import com.lytiks.backend.repository.AuditScoreRepository;
import com.lytiks.backend.repository.AuditPhotoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.HashMap;
import java.util.ArrayList;
import java.util.Map;
import java.util.UUID;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.file.StandardOpenOption;
import java.io.IOException;
import java.util.Base64;
import com.fasterxml.jackson.databind.ObjectMapper;

@RestController
@RequestMapping("/audits")
@CrossOrigin(origins = "*")
public class AuditController {
    private static final ObjectMapper MAPPER = new ObjectMapper();

    @Autowired
    private com.lytiks.backend.repository.ClientRepository clientRepository;

    @Autowired
    private AuditRepository auditRepository;
    
    @Autowired
    private AuditScoreRepository auditScoreRepository;
    
    @Autowired
    private AuditPhotoRepository auditPhotoRepository;

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
        if (auditData.containsKey("trayectoUbicaciones") && auditData.get("trayectoUbicaciones") != null) {
            Object trayecto = auditData.get("trayectoUbicaciones");
            if (trayecto instanceof String) {
                audit.setTrayectoUbicaciones((String) trayecto);
            } else {
                try {
                    audit.setTrayectoUbicaciones(MAPPER.writeValueAsString(trayecto));
                } catch (Exception e) {
                    audit.setTrayectoUbicaciones(trayecto.toString());
                }
            }
        }

        // Asociar cliente por cédula
        if (auditData.containsKey("cedulaCliente") && auditData.get("cedulaCliente") != null) {
            String cedula = auditData.get("cedulaCliente").toString();
            Optional<com.lytiks.backend.entity.Client> clientOpt = clientRepository.findByCedula(cedula);
            if (clientOpt.isPresent()) {
                audit.setClient(clientOpt.get());
            } else {
                response.put("success", false);
                response.put("message", "No se encontró un cliente con la cédula proporcionada");
                return ResponseEntity.badRequest().body(response);
            }
        } else {
            response.put("success", false);
            response.put("message", "Debe proporcionar la cédula del cliente");
            return ResponseEntity.badRequest().body(response);
        }

        Audit savedAudit = auditRepository.save(audit);

        // Guardar puntuaciones y fotos si existen
        if (auditData.containsKey("scores")) {
            @SuppressWarnings("unchecked")
            List<Map<String, Object>> scores = (List<Map<String, Object>>) auditData.get("scores");
            for (Map<String, Object> scoreData : scores) {
                AuditScore score = new AuditScore();
                score.setAudit(savedAudit);
                score.setCategoria((String) scoreData.get("categoria"));
                score.setPuntuacion(Integer.valueOf(scoreData.get("puntuacion").toString()));
                score.setObservaciones((String) scoreData.get("observaciones"));

                // Guardar foto si viene en base64
                if (scoreData.containsKey("photoBase64") && scoreData.get("photoBase64") != null) {
                    String photoBase64 = (String) scoreData.get("photoBase64");
                    try {
                        // Decodificar base64
                        byte[] imageBytes = Base64.getDecoder().decode(photoBase64);
                        // Crear nombre único referencial
                        String categoria = (String) scoreData.get("categoria");
                        String categoriaSanitized = categoria.replaceAll("[^a-zA-Z0-9]", "_");
                        String uniqueName = "audit_" + savedAudit.getId() + "_" + categoriaSanitized + "_" + UUID.randomUUID() + ".jpg";
                        String folderPath = "photos/auditoria";
                        String filePath = folderPath + "/" + uniqueName;
                        // Guardar archivo
                        Files.createDirectories(Paths.get(folderPath));
                        Files.write(Paths.get(filePath), imageBytes, StandardOpenOption.CREATE);

                        // Guardar ruta en AuditScore
                        score.setPhotoPath(filePath);

                        // Guardar también en AuditPhoto si quieres mantener ambos registros
                        AuditPhoto photo = new AuditPhoto();
                        photo.setAudit(savedAudit);
                        photo.setCategoria(categoria);
                        photo.setFileName(uniqueName);
                        photo.setFilePath(filePath);
                        photo.setFileSize((long) imageBytes.length);
                        photo.setMimeType("image/jpeg");
                        auditPhotoRepository.save(photo);
                    } catch (IOException e) {
                        // Manejar error de guardado de imagen
                        e.printStackTrace();
                    } catch (IllegalArgumentException e) {
                        // Manejar error de base64 inválido
                        e.printStackTrace();
                    }
                }
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

    // Obtener todas las auditorías (normales, moko, sigatoka) creadas por un técnico
    @GetMapping("/technician/{tecnicoId}")
    public ResponseEntity<Map<String, Object>> getAllAuditsByTechnician(@PathVariable Long tecnicoId) {
        Map<String, Object> result = new HashMap<>();
        // Auditorías normales
        List<Audit> audits = auditRepository.findByTecnicoId(tecnicoId);
        result.put("audits", audits);

        // Auditorías Moko
        try {
            Class<?> mokoRepoClass = Class.forName("com.lytiks.backend.repository.MokoAuditRepository");
            Object mokoRepo = mokoRepoClass.getDeclaredConstructor().newInstance();
            var mokoMethod = mokoRepoClass.getMethod("findByTecnicoId", Long.class);
            List<?> mokoAudits = (List<?>) mokoMethod.invoke(mokoRepo, tecnicoId);
            result.put("mokoAudits", mokoAudits);
        } catch (Exception e) {
            result.put("mokoAudits", new ArrayList<>());
        }

        // Auditorías Sigatoka
        try {
            Class<?> sigatokaRepoClass = Class.forName("com.lytiks.backend.repository.SigatokaAuditRepository");
            Object sigatokaRepo = sigatokaRepoClass.getDeclaredConstructor().newInstance();
            var sigatokaMethod = sigatokaRepoClass.getMethod("findByTecnicoId", Long.class);
            List<?> sigatokaAudits = (List<?>) sigatokaMethod.invoke(sigatokaRepo, tecnicoId);
            result.put("sigatokaAudits", sigatokaAudits);
        } catch (Exception e) {
            result.put("sigatokaAudits", new ArrayList<>());
        }

        return ResponseEntity.ok(result);
    }

    // Obtener auditoría por ID
    @GetMapping("/{id}")
    public ResponseEntity<Audit> getAuditById(@PathVariable Long id) {
        Optional<Audit> audit = auditRepository.findById(id);
        return audit.map(ResponseEntity::ok).orElse(ResponseEntity.notFound().build());
    }

    // Obtener todas las auditorías
    @GetMapping("/all")
    public ResponseEntity<List<Map<String, Object>>> getAllAudits() {
        List<Audit> audits = auditRepository.findAll();
        List<Map<String, Object>> auditsEnriquecidos = new java.util.ArrayList<>();
        for (Audit audit : audits) {
            Map<String, Object> auditMap = new java.util.HashMap<>();
            auditMap.put("id", audit.getId());
            auditMap.put("type", "Regular");
            auditMap.put("fecha", audit.getFecha());
            auditMap.put("cedulaCliente", audit.getCedulaCliente());
            auditMap.put("hacienda", audit.getHacienda());
            auditMap.put("cultivo", audit.getCultivo());
            auditMap.put("estado", audit.getEstado());
            auditMap.put("tecnicoId", audit.getTecnicoId());
            auditMap.put("observaciones", audit.getObservaciones());
            auditMap.put("trayectoUbicaciones", audit.getTrayectoUbicaciones());
            // Enriquecer con nombre del cliente
            if (audit.getClient() != null) {
                auditMap.put("nombreCliente", audit.getClient().getNombreCompleto());
            } else {
                auditMap.put("nombreCliente", "Cliente Desconocido");
            }
            auditsEnriquecidos.add(auditMap);
        }
        return ResponseEntity.ok(auditsEnriquecidos);
    }
    
    /**
     * Obtener auditorías de un cliente específico
     */
    @GetMapping("/cliente/{clienteId}")
    public ResponseEntity<List<Map<String, Object>>> getAuditsByCliente(@PathVariable Long clienteId) {
        List<Audit> audits = auditRepository.findByClienteId(clienteId);
        List<Map<String, Object>> auditsEnriquecidos = new java.util.ArrayList<>();
        for (Audit audit : audits) {
            Map<String, Object> auditMap = new java.util.HashMap<>();
            auditMap.put("id", audit.getId());
            auditMap.put("type", "Regular");
            auditMap.put("fecha", audit.getFecha());
            auditMap.put("hacienda", audit.getHacienda());
            auditMap.put("cultivo", audit.getCultivo());
            auditMap.put("estado", audit.getEstado());
            auditMap.put("observaciones", audit.getObservaciones());
            auditMap.put("trayectoUbicaciones", audit.getTrayectoUbicaciones());
            auditsEnriquecidos.add(auditMap);
        }
        return ResponseEntity.ok(auditsEnriquecidos);
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
            
            // Obtener auditorías recientes
            List<Audit> recentAudits = auditRepository.findRecentAuditsByTecnico(tecnicoId)
                    .stream().limit(3).toList();
            
            dashboard.put("totalAudits", totalAudits);
            dashboard.put("todayAudits", todayAudits);
            dashboard.put("pendingAudits", pendingAudits);
            dashboard.put("completedAudits", completedAudits);
            dashboard.put("recentAudits", recentAudits);
            dashboard.put("welcomeMessage", "Bienvenido, Técnico");
            
            return ResponseEntity.ok(dashboard);
            
        } catch (Exception e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("error", "Error al obtener dashboard: " + e.getMessage());
            return ResponseEntity.badRequest().body(errorResponse);
        }
    }

    // Obtener estadísticas generales de auditorías
    @GetMapping("/stats")
    public ResponseEntity<Map<String, Object>> getAuditsStats() {
        Map<String, Object> stats = new HashMap<>();
        
        try {
            // Contar todas las auditorías
            long totalAudits = auditRepository.count();
            
            // Contar auditorías de hoy
            long todayAudits = auditRepository.countTodayAudits();
            
            // Contar auditorías por estado
            long pendingAudits = auditRepository.countByEstado("PENDIENTE");
            long completedAudits = auditRepository.countByEstado("COMPLETADA");
            
            stats.put("totalAudits", totalAudits);
            stats.put("todayAudits", todayAudits);
            stats.put("pendingAudits", pendingAudits);
            stats.put("completedAudits", completedAudits);
            
            return ResponseEntity.ok(stats);
            
        } catch (Exception e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("error", "Error al obtener estadísticas: " + e.getMessage());
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
