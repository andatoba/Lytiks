package com.lytiks.backend.controller;

import com.lytiks.backend.entity.IsUsuario;
import com.lytiks.backend.entity.IsRol;
import com.lytiks.backend.repository.IsUsuarioRepository;
import com.lytiks.backend.repository.IsRolRepository;
import com.lytiks.backend.util.AESEncryption;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.ExampleObject;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/auth")
@CrossOrigin(origins = "*")
@Tag(name = "Autenticación", description = "Endpoints para autenticación y gestión de usuarios")
public class AuthController {

    @Autowired
    private IsUsuarioRepository isUsuarioRepository;
    
    @Autowired
    private IsRolRepository isRolRepository;

    // Endpoint para obtener perfil de usuario por username
    @Operation(
        summary = "Obtener perfil de usuario",
        description = "Obtiene el perfil completo de un usuario incluyendo su rol"
    )
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Perfil obtenido exitosamente"),
        @ApiResponse(responseCode = "404", description = "Usuario no encontrado"),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor")
    })
    @GetMapping("/profile/{username}")
    public ResponseEntity<?> getProfile(
        @Parameter(description = "Nombre de usuario", required = true)
        @PathVariable String username
    ) {
        try {
            Optional<IsUsuario> userOpt = isUsuarioRepository.findActiveUserByUsuario(username);
            if (userOpt.isEmpty()) {
                return ResponseEntity.notFound().build();
            }
            IsUsuario user = userOpt.get();
            
            // Obtener información del rol
            Optional<IsRol> rolOpt = isRolRepository.findById(user.getIdRoles());
            String rolNombre = rolOpt.map(IsRol::getNombre).orElse("UNKNOWN");
            
            // Crear perfil manejando posibles valores null
            Map<String, Object> profile = new HashMap<>();
            profile.put("id", user.getIdUsuarios() != null ? user.getIdUsuarios() : 0);
            profile.put("usuario", user.getUsuario() != null ? user.getUsuario() : "");
            profile.put("nombres", user.getNombres() != null ? user.getNombres() : "");
            profile.put("apellidos", user.getApellidos() != null ? user.getApellidos() : "");
            profile.put("correo", user.getCorreo() != null ? user.getCorreo() : "");
            profile.put("rol", rolNombre);
            profile.put("cedula", user.getCedula() != null ? user.getCedula() : "");
            profile.put("direccion", user.getDireccionDom() != null ? user.getDireccionDom() : "");
            profile.put("telefonoCasa", user.getTelefonoCasa() != null ? user.getTelefonoCasa() : "");
            profile.put("telefonoCel", user.getTelefonoCel() != null ? user.getTelefonoCel() : "");
            profile.put("tipoPersona", user.getTipoPersona() != null ? user.getTipoPersona() : "");
            profile.put("idArea", user.getIdArea() != null ? user.getIdArea() : 0);
            profile.put("idEmpresa", user.getIdEmpresa() != null ? user.getIdEmpresa() : 0);
            profile.put("idCiudad", user.getIdCiudad() != null ? user.getIdCiudad() : 0);
            profile.put("idSector", user.getIdSector() != null ? user.getIdSector() : 0);
            profile.put("estado", user.getEstado() != null ? user.getEstado() : "");
            profile.put("detalle", user.getDetalle() != null ? user.getDetalle() : "");
            profile.put("logo", user.getLogo() != null ? user.getLogo() : "");
            profile.put("logoRuta", user.getLogoRuta() != null ? user.getLogoRuta() : "");
            profile.put("fechaIngreso", user.getFechaIngreso() != null ? user.getFechaIngreso() : null);
            profile.put("fechaModificacion", user.getFechaModificacion() != null ? user.getFechaModificacion() : null);
            profile.put("usuarioIngreso", user.getUsuarioIngreso() != null ? user.getUsuarioIngreso() : "");
            profile.put("usuarioModificacion", user.getUsuarioModificacion() != null ? user.getUsuarioModificacion() : "");
            
            return ResponseEntity.ok(profile);
        } catch (Exception e) {
            System.out.println("❌ Error obteniendo perfil: " + e.getMessage());
            e.printStackTrace();
            return ResponseEntity.status(500).body(Map.of("error", "Error interno del servidor"));
        }
    }
    
    // Endpoint de login con encriptación AES
    @Operation(
        summary = "Iniciar sesión",
        description = "Autentica un usuario con sus credenciales y devuelve un token de acceso"
    )
    @ApiResponses(value = {
        @ApiResponse(
            responseCode = "200", 
            description = "Login exitoso",
            content = @Content(
                mediaType = "application/json",
                examples = @ExampleObject(
                    value = "{\"token\": \"token_1_1234567890\", \"user\": {\"id\": 1, \"usuario\": \"admin\", \"nombres\": \"Juan\", \"apellidos\": \"Pérez\", \"correo\": \"admin@lytiks.com\", \"rol\": \"ADMIN\"}}"
                )
            )
        ),
        @ApiResponse(responseCode = "401", description = "Credenciales inválidas"),
        @ApiResponse(responseCode = "400", description = "Credenciales incompletas"),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor")
    })
    @PostMapping("/login")
    public ResponseEntity<?> login(
        @io.swagger.v3.oas.annotations.parameters.RequestBody(
            description = "Credenciales del usuario (contraseña encriptada con AES)",
            required = true,
            content = @Content(
                mediaType = "application/json",
                examples = @ExampleObject(
                    value = "{\"username\": \"admin\", \"password\": \"encryptedPasswordHere\"}"
                )
            )
        )
        @RequestBody Map<String, String> credentials
    ) {
        IsUsuario user = null;
        String username = null;
        
        try {
            username = credentials.get("username");
            String encryptedPassword = credentials.get("password");
            
            System.out.println("🔐 Login attempt for user: " + username);
            System.out.println("🔐 Encrypted password received: " + encryptedPassword);
            
            if (username == null || encryptedPassword == null) {
                System.out.println("❌ Credenciales incompletas");
                return ResponseEntity.badRequest().body(Map.of("error", "Usuario y contraseña son requeridos"));
            }
            
            Optional<IsUsuario> userOpt = isUsuarioRepository.findActiveUserByUsuario(username);
            if (userOpt.isEmpty()) {
                System.out.println("❌ Usuario no encontrado: " + username);
                return ResponseEntity.status(401).body(Map.of("error", "Usuario o contraseña incorrectos"));
            }
            
            user = userOpt.get();
            System.out.println("👤 Usuario encontrado: " + user.getUsuario());
            System.out.println("🔒 Password in DB: " + user.getClave());
            System.out.println("🔒 Password received: " + encryptedPassword);
            System.out.println("🔍 Passwords match: " + user.getClave().equals(encryptedPassword));
            
            // Verificar contraseña encriptada
            if (!user.getClave().equals(encryptedPassword)) {
                System.out.println("❌ Contraseña incorrecta");
                return ResponseEntity.status(401).body(Map.of("error", "Usuario o contraseña incorrectos"));
            }
            
            // Obtener información del rol
            Optional<IsRol> rolOpt = isRolRepository.findById(user.getIdRoles());
            String rolNombre = rolOpt.map(IsRol::getNombre).orElse("UNKNOWN");
            
            // Generar token básico (en producción usar JWT)
            String token = "token_" + user.getIdUsuarios() + "_" + System.currentTimeMillis();
            
            // Crear respuesta manejando posibles valores null
            Map<String, Object> userMap = new HashMap<>();
            userMap.put("id", user.getIdUsuarios() != null ? user.getIdUsuarios() : 0);
            userMap.put("usuario", user.getUsuario() != null ? user.getUsuario() : "");
            userMap.put("nombres", user.getNombres() != null ? user.getNombres() : "");
            userMap.put("apellidos", user.getApellidos() != null ? user.getApellidos() : "");
            userMap.put("correo", user.getCorreo() != null ? user.getCorreo() : "");
            userMap.put("rol", rolNombre);
            
            Map<String, Object> response = new HashMap<>();
            response.put("token", token);
            response.put("user", userMap);
            
            System.out.println("✅ Login exitoso para usuario: " + username);
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            System.out.println("❌ Error durante login: " + e.getMessage());
            e.printStackTrace();
            return ResponseEntity.status(500).body(Map.of("error", "Error interno del servidor"));
        }
    }
    
    @Operation(
        summary = "Endpoint de prueba",
        description = "Verifica que el servicio de autenticación está funcionando"
    )
    @ApiResponse(responseCode = "200", description = "Servicio funcionando correctamente")
    @GetMapping("/test")
    public ResponseEntity<String> test() {
        return ResponseEntity.ok("Auth endpoint funcionando correctamente con is_usuarios!");
    }
}
