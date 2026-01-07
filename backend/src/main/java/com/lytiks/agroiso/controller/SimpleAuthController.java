package com.lytiks.agroiso.controller;

import org.springframework.web.bind.annotation.*;
import org.springframework.http.ResponseEntity;
import java.util.Map;

@RestController
@RequestMapping("/auth")
@CrossOrigin(origins = "*")
public class SimpleAuthController {
    
    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody Map<String, String> loginRequest) {
        String username = loginRequest.get("username");
        String password = loginRequest.get("password");
        
        // Autenticación simple para testing
        if ("admin".equals(username) && "admin123".equals(password)) {
            return ResponseEntity.ok(Map.of(
                "token", "fake-jwt-token-123456",
                "id", 1,
                "username", "admin",
                "firstName", "Administrator",
                "lastName", "System",
                "role", "ADMIN"
            ));
        } else if ("tecnico".equals(username) && "tecnico123".equals(password)) {
            return ResponseEntity.ok(Map.of(
                "token", "fake-jwt-token-789012",
                "id", 2,
                "username", "tecnico",
                "firstName", "Tecnico",
                "lastName", "User",
                "role", "TECHNICIAN"
            ));
        } else {
            return ResponseEntity.status(401).body(Map.of("error", "Usuario o contraseña incorrectos"));
        }
    }
    
    @GetMapping("/test")
    public ResponseEntity<String> test() {
        return ResponseEntity.ok("Simple Auth Controller funcionando correctamente!");
    }
}