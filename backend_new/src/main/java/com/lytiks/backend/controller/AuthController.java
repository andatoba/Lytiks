package com.lytiks.backend.controller;

import com.lytiks.backend.entity.User;
import com.lytiks.backend.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/auth")
@CrossOrigin(origins = "*")
public class AuthController {
    
    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    private PasswordEncoder passwordEncoder;
    
    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody Map<String, String> loginRequest) {
        String username = loginRequest.get("username");
        String password = loginRequest.get("password");
        
        Optional<User> userOpt = userRepository.findByUsername(username);
        
        if (userOpt.isEmpty()) {
            return ResponseEntity.status(401).body(Map.of("error", "Usuario no encontrado"));
        }
        
        User user = userOpt.get();
        
        if (!passwordEncoder.matches(password, user.getPassword())) {
            return ResponseEntity.status(401).body(Map.of("error", "Contraseña incorrecta"));
        }
        
        if (!user.getActive()) {
            return ResponseEntity.status(401).body(Map.of("error", "Usuario inactivo"));
        }
        
        // Simular token JWT por simplicidad
        String fakeToken = "fake-jwt-token-" + System.currentTimeMillis();
        
        return ResponseEntity.ok(Map.of(
            "token", fakeToken,
            "id", user.getId(),
            "username", user.getUsername(),
            "firstName", user.getFirstName(),
            "lastName", user.getLastName(),
            "role", user.getRole().toString()
        ));
    }
    
    @GetMapping("/test")
    public ResponseEntity<String> test() {
        return ResponseEntity.ok("Auth endpoint funcionando correctamente!");
    }
}