package com.lytiks.backend.controller;

import com.lytiks.backend.entity.SeguimientoMoko;
import com.lytiks.backend.service.SeguimientoMokoService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/seguimiento-moko")
@CrossOrigin(origins = "*")
public class SeguimientoMokoController {

    @Autowired
    private SeguimientoMokoService seguimientoMokoService;

    @PostMapping("/registrar")
    public ResponseEntity<Map<String, Object>> registrarSeguimiento(
            @RequestBody Map<String, Object> seguimientoData) {

        try {
            // Crear nuevo seguimiento
            SeguimientoMoko seguimiento = new SeguimientoMoko();
            
            // Mapear campos básicos
            seguimiento.setFocoId(Long.valueOf(seguimientoData.get("focoId").toString()));
            seguimiento.setNumeroFoco(Integer.valueOf(seguimientoData.get("numeroFoco").toString()));
            seguimiento.setSemanaInicio(Integer.valueOf(seguimientoData.get("semanaInicio").toString()));
            seguimiento.setPlantasAfectadas(Integer.valueOf(seguimientoData.get("plantasAfectadas").toString()));
            seguimiento.setPlantasInyectadas(Integer.valueOf(seguimientoData.get("plantasInyectadas").toString()));
            
            // Mapear campos booleanos de medidas de control
            seguimiento.setControlVectores((Boolean) seguimientoData.get("controlVectores"));
            seguimiento.setCuarentenaActiva((Boolean) seguimientoData.get("cuarentenaActiva"));
            seguimiento.setUnicaEntradaHabilitada((Boolean) seguimientoData.get("unicaEntradaHabilitada"));
            seguimiento.setEliminacionMalezaHospedera((Boolean) seguimientoData.get("eliminacionMalezaHospedera"));
            seguimiento.setControlPicudoAplicado((Boolean) seguimientoData.get("controlPicudoAplicado"));
            seguimiento.setInspeccionPlantasVecinas((Boolean) seguimientoData.get("inspeccionPlantasVecinas"));
            seguimiento.setCorteRiego((Boolean) seguimientoData.get("corteRiego"));
            seguimiento.setPediluvioActivo((Boolean) seguimientoData.get("pediluvioActivo"));
            
            // PPM solución desinfectante
            seguimiento.setPpmSolucionDesinfectante(Integer.valueOf(seguimientoData.get("ppmSolucionDesinfectante").toString()));
            
            // Establecer fechas
            seguimiento.setFechaSeguimiento(LocalDateTime.now());
            seguimiento.setFechaCreacion(LocalDateTime.now());

            // Guardar en la base de datos
            SeguimientoMoko savedSeguimiento = seguimientoMokoService.save(seguimiento);

            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Seguimiento registrado exitosamente");
            response.put("id", savedSeguimiento.getId());
            response.put("focoId", savedSeguimiento.getFocoId());
            response.put("numeroFoco", savedSeguimiento.getNumeroFoco());

            return ResponseEntity.status(HttpStatus.CREATED).body(response);

        } catch (Exception e) {
            Map<String, Object> error = new HashMap<>();
            error.put("success", false);
            error.put("error", "Error al registrar seguimiento: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
        }
    }

    @GetMapping("/todos")
    public ResponseEntity<List<SeguimientoMoko>> getAllSeguimientos() {
        try {
            List<SeguimientoMoko> seguimientos = seguimientoMokoService.getAllSeguimientos();
            return ResponseEntity.ok(seguimientos);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(null);
        }
    }

    @GetMapping("/foco/{focoId}")
    public ResponseEntity<List<SeguimientoMoko>> getSeguimientosByFoco(@PathVariable Long focoId) {
        try {
            List<SeguimientoMoko> seguimientos = seguimientoMokoService.getSeguimientosByFocoId(focoId);
            return ResponseEntity.ok(seguimientos);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(null);
        }
    }

    @GetMapping("/numero-foco/{numeroFoco}")
    public ResponseEntity<List<SeguimientoMoko>> getSeguimientosByNumeroFoco(@PathVariable Integer numeroFoco) {
        try {
            List<SeguimientoMoko> seguimientos = seguimientoMokoService.getSeguimientosByNumeroFoco(numeroFoco);
            return ResponseEntity.ok(seguimientos);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(null);
        }
    }

    @GetMapping("/{id}")
    public ResponseEntity<SeguimientoMoko> getSeguimientoById(@PathVariable Long id) {
        try {
            Optional<SeguimientoMoko> seguimiento = seguimientoMokoService.getSeguimientoById(id);
            if (seguimiento.isPresent()) {
                return ResponseEntity.ok(seguimiento.get());
            } else {
                return ResponseEntity.notFound().build();
            }
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(null);
        }
    }

    @GetMapping("/ultimo/foco/{focoId}")
    public ResponseEntity<SeguimientoMoko> getLastSeguimientoByFoco(@PathVariable Long focoId) {
        try {
            Optional<SeguimientoMoko> ultimoSeguimiento = seguimientoMokoService.getLastSeguimientoByFocoId(focoId);
            if (ultimoSeguimiento.isPresent()) {
                return ResponseEntity.ok(ultimoSeguimiento.get());
            } else {
                return ResponseEntity.notFound().build();
            }
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(null);
        }
    }

    @PutMapping("/actualizar/{id}")
    public ResponseEntity<Map<String, Object>> actualizarSeguimiento(
            @PathVariable Long id,
            @RequestBody Map<String, Object> seguimientoData) {

        try {
            // Crear seguimiento con datos actualizados
            SeguimientoMoko seguimientoActualizado = new SeguimientoMoko();
            
            // Mapear campos básicos
            seguimientoActualizado.setPlantasAfectadas(Integer.valueOf(seguimientoData.get("plantasAfectadas").toString()));
            seguimientoActualizado.setPlantasInyectadas(Integer.valueOf(seguimientoData.get("plantasInyectadas").toString()));
            
            // Mapear campos booleanos de medidas de control
            seguimientoActualizado.setControlVectores((Boolean) seguimientoData.get("controlVectores"));
            seguimientoActualizado.setCuarentenaActiva((Boolean) seguimientoData.get("cuarentenaActiva"));
            seguimientoActualizado.setUnicaEntradaHabilitada((Boolean) seguimientoData.get("unicaEntradaHabilitada"));
            seguimientoActualizado.setEliminacionMalezaHospedera((Boolean) seguimientoData.get("eliminacionMalezaHospedera"));
            seguimientoActualizado.setControlPicudoAplicado((Boolean) seguimientoData.get("controlPicudoAplicado"));
            seguimientoActualizado.setInspeccionPlantasVecinas((Boolean) seguimientoData.get("inspeccionPlantasVecinas"));
            seguimientoActualizado.setCorteRiego((Boolean) seguimientoData.get("corteRiego"));
            seguimientoActualizado.setPediluvioActivo((Boolean) seguimientoData.get("pediluvioActivo"));
            
            // PPM solución desinfectante
            seguimientoActualizado.setPpmSolucionDesinfectante(Integer.valueOf(seguimientoData.get("ppmSolucionDesinfectante").toString()));

            SeguimientoMoko savedSeguimiento = seguimientoMokoService.updateSeguimiento(id, seguimientoActualizado);

            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Seguimiento actualizado exitosamente");
            response.put("id", savedSeguimiento.getId());

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            Map<String, Object> error = new HashMap<>();
            error.put("success", false);
            error.put("error", "Error al actualizar seguimiento: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
        }
    }

    @DeleteMapping("/eliminar/{id}")
    public ResponseEntity<Map<String, Object>> eliminarSeguimiento(@PathVariable Long id) {
        try {
            boolean eliminado = seguimientoMokoService.deleteSeguimiento(id);
            Map<String, Object> response = new HashMap<>();
            
            if (eliminado) {
                response.put("success", true);
                response.put("message", "Seguimiento eliminado exitosamente");
                return ResponseEntity.ok(response);
            } else {
                response.put("success", false);
                response.put("error", "Seguimiento no encontrado");
                return ResponseEntity.notFound().build();
            }
        } catch (Exception e) {
            Map<String, Object> error = new HashMap<>();
            error.put("success", false);
            error.put("error", "Error al eliminar seguimiento: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
        }
    }

    @GetMapping("/semana/{semanaInicio}")
    public ResponseEntity<List<SeguimientoMoko>> getSeguimientosBySemana(@PathVariable Integer semanaInicio) {
        try {
            List<SeguimientoMoko> seguimientos = seguimientoMokoService.getSeguimientosBySemana(semanaInicio);
            return ResponseEntity.ok(seguimientos);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(null);
        }
    }

    @GetMapping("/pediluvio-activo")
    public ResponseEntity<List<SeguimientoMoko>> getSeguimientosConPediluvioActivo() {
        try {
            List<SeguimientoMoko> seguimientos = seguimientoMokoService.getSeguimientosConPediluvioActivo();
            return ResponseEntity.ok(seguimientos);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(null);
        }
    }

    @GetMapping("/cuarentena-activa")
    public ResponseEntity<List<SeguimientoMoko>> getSeguimientosConCuarentenaActiva() {
        try {
            List<SeguimientoMoko> seguimientos = seguimientoMokoService.getSeguimientosConCuarentenaActiva();
            return ResponseEntity.ok(seguimientos);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(null);
        }
    }

    @GetMapping("/estadisticas/foco/{focoId}")
    public ResponseEntity<Map<String, Object>> getEstadisticasFoco(@PathVariable Long focoId) {
        try {
            Long cantidadSeguimientos = seguimientoMokoService.countSeguimientosByFocoId(focoId);
            Optional<SeguimientoMoko> ultimoSeguimiento = seguimientoMokoService.getLastSeguimientoByFocoId(focoId);

            Map<String, Object> estadisticas = new HashMap<>();
            estadisticas.put("focoId", focoId);
            estadisticas.put("totalSeguimientos", cantidadSeguimientos);
            
            if (ultimoSeguimiento.isPresent()) {
                SeguimientoMoko ultimo = ultimoSeguimiento.get();
                estadisticas.put("ultimoSeguimiento", ultimo.getFechaSeguimiento());
                estadisticas.put("plantasAfectadasActuales", ultimo.getPlantasAfectadas());
                estadisticas.put("plantasInyectadas", ultimo.getPlantasInyectadas());
                estadisticas.put("pediluvioActivo", ultimo.getPediluvioActivo());
                estadisticas.put("cuarentenaActiva", ultimo.getCuarentenaActiva());
            } else {
                estadisticas.put("ultimoSeguimiento", null);
            }

            return ResponseEntity.ok(estadisticas);
        } catch (Exception e) {
            Map<String, Object> error = new HashMap<>();
            error.put("success", false);
            error.put("error", "Error al obtener estadísticas: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
        }
    }
}