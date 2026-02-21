package com.lytiks.backend.controller;

import com.lytiks.backend.entity.RegistroMoko;
import com.lytiks.backend.entity.Client;
import com.lytiks.backend.repository.ClientRepository;
import com.lytiks.backend.entity.Sintoma;
import com.lytiks.backend.entity.ProductoContencion;
import com.lytiks.backend.entity.Producto;
import com.lytiks.backend.entity.Aplicacion;
import com.lytiks.backend.entity.SeguimientoAplicacion;
import com.lytiks.backend.service.RegistroMokoService;
import com.lytiks.backend.service.SintomaService;
import com.lytiks.backend.service.SeguimientoAplicacionService;
import com.lytiks.backend.repository.ProductoContencionRepository;
import com.lytiks.backend.repository.ProductoRepository;
import com.lytiks.backend.repository.AplicacionRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
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
@RequestMapping("moko")
@CrossOrigin(origins = "*")
public class RegistroMokoController {

    @Autowired
    private RegistroMokoService registroMokoService;

    @Autowired
    private ClientRepository clientRepository;

    @Autowired
    private SintomaService sintomaService;
    
    @Autowired
    private ProductoContencionRepository productoContencionRepository;

    @Autowired
    private ProductoRepository productoRepository;
    
    @Autowired
    private AplicacionRepository aplicacionRepository;
    
