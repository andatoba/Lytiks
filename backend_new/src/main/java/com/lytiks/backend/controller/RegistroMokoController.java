package com.lytiks.backend.controller;

import com.lytiks.backend.entity.RegistroMoko;
import com.lytiks.backend.entity.Sintoma;
import com.lytiks.backend.service.RegistroMokoService;
import com.lytiks.backend.service.SintomaService;
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
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

@RestController
@RequestMapping("/api/moko")
@CrossOrigin(origins = "*")
public class RegistroMokoController {

    @Autowired
    private RegistroMokoService registroMokoService;

    @Autowired
    private SintomaService sintomaService;

    private static final String UPLOAD_DIR = "photos/moko/";

    @GetMapping("/next-foco-number")
    public ResponseEntity<Map<String, Object>> getNextFocoNumber() {
        try {
            int nextNumber = registroMokoService.getNextFocoNumber();
            Map<String, Object> response = new HashMap<>();
            response.put("nextNumber", nextNumber);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            Map<String, Object> error = new HashMap<>();
            error.put("error", "Error al obtener número de foco: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
        }
    }

    @GetMapping("/sintomas")
    public ResponseEntity<List<Sintoma>> getSintomas() {
        try {
            List<Sintoma> sintomas = sintomaService.getAllSintomas();
            return ResponseEntity.ok(sintomas);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(null);
        }
    }

    @PostMapping("/registrar")
    public ResponseEntity<Map<String, Object>> registrarFoco(
            @RequestParam("numeroFoco") int numeroFoco,
            @RequestParam("clienteId") Long clienteId,
            @RequestParam("gpsCoordinates") String gpsCoordinates,
            @RequestParam("plantasAfectadas") int plantasAfectadas,
            @RequestParam("fechaDeteccion") String fechaDeteccion,
            @RequestParam("sintomaId") Long sintomaId,
            @RequestParam("severidad") String severidad,
            @RequestParam("metodoComprobacion") String metodoComprobacion,
            @RequestParam("observaciones") String observaciones,
            @RequestParam(value = "foto", required = false) MultipartFile foto) {

        try {
            // Crear nuevo registro
            RegistroMoko registro = new RegistroMoko();
            registro.setNumeroFoco(numeroFoco);
            registro.setClienteId(clienteId);
            registro.setGpsCoordinates(gpsCoordinates);
            registro.setPlantasAfectadas(plantasAfectadas);
            registro.setFechaDeteccion(LocalDateTime.parse(fechaDeteccion));
            registro.setSintomaId(sintomaId);
            registro.setSeveridad(severidad);
            registro.setMetodoComprobacion(metodoComprobacion);
            registro.setObservaciones(observaciones);
            registro.setFechaCreacion(LocalDateTime.now());

            // Guardar foto si existe
            if (foto != null && !foto.isEmpty()) {
                String fotoPath = guardarFoto(foto, numeroFoco);
                registro.setFotoPath(fotoPath);
            }

            // Guardar en la base de datos
            RegistroMoko savedRegistro = registroMokoService.save(registro);

            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Registro creado exitosamente");
            response.put("id", savedRegistro.getId());
            response.put("numeroFoco", savedRegistro.getNumeroFoco());

            return ResponseEntity.status(HttpStatus.CREATED).body(response);

        } catch (Exception e) {
            Map<String, Object> error = new HashMap<>();
            error.put("success", false);
            error.put("error", "Error al crear registro: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
        }
    }

    @GetMapping("/registros")
    public ResponseEntity<List<RegistroMoko>> getRegistros() {
        try {
            List<RegistroMoko> registros = registroMokoService.getAllRegistros();
            return ResponseEntity.ok(registros);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(null);
        }
    }

    @GetMapping("/registro/{id}")
    public ResponseEntity<RegistroMoko> getRegistroById(@PathVariable Long id) {
        try {
            Optional<RegistroMoko> registro = registroMokoService.getRegistroById(id);
            if (registro.isPresent()) {
                return ResponseEntity.ok(registro.get());
            } else {
                return ResponseEntity.notFound().build();
            }
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(null);
        }
    }

    @PutMapping("/registro/{id}")
    public ResponseEntity<Map<String, Object>> actualizarRegistro(
            @PathVariable Long id,
            @RequestParam("gpsCoordinates") String gpsCoordinates,
            @RequestParam("plantasAfectadas") int plantasAfectadas,
            @RequestParam("sintomaId") Long sintomaId,
            @RequestParam("severidad") String severidad,
            @RequestParam("metodoComprobacion") String metodoComprobacion,
            @RequestParam("observaciones") String observaciones,
            @RequestParam(value = "foto", required = false) MultipartFile foto) {

        try {
            Optional<RegistroMoko> registroOpt = registroMokoService.getRegistroById(id);
            if (!registroOpt.isPresent()) {
                Map<String, Object> error = new HashMap<>();
                error.put("success", false);
                error.put("error", "Registro no encontrado");
                return ResponseEntity.notFound().build();
            }

            RegistroMoko registro = registroOpt.get();
            registro.setGpsCoordinates(gpsCoordinates);
            registro.setPlantasAfectadas(plantasAfectadas);
            registro.setSintomaId(sintomaId);
            registro.setSeveridad(severidad);
            registro.setMetodoComprobacion(metodoComprobacion);
            registro.setObservaciones(observaciones);

            // Actualizar foto si se proporcionó una nueva
            if (foto != null && !foto.isEmpty()) {
                String fotoPath = guardarFoto(foto, registro.getNumeroFoco());
                registro.setFotoPath(fotoPath);
            }

            RegistroMoko savedRegistro = registroMokoService.save(registro);

            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Registro actualizado exitosamente");
            response.put("id", savedRegistro.getId());

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            Map<String, Object> error = new HashMap<>();
            error.put("success", false);
            error.put("error", "Error al actualizar registro: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
        }
    }

    @DeleteMapping("/registro/{id}")
    public ResponseEntity<Map<String, Object>> eliminarRegistro(@PathVariable Long id) {
        try {
            boolean eliminado = registroMokoService.deleteRegistro(id);
            Map<String, Object> response = new HashMap<>();
            
            if (eliminado) {
                response.put("success", true);
                response.put("message", "Registro eliminado exitosamente");
                return ResponseEntity.ok(response);
            } else {
                response.put("success", false);
                response.put("error", "Registro no encontrado");
                return ResponseEntity.notFound().build();
            }
        } catch (Exception e) {
            Map<String, Object> error = new HashMap<>();
            error.put("success", false);
            error.put("error", "Error al eliminar registro: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
        }
    }

    // Endpoints adicionales para lista de focos

    @GetMapping("/registros/por-severidad/{severidad}")
    public ResponseEntity<List<RegistroMoko>> getRegistrosBySeveridad(@PathVariable String severidad) {
        try {
            List<RegistroMoko> registros = registroMokoService.getRegistrosBySeveridad(severidad);
            return ResponseEntity.ok(registros);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(null);
        }
    }

    @GetMapping("/registros/buscar")
    public ResponseEntity<List<RegistroMoko>> buscarRegistros(@RequestParam String query) {
        try {
            List<RegistroMoko> registros = registroMokoService.buscarRegistros(query);
            return ResponseEntity.ok(registros);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(null);
        }
    }

    @GetMapping("/registros/por-cliente/{clienteId}")
    public ResponseEntity<List<RegistroMoko>> getRegistrosByCliente(@PathVariable Long clienteId) {
        try {
            List<RegistroMoko> registros = registroMokoService.getRegistrosByClienteId(clienteId);
            return ResponseEntity.ok(registros);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(null);
        }
    }

    @GetMapping("/registros/por-fecha")
    public ResponseEntity<List<RegistroMoko>> getRegistrosByFecha(
            @RequestParam String fechaInicio,
            @RequestParam String fechaFin) {
        try {
            LocalDateTime inicio = LocalDateTime.parse(fechaInicio);
            LocalDateTime fin = LocalDateTime.parse(fechaFin);
            List<RegistroMoko> registros = registroMokoService.getRegistrosByFechaRange(inicio, fin);
            return ResponseEntity.ok(registros);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(null);
        }
    }

    @GetMapping("/estadisticas")
    public ResponseEntity<Map<String, Object>> getEstadisticas() {
        try {
            Map<String, Object> estadisticas = new HashMap<>();
            
            // Contar total de focos
            Long totalFocos = registroMokoService.contarTotalRegistros();
            estadisticas.put("totalFocos", totalFocos);
            
            // Contar por severidad
            Map<String, Long> porSeveridad = new HashMap<>();
            porSeveridad.put("alto", registroMokoService.contarBySeveridad("alto"));
            porSeveridad.put("medio", registroMokoService.contarBySeveridad("medio"));
            porSeveridad.put("bajo", registroMokoService.contarBySeveridad("bajo"));
            estadisticas.put("porSeveridad", porSeveridad);
            
            // Último registro
            Optional<RegistroMoko> ultimoRegistro = registroMokoService.getUltimoRegistro();
            if (ultimoRegistro.isPresent()) {
                estadisticas.put("ultimoFoco", ultimoRegistro.get().getNumeroFoco());
                estadisticas.put("ultimaFecha", ultimoRegistro.get().getFechaDeteccion());
            }

            return ResponseEntity.ok(estadisticas);
        } catch (Exception e) {
            Map<String, Object> error = new HashMap<>();
            error.put("success", false);
            error.put("error", "Error al obtener estadísticas: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
        }
    }

    @GetMapping("/registros/recientes")
    public ResponseEntity<List<RegistroMoko>> getRegistrosRecientes(@RequestParam(defaultValue = "10") int limite) {
        try {
            List<RegistroMoko> registros = registroMokoService.getRegistrosRecientes(limite);
            return ResponseEntity.ok(registros);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(null);
        }
    }

    @GetMapping("/registros/con-fotos")
    public ResponseEntity<List<RegistroMoko>> getRegistrosConFotos() {
        try {
            List<RegistroMoko> registros = registroMokoService.getRegistrosConFotos();
            return ResponseEntity.ok(registros);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(null);
        }
    }

    private String guardarFoto(MultipartFile foto, int numeroFoco) throws IOException {
        // Crear directorio si no existe
        Path uploadPath = Paths.get(UPLOAD_DIR);
        if (!Files.exists(uploadPath)) {
            Files.createDirectories(uploadPath);
        }

        // Generar nombre único para la foto
        String timestamp = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMdd_HHmmss"));
        String extension = getFileExtension(foto.getOriginalFilename());
        String fileName = String.format("moko_foco_%d_%s_%s.%s", 
            numeroFoco, timestamp, UUID.randomUUID().toString().substring(0, 8), extension);
        
        Path filePath = uploadPath.resolve(fileName);
        
        // Guardar archivo
        Files.copy(foto.getInputStream(), filePath, StandardCopyOption.REPLACE_EXISTING);
        
        return UPLOAD_DIR + fileName;
    }

    private String getFileExtension(String fileName) {
        if (fileName != null && fileName.contains(".")) {
            return fileName.substring(fileName.lastIndexOf(".") + 1);
        }
        return "jpg";
    }
}