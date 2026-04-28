package com.lytiks.backend.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.lytiks.backend.entity.MokoCapacitacion;
import com.lytiks.backend.service.MokoCapacitacionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/moko/capacitaciones")
public class MokoCapacitacionController {

    private static final String PHOTO_DIR = "photos/moko/capacitaciones/";

    @Autowired
    private MokoCapacitacionService service;

    @Autowired
    private ObjectMapper objectMapper;

    @PostMapping("/registrar")
    public ResponseEntity<Map<String, Object>> registrar(
            @RequestParam("clienteId") Long clienteId,
            @RequestParam(value = "haciendaId", required = false) Long haciendaId,
            @RequestParam(value = "loteId", required = false) Long loteId,
            @RequestParam(value = "hacienda", required = false) String hacienda,
            @RequestParam("lote") String lote,
            @RequestParam("tema") String tema,
            @RequestParam(value = "descripcion", required = false) String descripcion,
            @RequestParam(value = "participantes", required = false) Integer participantes,
            @RequestParam(value = "fotos", required = false) List<MultipartFile> fotos) {
        try {
            List<String> rutasFotos = new ArrayList<>();
            if (fotos != null) {
                for (MultipartFile foto : fotos) {
                    if (foto != null && !foto.isEmpty()) {
                        rutasFotos.add(guardarFoto(foto, "cap_" + tema));
                    }
                }
            }

            MokoCapacitacion capacitacion = new MokoCapacitacion();
            capacitacion.setClienteId(clienteId);
            capacitacion.setHaciendaId(haciendaId);
            capacitacion.setLoteId(loteId);
            capacitacion.setHacienda(hacienda);
            capacitacion.setLote(lote);
            capacitacion.setTema(tema);
            capacitacion.setDescripcion(descripcion);
            capacitacion.setParticipantes(participantes);
            capacitacion.setFotosJson(objectMapper.writeValueAsString(rutasFotos));

            MokoCapacitacion saved = service.save(capacitacion);
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("capacitacion", saved);
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
        } catch (Exception e) {
            return error("Error al registrar capacitación: " + e.getMessage());
        }
    }

    @GetMapping("/cliente/{clienteId}")
    public ResponseEntity<List<MokoCapacitacion>> listar(
            @PathVariable Long clienteId,
            @RequestParam(value = "hacienda", required = false) String hacienda,
            @RequestParam(value = "lote", required = false) String lote) {
        return ResponseEntity.ok(service.findByClienteAndLote(clienteId, hacienda, lote));
    }

    @GetMapping("/cliente/{clienteId}/count")
    public ResponseEntity<Map<String, Object>> contar(
            @PathVariable Long clienteId,
            @RequestParam(value = "hacienda", required = false) String hacienda,
            @RequestParam(value = "lote", required = false) String lote) {
        return ResponseEntity.ok(
                Map.of("count", service.countByClienteAndLote(clienteId, hacienda, lote))
        );
    }

    private ResponseEntity<Map<String, Object>> error(String message) {
        Map<String, Object> response = new HashMap<>();
        response.put("success", false);
        response.put("error", message);
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
    }

    private String guardarFoto(MultipartFile foto, String prefix) throws IOException {
        Path uploadPath = Paths.get(PHOTO_DIR);
        if (!Files.exists(uploadPath)) {
            Files.createDirectories(uploadPath);
        }
        String originalName = foto.getOriginalFilename() == null ? "foto.jpg" : foto.getOriginalFilename();
        String extension = "";
        int dotIndex = originalName.lastIndexOf('.');
        if (dotIndex >= 0) {
            extension = originalName.substring(dotIndex);
        }
        String fileName = prefix.replaceAll("[^a-zA-Z0-9_-]", "_") + "_" + UUID.randomUUID() + extension;
        Path filePath = uploadPath.resolve(fileName);
        Files.copy(foto.getInputStream(), filePath, StandardCopyOption.REPLACE_EXISTING);
        return PHOTO_DIR + fileName;
    }
}
