package com.lytiks.backend.controller;

import com.lytiks.backend.entity.Aplicacion;
import com.lytiks.backend.repository.AplicacionRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;

@RestController
@RequestMapping("/moko")
@CrossOrigin(origins = "*")
public class AplicacionController {

    @Autowired
    private AplicacionRepository aplicacionRepository;

    @PostMapping("/aplicaciones")
    public ResponseEntity<Aplicacion> guardarAplicacion(@RequestBody Aplicacion aplicacion) {
        try {
            aplicacion.setCreatedAt(LocalDateTime.now());
            Aplicacion saved = aplicacionRepository.save(aplicacion);
            return ResponseEntity.status(HttpStatus.CREATED).body(saved);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(null);
        }
    }
}
