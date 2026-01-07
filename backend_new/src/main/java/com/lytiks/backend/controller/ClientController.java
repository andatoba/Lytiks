package com.lytiks.backend.controller;

import com.lytiks.backend.entity.Client;
import com.lytiks.backend.repository.ClientRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/clients")
@CrossOrigin(origins = "*")
public class ClientController {

    @Autowired
    private ClientRepository clientRepository;

    // Buscar cliente por cédula (para autocompletado)
    @GetMapping("/search/cedula/{cedula}")
    public ResponseEntity<Map<String, Object>> searchClientByCedula(@PathVariable String cedula) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            Optional<Client> client = clientRepository.findByCedula(cedula);
            
            if (client.isPresent()) {
                Client foundClient = client.get();
                Map<String, Object> clientData = new HashMap<>();
                clientData.put("id", foundClient.getId());
                clientData.put("cedula", foundClient.getCedula());
                clientData.put("nombre", foundClient.getNombre());
                clientData.put("apellidos", foundClient.getApellidos());
                clientData.put("telefono", foundClient.getTelefono());
                clientData.put("email", foundClient.getEmail());
                clientData.put("direccion", foundClient.getDireccion());
                clientData.put("parroquia", foundClient.getParroquia());
                clientData.put("nombreFinca", foundClient.getFincaNombre());
                clientData.put("fincaHectareas", foundClient.getFincaHectareas());
                clientData.put("cultivosPrincipales", foundClient.getCultivosPrincipales());
                clientData.put("geolocalizacionLat", foundClient.getGeolocalizacionLat());
                clientData.put("geolocalizacionLng", foundClient.getGeolocalizacionLng());
                clientData.put("observaciones", foundClient.getObservaciones());
                clientData.put("tecnicoAsignadoId", foundClient.getTecnicoAsignadoId());

                System.out.println("Cliente encontrado: " + clientData);
                response = clientData; // Enviar directamente los datos del cliente
            } else {
                // Buscar hacienda por cédula si existe
                Optional<Client> hacienda = clientRepository.findByCedula(cedula);
                String nombreFinca = hacienda.isPresent() ? hacienda.get().getFincaNombre() : "";
                if (nombreFinca != null && !nombreFinca.isEmpty()) {
                    response.put("error", "No se encontró ningún cliente registrado, pero la hacienda asociada es: " + nombreFinca);
                } else {
                    response.put("error", "No se encontró ningún cliente ni hacienda registrada con la cédula: " + cedula);
                }
            }
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            response.put("found", false);
            response.put("message", "Error al buscar cliente: " + e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }

