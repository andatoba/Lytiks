package com.lytiks.backend.controller;

import com.lytiks.backend.dto.PlagasResumenDTO;
import com.lytiks.backend.entity.PlagasResumenAuditoria;
import com.lytiks.backend.service.PlagasResumenService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/plagas")
public class PlagasResumenController {

    @Autowired
    private PlagasResumenService plagasResumenService;

    @PostMapping("/guardar-resumen")
    public ResponseEntity<Map<String, Object>> guardarResumen(@RequestBody PlagasResumenDTO dto) {
        Map<String, Object> result = plagasResumenService.guardarResumen(dto);
        if (Boolean.TRUE.equals(result.get("success"))) {
            return ResponseEntity.ok(result);
        }
        return ResponseEntity.badRequest().body(result);
    }

    @GetMapping("/cliente/{clientId}")
    public ResponseEntity<List<PlagasResumenAuditoria>> obtenerPorCliente(@PathVariable Long clientId) {
        return ResponseEntity.ok(plagasResumenService.obtenerPorCliente(clientId));
    }

    @GetMapping("/tecnico/{tecnicoId}")
    public ResponseEntity<List<PlagasResumenAuditoria>> obtenerPorTecnico(@PathVariable Long tecnicoId) {
        return ResponseEntity.ok(plagasResumenService.obtenerPorTecnico(tecnicoId));
    }

    @GetMapping("/all")
    public ResponseEntity<List<PlagasResumenAuditoria>> obtenerTodos() {
        return ResponseEntity.ok(plagasResumenService.obtenerTodos());
    }
}
