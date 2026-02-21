package com.lytiks.backend.controller;

import com.lytiks.backend.entity.AuditCategoria;
import com.lytiks.backend.entity.AuditCriterio;
import com.lytiks.backend.service.AuditCategoriaService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/audit-categorias")
@CrossOrigin(origins = "*")
public class AuditCategoriaController {
    
    @Autowired
    private AuditCategoriaService categoriaService;
    
    /**
     * GET /api/audit-categorias
     * Obtiene todas las categorías activas
     */
    @GetMapping
    public ResponseEntity<List<AuditCategoria>> getCategoriasActivas() {
        List<AuditCategoria> categorias = categoriaService.getCategoriasActivas();
        return ResponseEntity.ok(categorias);
    }
    
    /**
     * GET /api/audit-categorias/all
     * Obtiene todas las categorías (activas e inactivas)
     */
    @GetMapping("/all")
    public ResponseEntity<List<AuditCategoria>> getAllCategorias() {
        List<AuditCategoria> categorias = categoriaService.getAllCategorias();
        return ResponseEntity.ok(categorias);
    }
    
    /**
     * GET /api/audit-categorias/con-criterios
     * Obtiene todas las categorías con sus criterios
     */
    @GetMapping("/con-criterios")
    public ResponseEntity<List<Map<String, Object>>> getCategoriasConCriterios() {
        List<Map<String, Object>> categorias = categoriaService.getCategoriasConCriterios();
        return ResponseEntity.ok(categorias);
    }
    
    /**
     * GET /api/audit-categorias/{id}
     * Obtiene una categoría por ID
     */
    @GetMapping("/{id}")
    public ResponseEntity<AuditCategoria> getCategoriaById(@PathVariable Long id) {
        return categoriaService.getCategoriaById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }
    
    /**
     * GET /api/audit-categorias/codigo/{codigo}
     * Obtiene una categoría por código
     */
    @GetMapping("/codigo/{codigo}")
    public ResponseEntity<AuditCategoria> getCategoriaByCodigo(@PathVariable String codigo) {
        return categoriaService.getCategoriaByCodigo(codigo)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }
    
    /**
     * GET /api/audit-categorias/{categoriaId}/criterios
     * Obtiene todos los criterios de una categoría
     */
    @GetMapping("/{categoriaId}/criterios")
    public ResponseEntity<List<AuditCriterio>> getCriteriosByCategoria(@PathVariable Long categoriaId) {
        List<AuditCriterio> criterios = categoriaService.getCriteriosByCategoria(categoriaId);
        return ResponseEntity.ok(criterios);
    }
    
    /**
     * POST /api/audit-categorias
     * Crea una nueva categoría
     */
    @PostMapping
    public ResponseEntity<Map<String, Object>> crearCategoria(@RequestBody AuditCategoria categoria) {
        Map<String, Object> response = new HashMap<>();
        try {
            AuditCategoria nuevaCategoria = categoriaService.guardarCategoria(categoria);
            response.put("success", true);
            response.put("message", "Categoría creada exitosamente");
            response.put("categoria", nuevaCategoria);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "Error al crear categoría: " + e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }
    
    /**
     * PUT /api/audit-categorias/{id}
     * Actualiza una categoría existente
     */
    @PutMapping("/{id}")
    public ResponseEntity<Map<String, Object>> actualizarCategoria(
            @PathVariable Long id, 
            @RequestBody AuditCategoria categoria) {
        Map<String, Object> response = new HashMap<>();
        try {
            if (!categoriaService.getCategoriaById(id).isPresent()) {
                response.put("success", false);
                response.put("message", "Categoría no encontrada");
                return ResponseEntity.notFound().build();
            }
            categoria.setId(id);
            AuditCategoria categoriaActualizada = categoriaService.guardarCategoria(categoria);
            response.put("success", true);
            response.put("message", "Categoría actualizada exitosamente");
            response.put("categoria", categoriaActualizada);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "Error al actualizar categoría: " + e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }
    
    /**
     * DELETE /api/audit-categorias/{id}
     * Elimina una categoría
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<Map<String, Object>> eliminarCategoria(@PathVariable Long id) {
        Map<String, Object> response = new HashMap<>();
        try {
            if (!categoriaService.getCategoriaById(id).isPresent()) {
                response.put("success", false);
                response.put("message", "Categoría no encontrada");
                return ResponseEntity.notFound().build();
            }
            categoriaService.eliminarCategoria(id);
            response.put("success", true);
            response.put("message", "Categoría eliminada exitosamente");
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "Error al eliminar categoría: " + e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }
}