    // Crear nuevo cliente
    @PostMapping("/create")
    public ResponseEntity<Map<String, Object>> createClient(@RequestBody Map<String, Object> clientData) {
        Map<String, Object> response = new HashMap<>();
        
    try {
            // Validación de campos requeridos
            if (!clientData.containsKey("cedula") || clientData.get("cedula") == null || 
                ((String)clientData.get("cedula")).trim().isEmpty()) {
                response.put("success", false);
                response.put("message", "La cédula es requerida");
                return ResponseEntity.badRequest().body(response);
            }

            String cedula = (String) clientData.get("cedula");
            
            // Verificar si ya existe un cliente con esa cédula
            if (clientRepository.existsByCedula(cedula)) {
                response.put("success", false);
                response.put("message", "Ya existe un cliente con esta cédula");
                return ResponseEntity.badRequest().body(response);
            }
            
            Client client = new Client();
            client.setCedula(cedula);

            // Manejo seguro de campos String
            try {
                client.setNombre(clientData.get("nombre") != null ? (String) clientData.get("nombre") : null);
                client.setApellidos(clientData.get("apellidos") != null ? (String) clientData.get("apellidos") : null);
                client.setTelefono(clientData.get("telefono") != null ? (String) clientData.get("telefono") : null);
                client.setEmail(clientData.get("email") != null ? (String) clientData.get("email") : null);
                client.setDireccion(clientData.get("direccion") != null ? (String) clientData.get("direccion") : null);
                client.setParroquia(clientData.get("parroquia") != null ? (String) clientData.get("parroquia") : null);
                client.setFincaNombre(clientData.get("fincaNombre") != null ? (String) clientData.get("fincaNombre") : null);
                client.setCultivosPrincipales(clientData.get("cultivosPrincipales") != null ? 
                    (String) clientData.get("cultivosPrincipales") : null);
                client.setObservaciones(clientData.get("observaciones") != null ? 
                    (String) clientData.get("observaciones") : null);
            } catch (ClassCastException e) {
                response.put("success", false);
                response.put("message", "Error en el formato de los campos de texto: " + e.getMessage());
                return ResponseEntity.badRequest().body(response);
            }
            
            // Manejo seguro de campos numéricos
            try {
                if (clientData.get("fincaHectareas") != null && !clientData.get("fincaHectareas").toString().isEmpty()) {
                    client.setFincaHectareas(Double.valueOf(clientData.get("fincaHectareas").toString()));
                }
                
                if (clientData.get("geolocalizacionLat") != null && !clientData.get("geolocalizacionLat").toString().isEmpty()) {
                    client.setGeolocalizacionLat(Double.valueOf(clientData.get("geolocalizacionLat").toString()));
                }
                
                if (clientData.get("geolocalizacionLng") != null && !clientData.get("geolocalizacionLng").toString().isEmpty()) {
                    client.setGeolocalizacionLng(Double.valueOf(clientData.get("geolocalizacionLng").toString()));
                }
                
                if (clientData.get("tecnicoAsignadoId") != null && !clientData.get("tecnicoAsignadoId").toString().isEmpty()) {
                    client.setTecnicoAsignadoId(Long.valueOf(clientData.get("tecnicoAsignadoId").toString()));
                }
            } catch (NumberFormatException e) {
                response.put("success", false);
                response.put("message", "Error en el formato de los campos numéricos: " + e.getMessage());
                return ResponseEntity.badRequest().body(response);
            }
            
            Client savedClient = clientRepository.save(client);
            
            response.put("success", true);
            response.put("message", "Cliente creado exitosamente");
            response.put("clientId", savedClient.getId());
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            e.printStackTrace(); // Log detallado en consola
            response.put("success", false);
            response.put("message", "Error al crear cliente: " + e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }

    // Actualizar cliente existente
    @PutMapping("/update/{id}")
    public ResponseEntity<Map<String, Object>> updateClient(
            @PathVariable Long id, 
            @RequestBody Map<String, Object> clientData) {
        
        Map<String, Object> response = new HashMap<>();
        
        try {
            Optional<Client> clientOpt = clientRepository.findById(id);
            
            if (clientOpt.isPresent()) {
                Client client = clientOpt.get();
                boolean anyChange = false;
                // Actualizar campos si están presentes (siempre actualiza aunque sean nulos o vacíos)
                // Solo permitir actualización de los siguientes campos:
                if (clientData.containsKey("telefono")) {
                    client.setTelefono((String) clientData.get("telefono"));
                    anyChange = true;
                }
                if (clientData.containsKey("email")) {
                    client.setEmail((String) clientData.get("email"));
                    anyChange = true;
                }
                if (clientData.containsKey("direccion")) {
                    client.setDireccion((String) clientData.get("direccion"));
                    anyChange = true;
                }
                if (clientData.containsKey("parroquia")) {
                    client.setParroquia((String) clientData.get("parroquia"));
                    anyChange = true;
                }
                // eliminado departamento
                if (clientData.containsKey("fincaNombre")) {
                    client.setFincaNombre((String) clientData.get("fincaNombre"));
                    anyChange = true;
                }
                if (clientData.containsKey("fincaHectareas")) {
                    Object hect = clientData.get("fincaHectareas");
                    if (hect != null && !hect.toString().isEmpty()) {
                        try {
                            client.setFincaHectareas(Double.valueOf(hect.toString()));
                        } catch (NumberFormatException ex) {
                            client.setFincaHectareas(null);
                        }
                    } else {
                        client.setFincaHectareas(null);
                    }
                    anyChange = true;
                }
                if (clientData.containsKey("cultivosPrincipales")) {
                    client.setCultivosPrincipales((String) clientData.get("cultivosPrincipales"));
                    anyChange = true;
                }
                if (clientData.containsKey("geolocalizacionLat")) {
                    Object lat = clientData.get("geolocalizacionLat");
                    if (lat != null && !lat.toString().isEmpty()) {
                        try {
                            client.setGeolocalizacionLat(Double.valueOf(lat.toString()));
                        } catch (NumberFormatException ex) {
                            client.setGeolocalizacionLat(null);
                        }
                    } else {
                        client.setGeolocalizacionLat(null);
                    }
                    anyChange = true;
                }
                if (clientData.containsKey("geolocalizacionLng")) {
                    Object lng = clientData.get("geolocalizacionLng");
                    if (lng != null && !lng.toString().isEmpty()) {
                        try {
                            client.setGeolocalizacionLng(Double.valueOf(lng.toString()));
                        } catch (NumberFormatException ex) {
                            client.setGeolocalizacionLng(null);
                        }
                    } else {
                        client.setGeolocalizacionLng(null);
                    }
                    anyChange = true;
                }
                if (clientData.containsKey("observaciones")) {
                    client.setObservaciones((String) clientData.get("observaciones"));
                    anyChange = true;
                }
                if (clientData.containsKey("estado")) {
                    client.setEstado((String) clientData.get("estado"));
                    anyChange = true;
                }
                // Si no se envió ningún campo, igual se actualiza la fecha
                client.setFechaActualizacion(LocalDateTime.now());
                clientRepository.save(client);
                response.put("success", true);
                response.put("message", "Cliente actualizado exitosamente");
                return ResponseEntity.ok(response);
            } else {
                response.put("success", false);
                response.put("message", "No se encontró ningún cliente registrado con ese ID.");
                return ResponseEntity.notFound().build();
            }
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "Error al actualizar cliente: " + e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }

    // Obtener todos los clientes
    @GetMapping("/all")
    public ResponseEntity<List<Client>> getAllClients() {
        List<Client> clients = clientRepository.findAll();
        return ResponseEntity.ok(clients);
    }

    // Obtener clientes por técnico
    @GetMapping("/technician/{tecnicoId}")
    public ResponseEntity<List<Client>> getClientsByTechnician(@PathVariable Long tecnicoId) {
        List<Client> clients = clientRepository.findByTecnicoAsignadoId(tecnicoId);
        return ResponseEntity.ok(clients);
    }

    // Buscar clientes por nombre
    @GetMapping("/search/name/{nombre}")
    public ResponseEntity<List<Client>> searchClientsByName(@PathVariable String nombre) {
        List<Client> clients = clientRepository.findByNombreCompletoContaining(nombre);
        return ResponseEntity.ok(clients);
    }

    // Obtener cliente por ID
    @GetMapping("/{id}")
    public ResponseEntity<Client> getClientById(@PathVariable Long id) {
        Optional<Client> client = clientRepository.findById(id);
        return client.map(ResponseEntity::ok).orElse(ResponseEntity.notFound().build());
    }

    // Eliminar cliente
    @DeleteMapping("/{id}")
    public ResponseEntity<Map<String, Object>> deleteClient(@PathVariable Long id) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            if (clientRepository.existsById(id)) {
                clientRepository.deleteById(id);
                response.put("success", true);
                response.put("message", "Cliente eliminado exitosamente");
                return ResponseEntity.ok(response);
            } else {
                response.put("success", false);
                response.put("message", "No se encontró ningún cliente registrado con esa cédula.");
                return ResponseEntity.notFound().build();
            }
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "Error al eliminar cliente: " + e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }

    // Estadísticas de clientes
    @GetMapping("/stats")
    public ResponseEntity<Map<String, Object>> getClientsStats() {
        Map<String, Object> stats = new HashMap<>();
        
        try {
            long totalClients = clientRepository.count();
            long activeClients = clientRepository.countByEstado("ACTIVO");
            Double totalHectareas = clientRepository.sumTotalHectareas();
            List<Client> recentClients = clientRepository.findRecentClients()
                    .stream().limit(5).toList();
            
            stats.put("totalClients", totalClients);
            stats.put("activeClients", activeClients);
            stats.put("totalHectareas", totalHectareas != null ? totalHectareas : 0.0);
            stats.put("recentClients", recentClients);
            
            return ResponseEntity.ok(stats);
            
        } catch (Exception e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("error", "Error al obtener estadísticas: " + e.getMessage());
            return ResponseEntity.badRequest().body(errorResponse);
        }
    }
}