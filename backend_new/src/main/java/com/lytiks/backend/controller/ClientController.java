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
                response.put("found", true);
                response.put("client", client.get());
                response.put("message", "Cliente encontrado");
            } else {
                response.put("found", false);
                response.put("message", "Cliente no encontrado");
            }
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            response.put("found", false);
            response.put("error", "Error al buscar cliente: " + e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }

    // Crear nuevo cliente
    @PostMapping("/create")
    public ResponseEntity<Map<String, Object>> createClient(@RequestBody Map<String, Object> clientData) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            String cedula = (String) clientData.get("cedula");
            
            // Verificar si ya existe un cliente con esa cédula
            if (clientRepository.existsByCedula(cedula)) {
                response.put("success", false);
                response.put("message", "Ya existe un cliente con esta cédula");
                return ResponseEntity.badRequest().body(response);
            }
            
            Client client = new Client();
            client.setCedula(cedula);
            client.setNombre((String) clientData.get("nombre"));
            client.setApellidos((String) clientData.get("apellidos"));
            client.setTelefono((String) clientData.get("telefono"));
            client.setEmail((String) clientData.get("email"));
            client.setDireccion((String) clientData.get("direccion"));
            client.setMunicipio((String) clientData.get("municipio"));
            client.setDepartamento((String) clientData.get("departamento"));
            client.setFincaNombre((String) clientData.get("fincaNombre"));
            
            if (clientData.get("fincaHectareas") != null) {
                client.setFincaHectareas(Double.valueOf(clientData.get("fincaHectareas").toString()));
            }
            
            client.setCultivosPrincipales((String) clientData.get("cultivosPrincipales"));
            client.setTipoProductor((String) clientData.get("tipoProductor"));
            client.setAsociacion((String) clientData.get("asociacion"));
            
            if (clientData.get("geolocalizacionLat") != null) {
                client.setGeolocalizacionLat(Double.valueOf(clientData.get("geolocalizacionLat").toString()));
            }
            
            if (clientData.get("geolocalizacionLng") != null) {
                client.setGeolocalizacionLng(Double.valueOf(clientData.get("geolocalizacionLng").toString()));
            }
            
            client.setObservaciones((String) clientData.get("observaciones"));
            
            if (clientData.get("tecnicoAsignadoId") != null) {
                client.setTecnicoAsignadoId(Long.valueOf(clientData.get("tecnicoAsignadoId").toString()));
            }
            
            Client savedClient = clientRepository.save(client);
            
            response.put("success", true);
            response.put("message", "Cliente creado exitosamente");
            response.put("clientId", savedClient.getId());
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
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
                
                // Actualizar campos si están presentes
                if (clientData.containsKey("nombre")) {
                    client.setNombre((String) clientData.get("nombre"));
                }
                if (clientData.containsKey("apellidos")) {
                    client.setApellidos((String) clientData.get("apellidos"));
                }
                if (clientData.containsKey("telefono")) {
                    client.setTelefono((String) clientData.get("telefono"));
                }
                if (clientData.containsKey("email")) {
                    client.setEmail((String) clientData.get("email"));
                }
                if (clientData.containsKey("direccion")) {
                    client.setDireccion((String) clientData.get("direccion"));
                }
                if (clientData.containsKey("municipio")) {
                    client.setMunicipio((String) clientData.get("municipio"));
                }
                if (clientData.containsKey("departamento")) {
                    client.setDepartamento((String) clientData.get("departamento"));
                }
                if (clientData.containsKey("fincaNombre")) {
                    client.setFincaNombre((String) clientData.get("fincaNombre"));
                }
                if (clientData.containsKey("fincaHectareas")) {
                    client.setFincaHectareas(Double.valueOf(clientData.get("fincaHectareas").toString()));
                }
                if (clientData.containsKey("cultivosPrincipales")) {
                    client.setCultivosPrincipales((String) clientData.get("cultivosPrincipales"));
                }
                if (clientData.containsKey("tipoProductor")) {
                    client.setTipoProductor((String) clientData.get("tipoProductor"));
                }
                if (clientData.containsKey("asociacion")) {
                    client.setAsociacion((String) clientData.get("asociacion"));
                }
                if (clientData.containsKey("geolocalizacionLat")) {
                    client.setGeolocalizacionLat(Double.valueOf(clientData.get("geolocalizacionLat").toString()));
                }
                if (clientData.containsKey("geolocalizacionLng")) {
                    client.setGeolocalizacionLng(Double.valueOf(clientData.get("geolocalizacionLng").toString()));
                }
                if (clientData.containsKey("observaciones")) {
                    client.setObservaciones((String) clientData.get("observaciones"));
                }
                if (clientData.containsKey("estado")) {
                    client.setEstado((String) clientData.get("estado"));
                }
                
                client.setFechaActualizacion(LocalDateTime.now());
                clientRepository.save(client);
                
                response.put("success", true);
                response.put("message", "Cliente actualizado exitosamente");
                return ResponseEntity.ok(response);
                
            } else {
                response.put("success", false);
                response.put("message", "Cliente no encontrado");
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
                response.put("message", "Cliente no encontrado");
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
            List<Client> recentClients = clientRepository.findRecentClients()
                    .stream().limit(5).toList();
            
            stats.put("totalClients", totalClients);
            stats.put("activeClients", activeClients);
            stats.put("recentClients", recentClients);
            
            return ResponseEntity.ok(stats);
            
        } catch (Exception e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("error", "Error al obtener estadísticas: " + e.getMessage());
            return ResponseEntity.badRequest().body(errorResponse);
        }
    }
}