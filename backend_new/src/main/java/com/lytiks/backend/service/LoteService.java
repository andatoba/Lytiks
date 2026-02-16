package com.lytiks.backend.service;

import com.lytiks.backend.entity.Lote;
import com.lytiks.backend.repository.LoteRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Service
@Slf4j
@Transactional
public class LoteService {
    
    @Autowired
    private LoteRepository loteRepository;
    
    public List<Lote> getAllLotes() {
        return loteRepository.findAll();
    }
    
    public Optional<Lote> getLoteById(Long id) {
        return loteRepository.findById(id);
    }
    
    public List<Lote> getLotesByHacienda(Long haciendaId) {
        return loteRepository.findByHaciendaIdAndEstado(haciendaId, "ACTIVO");
    }
    
    public List<Lote> getLotesActivos() {
        return loteRepository.findByEstado("ACTIVO");
    }
    
    public Lote createLote(Lote lote) {
        if (lote.getEstado() == null) {
            lote.setEstado("ACTIVO");
        }
        log.info("Creando lote: {}", lote.getNombre());
        return loteRepository.save(lote);
    }
    
    public Lote updateLote(Long id, Lote loteDetails) {
        Lote lote = loteRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Lote no encontrado con id: " + id));
        
        lote.setNombre(loteDetails.getNombre());
        lote.setCodigo(loteDetails.getCodigo());
        lote.setDetalle(loteDetails.getDetalle());
        lote.setHectareas(loteDetails.getHectareas());
        lote.setVariedad(loteDetails.getVariedad());
        lote.setEdad(loteDetails.getEdad());
        lote.setEstado(loteDetails.getEstado());
        lote.setUsuarioActualizacion(loteDetails.getUsuarioActualizacion());
        
        log.info("Actualizando lote: {}", lote.getId());
        return loteRepository.save(lote);
    }
    
    public void deleteLote(Long id) {
        Lote lote = loteRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Lote no encontrado con id: " + id));
        lote.setEstado("INACTIVO");
        loteRepository.save(lote);
        log.info("Lote {} marcado como inactivo", id);
    }
    
    public List<Lote> searchLotes(String nombre) {
        return loteRepository.findByNombreContainingIgnoreCaseAndEstado(nombre, "ACTIVO");
    }
    
    public List<Lote> searchLotesByCodigo(String codigo) {
        return loteRepository.findByCodigoContainingIgnoreCase(codigo);
    }
}