    @Autowired
    private SeguimientoAplicacionService seguimientoService;

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
            System.out.println("🔍 SINTOMAS - Total encontrados: " + sintomas.size());
            for (Sintoma sintoma : sintomas) {
                System.out.println("  ID: " + sintoma.getId() + " - " + sintoma.getSintomaObservable() + " (" + sintoma.getSeveridad() + ")");
            }
            return ResponseEntity.ok(sintomas);
        } catch (Exception e) {
            System.err.println("❌ ERROR al obtener síntomas: " + e.getMessage());
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(null);
        }
    }

    @PostMapping("/registrar")
    public ResponseEntity<Map<String, Object>> registrarFoco(
            @RequestParam("numeroFoco") int numeroFoco,
            @RequestParam("clienteId") Long clienteId,
            @RequestParam(value = "lote", required = false) String lote,
            @RequestParam(value = "areaHectareas", required = false) Double areaHectareas,
            @RequestParam("gpsCoordinates") String gpsCoordinates,
            @RequestParam(value = "loteLatitud", required = false) Double loteLatitud,
            @RequestParam(value = "loteLongitud", required = false) Double loteLongitud,
            @RequestParam("plantasAfectadas") int plantasAfectadas,
            @RequestParam("fechaDeteccion") String fechaDeteccion,
            @RequestParam(value = "sintomaId", required = false) Long sintomaId,
            @RequestParam(value = "sintomasIds", required = false) String sintomasIds,
            @RequestParam(value = "sintomasDetalles", required = false) String sintomasDetalles,
            @RequestParam("severidad") String severidad,
            @RequestParam("metodoComprobacion") String metodoComprobacion,
            @RequestParam("observaciones") String observaciones,
            @RequestParam(value = "foto", required = false) MultipartFile foto) {

        try {
            System.out.println("🔥 REGISTRO MOKO - Datos recibidos:");
            System.out.println("numeroFoco: " + numeroFoco);
            System.out.println("clienteId: " + clienteId);
            System.out.println("lote: " + lote);
            System.out.println("areaHectareas: " + areaHectareas);
            System.out.println("gpsCoordinates: " + gpsCoordinates);
            System.out.println("loteLatitud: " + loteLatitud);
            System.out.println("loteLongitud: " + loteLongitud);
            System.out.println("plantasAfectadas: " + plantasAfectadas);
            System.out.println("fechaDeteccion: " + fechaDeteccion);
            System.out.println("sintomaId (legacy): " + sintomaId);
            System.out.println("sintomasIds: " + sintomasIds);
            System.out.println("sintomasDetalles: " + sintomasDetalles);
            System.out.println("severidad: " + severidad);
            System.out.println("metodoComprobacion: " + metodoComprobacion);
            System.out.println("observaciones: " + observaciones);
            System.out.println("foto: " + (foto != null ? foto.getOriginalFilename() : "null"));

            // Crear nuevo registro
            RegistroMoko registro = new RegistroMoko();
            registro.setNumeroFoco(numeroFoco);
            registro.setClienteId(clienteId);
            registro.setLote(lote);
            registro.setAreaHectareas(areaHectareas);
            registro.setGpsCoordinates(gpsCoordinates);
            registro.setLoteLatitud(loteLatitud);
            registro.setLoteLongitud(loteLongitud);
            registro.setPlantasAfectadas(plantasAfectadas);
            
            // Parsear fecha con mejor manejo de errores
            try {
                registro.setFechaDeteccion(LocalDateTime.parse(fechaDeteccion));
            } catch (Exception e) {
                System.err.println("Error parseando fecha: " + fechaDeteccion + " - " + e.getMessage());
                // Usar fecha actual como fallback
                registro.setFechaDeteccion(LocalDateTime.now());
            }
            
            // Manejar síntomas múltiples o único
            if (sintomasDetalles != null && !sintomasDetalles.isEmpty()) {
                registro.setSintomasJson(sintomasDetalles);
                System.out.println("✅ Guardando síntomas múltiples: " + sintomasDetalles);
            } else if (sintomaId != null) {
                registro.setSintomaId(sintomaId);
                System.out.println("✅ Guardando síntoma único (legacy): " + sintomaId);
            }
            
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
    public ResponseEntity<List<Map<String, Object>>> getRegistros() {
        try {
            List<RegistroMoko> registros = registroMokoService.getAllRegistros();
            List<Map<String, Object>> registrosEnriquecidos = new java.util.ArrayList<>();
            for (RegistroMoko registro : registros) {
                Map<String, Object> regMap = new java.util.HashMap<>();
                regMap.put("id", registro.getId());
                regMap.put("numeroFoco", registro.getNumeroFoco());
                regMap.put("clienteId", registro.getClienteId());
                regMap.put("gpsCoordinates", registro.getGpsCoordinates());
                regMap.put("loteLatitud", registro.getLoteLatitud());
                regMap.put("loteLongitud", registro.getLoteLongitud());
                regMap.put("plantasAfectadas", registro.getPlantasAfectadas());
                regMap.put("fechaDeteccion", registro.getFechaDeteccion());
                regMap.put("sintomaId", registro.getSintomaId());
                regMap.put("sintomasJson", registro.getSintomasJson());
                regMap.put("lote", registro.getLote());
                regMap.put("areaHectareas", registro.getAreaHectareas());
                regMap.put("severidad", registro.getSeveridad());
                regMap.put("metodoComprobacion", registro.getMetodoComprobacion());
                regMap.put("observaciones", registro.getObservaciones());
                regMap.put("fotoPath", registro.getFotoPath());
                regMap.put("fechaCreacion", registro.getFechaCreacion());
                regMap.put("cedulaCliente", registro.getCedulaCliente());
                // Enriquecer con datos del cliente
                if (registro.getClienteId() != null) {
                    clientRepository.findById(registro.getClienteId()).ifPresent(cliente -> {
                        regMap.put("nombreCliente", cliente.getNombreCompleto());
                        regMap.put("hacienda", cliente.getFincaNombre());
                    });
                } else {
                    regMap.put("nombreCliente", "N/A");
                    regMap.put("hacienda", "N/A");
                }
                registrosEnriquecidos.add(regMap);
            }
            return ResponseEntity.ok(registrosEnriquecidos);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(null);
        }
    }
    
    /**
     * Obtener registros Moko de un cliente específico
     */
    @GetMapping("/registros/cliente/{clienteId}")
    public ResponseEntity<List<Map<String, Object>>> getRegistrosByCliente(@PathVariable Long clienteId) {
        try {
            List<RegistroMoko> registros = registroMokoService.getRegistrosByClienteId(clienteId);
            List<Map<String, Object>> registrosEnriquecidos = new java.util.ArrayList<>();
            for (RegistroMoko registro : registros) {
                Map<String, Object> regMap = new java.util.HashMap<>();
                regMap.put("id", registro.getId());
                regMap.put("numeroFoco", registro.getNumeroFoco());
                regMap.put("clienteId", registro.getClienteId());
                regMap.put("gpsCoordinates", registro.getGpsCoordinates());
                regMap.put("loteLatitud", registro.getLoteLatitud());
                regMap.put("loteLongitud", registro.getLoteLongitud());
                regMap.put("plantasAfectadas", registro.getPlantasAfectadas());
                regMap.put("fechaDeteccion", registro.getFechaDeteccion());
                regMap.put("sintomaId", registro.getSintomaId());
                regMap.put("sintomasJson", registro.getSintomasJson());
                regMap.put("lote", registro.getLote());
                regMap.put("areaHectareas", registro.getAreaHectareas());
                regMap.put("severidad", registro.getSeveridad());
                regMap.put("metodoComprobacion", registro.getMetodoComprobacion());
                regMap.put("observaciones", registro.getObservaciones());
                regMap.put("fotoPath", registro.getFotoPath());
                regMap.put("fechaCreacion", registro.getFechaCreacion());
                registrosEnriquecidos.add(regMap);
            }
            return ResponseEntity.ok(registrosEnriquecidos);
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
            @RequestParam(value = "loteLatitud", required = false) Double loteLatitud,
            @RequestParam(value = "loteLongitud", required = false) Double loteLongitud,
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
            if (loteLatitud != null) {
                registro.setLoteLatitud(loteLatitud);
            }
            if (loteLongitud != null) {
                registro.setLoteLongitud(loteLongitud);
            }
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
    public ResponseEntity<List<RegistroMoko>> getRegistrosByClienteSimple(@PathVariable Long clienteId) {
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

    // Endpoint para productos de contención, ahora usando la entidad Producto
    @GetMapping("/productos-contencion")
    public ResponseEntity<List<Map<String, Object>>> getProductosContencion() {
        try {
            List<ProductoContencion> productosContencion = productoContencionRepository.findAll();
            List<Map<String, Object>> resultado = new java.util.ArrayList<>();
            for (ProductoContencion pc : productosContencion) {
                Map<String, Object> obj = new HashMap<>();
                Producto prod = pc.getProducto();
                if (prod != null) {
                    obj.put("idProducto", prod.getIdProducto());
                    obj.put("nombre", prod.getNombre());
                    obj.put("detalle", prod.getDetalle());
                    obj.put("cantidad", prod.getCantidad());
                    obj.put("pesoKg", prod.getPesoKg());
                }
                obj.put("presentacion", pc.getPresentacion());
                obj.put("dosisSugerida", pc.getDosisSugerida());
                obj.put("url", pc.getUrl());
                resultado.add(obj);
            }
            return ResponseEntity.ok(resultado);
        } catch (Exception e) {
            System.err.println("Error obteniendo productos: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(null);
        }
    }

    @PostMapping("/init-productos")
    public ResponseEntity<Map<String, Object>> initProductos() {
        try {
            // Limpiar productos existentes
            productoContencionRepository.deleteAll();
            productoRepository.deleteAll();

            // Crear productos con las especificaciones correctas
            Producto goldenProducto = new Producto();
            goldenProducto.setNombre("Golden Crop");
            goldenProducto.setDetalle("Producto para contención");
            goldenProducto.setCantidad(1);
            goldenProducto.setPesoKg(1.0);
            productoRepository.save(goldenProducto);

            ProductoContencion golden = new ProductoContencion();
            golden.setProducto(goldenProducto);
            golden.setPresentacion("1L");
            golden.setDosisSugerida("1L/400L/agua/ha");
            golden.setUrl("https://example.com/golden-crop");
            productoContencionRepository.save(golden);

            Producto previotikProducto = new Producto();
            previotikProducto.setNombre("Previotik Crop");
            previotikProducto.setDetalle("Producto para contención");
            previotikProducto.setCantidad(1);
            previotikProducto.setPesoKg(6.6);
            productoRepository.save(previotikProducto);

            ProductoContencion previotik = new ProductoContencion();
            previotik.setProducto(previotikProducto);
            previotik.setPresentacion("6.6kg");
            previotik.setDosisSugerida("6.6kg/ha (con fertilizante)");
            previotik.setUrl("https://example.com/previotik-crop");
            productoContencionRepository.save(previotik);

            Producto saferbacterProducto = new Producto();
            saferbacterProducto.setNombre("Saferbacter");
            saferbacterProducto.setDetalle("Producto para contención");
            saferbacterProducto.setCantidad(1);
            saferbacterProducto.setPesoKg(0.25);
            productoRepository.save(saferbacterProducto);

            ProductoContencion saferbacter = new ProductoContencion();
            saferbacter.setProducto(saferbacterProducto);
            saferbacter.setPresentacion("250g");
            saferbacter.setDosisSugerida("250g/400L/agua/ha");
            saferbacter.setUrl("https://example.com/saferbacter");
            productoContencionRepository.save(saferbacter);

            Producto safersoilProducto = new Producto();
            safersoilProducto.setNombre("Safersoil Trichoderma");
            safersoilProducto.setDetalle("Producto para contención");
            safersoilProducto.setCantidad(1);
            safersoilProducto.setPesoKg(0.25);
            productoRepository.save(safersoilProducto);

            ProductoContencion safersoil = new ProductoContencion();
            safersoil.setProducto(safersoilProducto);
            safersoil.setPresentacion("250g");
            safersoil.setDosisSugerida("250g/400L/agua/ha");
            safersoil.setUrl("https://example.com/safersoil-trichoderma");
            productoContencionRepository.save(safersoil);

            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Productos inicializados correctamente");
            response.put("total", 4);

            return ResponseEntity.ok(response);
        } catch (Exception e) {
            Map<String, Object> error = new HashMap<>();
            error.put("success", false);
            error.put("error", "Error inicializando productos: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
        }
    }

    @PostMapping("/aplicaciones-contencion")
    public ResponseEntity<Map<String, Object>> saveAplicacionContencion(@RequestBody Aplicacion aplicacion) {
        try {
            Aplicacion savedAplicacion = aplicacionRepository.save(aplicacion);
            
            // Crear seguimiento automático
            seguimientoService.crearSeguimientoAutomatico(savedAplicacion);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Aplicación guardada exitosamente");
            response.put("id", savedAplicacion.getId());
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
        } catch (Exception e) {
            Map<String, Object> error = new HashMap<>();
            error.put("success", false);
            error.put("error", "Error al guardar aplicación: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
        }
    }

    // Endpoints para seguimiento de aplicaciones
    @GetMapping("/seguimiento/{aplicacionId}")
    public ResponseEntity<Map<String, Object>> getSeguimiento(@PathVariable Long aplicacionId) {
        try {
            Map<String, Object> seguimiento = seguimientoService.getResumenSeguimiento(aplicacionId);
            return ResponseEntity.ok(seguimiento);
        } catch (Exception e) {
            Map<String, Object> error = new HashMap<>();
            error.put("success", false);
            error.put("error", "Error al obtener seguimiento: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
        }
    }

    @PostMapping("/seguimiento/{seguimientoId}/completar")
    public ResponseEntity<Map<String, Object>> marcarCompletada(
            @PathVariable Long seguimientoId,
            @RequestParam(required = false) String observaciones,
            @RequestParam(value = "foto", required = false) MultipartFile foto) {
        try {
            String fotoPath = null;
            if (foto != null && !foto.isEmpty()) {
                // Guardar foto de evidencia
                fotoPath = guardarFotoEvidencia(foto, seguimientoId);
            }

            SeguimientoAplicacion seguimiento = seguimientoService.marcarCompletada(
                seguimientoId, 
                observaciones, 
                fotoPath
            );

            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Aplicación marcada como completada");
            response.put("seguimiento", seguimiento);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            Map<String, Object> error = new HashMap<>();
            error.put("success", false);
            error.put("error", "Error al marcar aplicación: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
        }
    }

    @PostMapping("/seguimiento/{seguimientoId}/reprogramar")
    public ResponseEntity<Map<String, Object>> reprogramarAplicacion(
            @PathVariable Long seguimientoId,
            @RequestParam String nuevaFecha,
            @RequestParam String nuevaHora) {
        try {
            LocalDateTime fecha = LocalDateTime.parse(nuevaFecha);
            SeguimientoAplicacion seguimiento = seguimientoService.reprogramarAplicacion(
                seguimientoId, 
                fecha, 
                nuevaHora
            );

            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Aplicación reprogramada exitosamente");
            response.put("seguimiento", seguimiento);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            Map<String, Object> error = new HashMap<>();
            error.put("success", false);
            error.put("error", "Error al reprogramar aplicación: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
        }
    }

    @PostMapping("/api/seguimiento-moko/registrar")
    public ResponseEntity<Map<String, Object>> registrarSeguimiento(@RequestBody Map<String, Object> body) {
        try {
            SeguimientoAplicacion seguimiento = new SeguimientoAplicacion();
            if (body.containsKey("aplicacionId")) seguimiento.setAplicacionId(Long.valueOf(body.get("aplicacionId").toString()));
            if (body.containsKey("numeroAplicacion")) seguimiento.setNumeroAplicacion(Integer.valueOf(body.get("numeroAplicacion").toString()));
            if (body.containsKey("fechaProgramada")) seguimiento.setFechaProgramada(java.time.LocalDateTime.parse(body.get("fechaProgramada").toString()));
            if (body.containsKey("estado")) seguimiento.setEstado(body.get("estado").toString());
            if (body.containsKey("dosisAplicada")) seguimiento.setDosisAplicada(body.get("dosisAplicada").toString());
            if (body.containsKey("lote")) seguimiento.setLote(body.get("lote").toString());
            if (body.containsKey("observaciones")) seguimiento.setObservaciones(body.get("observaciones").toString());
            seguimiento.setFechaCreacion(java.time.LocalDateTime.now());

            SeguimientoAplicacion saved = seguimientoService.saveSeguimiento(seguimiento);

            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Seguimiento guardado correctamente");
            response.put("id", saved.getId());
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
        } catch (Exception e) {
            Map<String, Object> error = new HashMap<>();
            error.put("success", false);
            error.put("error", "Error al guardar seguimiento: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
        }
    }





    private String guardarFotoEvidencia(MultipartFile foto, Long seguimientoId) throws IOException {
        // Crear directorio si no existe
        Path uploadPath = Paths.get("photos/evidencias/");
        if (!Files.exists(uploadPath)) {
            Files.createDirectories(uploadPath);
        }

        // Generar nombre único para la foto
        String timestamp = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMdd_HHmmss"));
        String extension = getFileExtension(foto.getOriginalFilename());
        String fileName = String.format("evidencia_%d_%s_%s.%s", 
            seguimientoId, timestamp, UUID.randomUUID().toString().substring(0, 8), extension);
        
        Path filePath = uploadPath.resolve(fileName);
        
        // Guardar archivo
        Files.copy(foto.getInputStream(), filePath, StandardCopyOption.REPLACE_EXISTING);
        
        return "photos/evidencias/" + fileName;
    }
}
