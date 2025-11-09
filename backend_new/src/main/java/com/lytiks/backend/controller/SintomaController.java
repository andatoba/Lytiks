package com.lytiks.backend.controller;

import com.lytiks.backend.entity.Sintoma;
import com.lytiks.backend.repository.SintomaRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/sintomas")
@CrossOrigin(origins = "*")
public class SintomaController {

    @Autowired
    private SintomaRepository sintomaRepository;

    // Obtener todos los síntomas
    @GetMapping("/all")
    public ResponseEntity<Map<String, Object>> getAllSintomas() {
        Map<String, Object> response = new HashMap<>();
        try {
            List<Sintoma> sintomas = sintomaRepository.findAll();
            response.put("success", true);
            response.put("data", sintomas);
            response.put("message", "Síntomas obtenidos exitosamente");
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "Error al obtener síntomas: " + e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }

    // Obtener síntomas por categoría
    @GetMapping("/categoria/{categoria}")
    public ResponseEntity<Map<String, Object>> getSintomasByCategoria(@PathVariable String categoria) {
        Map<String, Object> response = new HashMap<>();
        try {
            List<Sintoma> sintomas = sintomaRepository.findByCategoria(categoria);
            response.put("success", true);
            response.put("data", sintomas);
            response.put("message", "Síntomas de categoría '" + categoria + "' obtenidos exitosamente");
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "Error al obtener síntomas por categoría: " + e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }

    // Obtener síntomas por severidad
    @GetMapping("/severidad/{severidad}")
    public ResponseEntity<Map<String, Object>> getSintomasBySeveridad(@PathVariable String severidad) {
        Map<String, Object> response = new HashMap<>();
        try {
            List<Sintoma> sintomas = sintomaRepository.findBySeveridad(severidad);
            response.put("success", true);
            response.put("data", sintomas);
            response.put("message", "Síntomas de severidad '" + severidad + "' obtenidos exitosamente");
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "Error al obtener síntomas por severidad: " + e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }

    // Obtener un síntoma por ID
    @GetMapping("/{id}")
    public ResponseEntity<Map<String, Object>> getSintomaById(@PathVariable Long id) {
        Map<String, Object> response = new HashMap<>();
        try {
            Optional<Sintoma> sintoma = sintomaRepository.findById(id);
            if (sintoma.isPresent()) {
                response.put("success", true);
                response.put("data", sintoma.get());
                response.put("message", "Síntoma encontrado");
                return ResponseEntity.ok(response);
            } else {
                response.put("success", false);
                response.put("message", "Síntoma no encontrado");
                return ResponseEntity.notFound().build();
            }
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "Error al obtener síntoma: " + e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }

    // Obtener categorías únicas
    @GetMapping("/categorias")
    public ResponseEntity<Map<String, Object>> getCategorias() {
        Map<String, Object> response = new HashMap<>();
        try {
            List<String> categorias = sintomaRepository.findDistinctCategorias();
            response.put("success", true);
            response.put("data", categorias);
            response.put("message", "Categorías obtenidas exitosamente");
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "Error al obtener categorías: " + e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }

    // Buscar síntomas por texto
    @GetMapping("/buscar")
    public ResponseEntity<Map<String, Object>> buscarSintomas(@RequestParam String query) {
        Map<String, Object> response = new HashMap<>();
        try {
            List<Sintoma> sintomas = sintomaRepository.findBySintomaObservableContainingIgnoreCase(query);
            response.put("success", true);
            response.put("data", sintomas);
            response.put("message", "Búsqueda completada");
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "Error en búsqueda: " + e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }
}