package com.lytiks.backend.controller;

import com.lytiks.backend.entity.IsUsuario;
import com.lytiks.backend.entity.IsRol;
import com.lytiks.backend.repository.IsUsuarioRepository;
import com.lytiks.backend.repository.IsRolRepository;
import com.lytiks.backend.util.AESEncryption;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/auth")
@CrossOrigin(origins = "*")
public class AuthController {

    @Autowired
    private IsUsuarioRepository isUsuarioRepository;
    
    @Autowired
    private IsRolRepository isRolRepository;

    // Endpoint para obtener perfil de usuario por username
    @GetMapping("/profile/{username}")
    public ResponseEntity<?> getProfile(@PathVariable String username) {
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
            
            return ResponseEntity.ok(profile);
        } catch (Exception e) {
            System.out.println("❌ Error obteniendo perfil: " + e.getMessage());
            e.printStackTrace();
            return ResponseEntity.status(500).body(Map.of("error", "Error interno del servidor"));
        }
    }
    
    // Endpoint de login con encriptación AES
    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody Map<String, String> credentials) {
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
    
    @GetMapping("/test")
    public ResponseEntity<String> test() {
        return ResponseEntity.ok("Auth endpoint funcionando correctamente con is_usuarios!");
    }
}