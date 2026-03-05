package com.lytiks.backend.service;

import com.lytiks.backend.entity.AuditCategoria;
import com.lytiks.backend.entity.AuditCriterio;
import com.lytiks.backend.repository.AuditCategoriaRepository;
import com.lytiks.backend.repository.AuditCriterioRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class AuditCategoriaService {
    
    @Autowired
    private AuditCategoriaRepository categoriaRepository;
    
    @Autowired
    private AuditCriterioRepository criterioRepository;
    
    /**
     * Obtiene todas las categorías activas ordenadas
     */
    @Transactional(readOnly = true)
    public List<AuditCategoria> getCategoriasActivas() {
        return categoriaRepository.findByActivoTrueOrderByOrdenAsc();
    }
    
    /**
     * Obtiene todas las categorías (activas e inactivas)
     */
    @Transactional(readOnly = true)
    public List<AuditCategoria> getAllCategorias() {
        return categoriaRepository.findAllByOrderByOrdenAsc();
    }
    
    /**
     * Obtiene una categoría por su código
     */
    @Transactional(readOnly = true)
    public Optional<AuditCategoria> getCategoriaByCodigo(String codigo) {
        return categoriaRepository.findByCodigo(codigo);
    }
    
    /**
     * Obtiene una categoría por ID
     */
    @Transactional(readOnly = true)
    public Optional<AuditCategoria> getCategoriaById(Long id) {
        return categoriaRepository.findById(id);
    }
    
    /**
     * Obtiene todos los criterios de una categoría
     */
    @Transactional(readOnly = true)
    public List<AuditCriterio> getCriteriosByCategoria(Long categoriaId) {
        return criterioRepository.findByCategoriaIdAndActivoTrueOrderByOrdenAsc(categoriaId);
    }
    
    /**
     * Obtiene todas las categorías con sus criterios
     */
    @Transactional(readOnly = true)
    public List<Map<String, Object>> getCategoriasConCriterios() {
        List<AuditCategoria> categorias = categoriaRepository.findByActivoTrueOrderByOrdenAsc();
        return categorias.stream().map(categoria -> {
            Map<String, Object> categoriaMap = new HashMap<>();
            categoriaMap.put("id", categoria.getId());
            categoriaMap.put("codigo", categoria.getCodigo());
            categoriaMap.put("nombre", categoria.getNombre());
            categoriaMap.put("descripcion", categoria.getDescripcion());
            categoriaMap.put("orden", categoria.getOrden());
            
            // Obtener criterios de esta categoría
            List<AuditCriterio> criterios = criterioRepository.findByCategoriaIdAndActivoTrueOrderByOrdenAsc(categoria.getId());
            List<Map<String, Object>> criteriosMap = criterios.stream().map(criterio -> {
                Map<String, Object> criterioMap = new HashMap<>();
                criterioMap.put("id", criterio.getId());
                criterioMap.put("nombre", criterio.getNombre());
                criterioMap.put("puntuacionMaxima", criterio.getPuntuacionMaxima());
                criterioMap.put("orden", criterio.getOrden());
                return criterioMap;
            }).collect(Collectors.toList());
            
            categoriaMap.put("criterios", criteriosMap);
            return categoriaMap;
        }).collect(Collectors.toList());
    }
    
    /**
     * Crea o actualiza una categoría
     */
    @Transactional
    public AuditCategoria guardarCategoria(AuditCategoria categoria) {
        return categoriaRepository.save(categoria);
    }
    
    /**
     * Crea o actualiza un criterio
     */
    @Transactional
    public AuditCriterio guardarCriterio(AuditCriterio criterio) {
        return criterioRepository.save(criterio);
    }
    
    /**
     * Elimina una categoría
     */
    @Transactional
    public void eliminarCategoria(Long id) {
        categoriaRepository.deleteById(id);
    }
    
    /**
     * Elimina un criterio
     */
    @Transactional
    public void eliminarCriterio(Long id) {
        criterioRepository.deleteById(id);
    }
}
