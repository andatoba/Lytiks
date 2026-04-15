package com.lytiks.backend.controller;

import com.lytiks.backend.entity.MokoMuestra;
import com.lytiks.backend.service.MokoMuestraService;
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
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/moko/muestras")
public class MokoMuestraController {

    private static final String PHOTO_DIR = "photos/moko/muestras/";
    private static final String DOC_DIR = "docs/moko/muestras/";

    @Autowired
    private MokoMuestraService muestraService;

    @PostMapping("/registrar")
    public ResponseEntity<Map<String, Object>> registrarMuestra(
            @RequestParam("clienteId") Long clienteId,
            @RequestParam(value = "haciendaId", required = false) Long haciendaId,
            @RequestParam(value = "loteId", required = false) Long loteId,
            @RequestParam("lote") String lote,
            @RequestParam("tipoMuestra") String tipoMuestra,
            @RequestParam("muestraNumero") Integer muestraNumero,
            @RequestParam("codigo") String codigo,
            @RequestParam(value = "descripcion", required = false) String descripcion,
            @RequestParam(value = "foto", required = false) MultipartFile foto) {
        try {
            MokoMuestra muestra = new MokoMuestra();
            muestra.setClienteId(clienteId);
            muestra.setHaciendaId(haciendaId);
            muestra.setLoteId(loteId);
            muestra.setLote(lote);
            muestra.setTipoMuestra(tipoMuestra);
            muestra.setMuestraNumero(muestraNumero);
            muestra.setCodigo(codigo);
            muestra.setDescripcion(descripcion);

            if (foto != null && !foto.isEmpty()) {
                muestra.setFotoPath(guardarArchivo(foto, PHOTO_DIR, "muestra_" + codigo));
            }

            MokoMuestra saved = muestraService.save(muestra);
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("muestra", saved);
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
        } catch (Exception e) {
            return buildError("Error al registrar muestra: " + e.getMessage());
        }
    }

    @GetMapping("/cliente/{clienteId}")
    public ResponseEntity<List<MokoMuestra>> listarPorCliente(
            @PathVariable Long clienteId,
            @RequestParam(value = "lote", required = false) String lote,
            @RequestParam(value = "tipo", required = false) String tipo,
            @RequestParam(value = "query", required = false) String query) {
        return ResponseEntity.ok(
                muestraService.buscarPorCliente(clienteId, lote, tipo, query)
        );
    }

    @GetMapping("/{muestraId}")
    public ResponseEntity<?> getById(@PathVariable Long muestraId) {
        return muestraService.findById(muestraId)
                .<ResponseEntity<?>>map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.status(HttpStatus.NOT_FOUND)
                        .body(Map.of("success", false, "error", "Muestra no encontrada")));
    }

    @PostMapping("/{muestraId}/laboratorio")
    public ResponseEntity<Map<String, Object>> cargarResultadoLaboratorio(
            @PathVariable Long muestraId,
            @RequestParam(value = "resultadoLaboratorio", required = false) String resultadoLaboratorio,
            @RequestParam(value = "documento", required = false) MultipartFile documento) {
        try {
            MokoMuestra muestra = muestraService.findById(muestraId)
                    .orElseThrow(() -> new IllegalArgumentException("Muestra no encontrada"));

            if (resultadoLaboratorio != null) {
                muestra.setResultadoLaboratorio(resultadoLaboratorio);
            }

            if (documento != null && !documento.isEmpty()) {
                muestra.setDocumentoLaboratorioPath(
                        guardarArchivo(documento, DOC_DIR, "lab_" + muestra.getCodigo())
                );
                muestra.setDocumentoLaboratorioNombre(documento.getOriginalFilename());
            }

            MokoMuestra saved = muestraService.save(muestra);
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("muestra", saved);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return buildError("Error al cargar resultado de laboratorio: " + e.getMessage());
        }
    }

    private ResponseEntity<Map<String, Object>> buildError(String message) {
        Map<String, Object> error = new HashMap<>();
        error.put("success", false);
        error.put("error", message);
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
    }

    private String guardarArchivo(MultipartFile file, String directory, String prefix) throws IOException {
        Path uploadPath = Paths.get(directory);
        if (!Files.exists(uploadPath)) {
            Files.createDirectories(uploadPath);
        }

        String originalName = file.getOriginalFilename() == null ? "archivo" : file.getOriginalFilename();
        String extension = "";
        int dotIndex = originalName.lastIndexOf('.');
        if (dotIndex >= 0) {
            extension = originalName.substring(dotIndex);
        }

        String safePrefix = prefix.replaceAll("[^a-zA-Z0-9_-]", "_");
        String fileName = safePrefix + "_" + UUID.randomUUID() + extension;
        Path filePath = uploadPath.resolve(fileName);
        Files.copy(file.getInputStream(), filePath, StandardCopyOption.REPLACE_EXISTING);
        return directory + fileName;
    }
}
