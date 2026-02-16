package com.lytiks.backend.service;

import com.lytiks.backend.entity.Hacienda;
import com.lytiks.backend.repository.HaciendaRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Service
@Slf4j
@Transactional
public class HaciendaService {
    
    @Autowired
    private HaciendaRepository haciendaRepository;
    
    public List<Hacienda> getAllHaciendas() {
        return haciendaRepository.findAll();
    }
    
    public Optional<Hacienda> getHaciendaById(Long id) {
        return haciendaRepository.findById(id);
    }
    
    public List<Hacienda> getHaciendasByCliente(Long clienteId) {
        return haciendaRepository.findByClienteIdAndEstado(clienteId, "ACTIVO");
    }
    
    public List<Hacienda> getHaciendasActivas() {
        return haciendaRepository.findByEstado("ACTIVO");
    }
    
    public Hacienda createHacienda(Hacienda hacienda) {
        if (hacienda.getEstado() == null) {
            hacienda.setEstado("ACTIVO");
        }
        log.info("Creando hacienda: {}", hacienda.getNombre());
        return haciendaRepository.save(hacienda);
    }
    
    public Hacienda updateHacienda(Long id, Hacienda haciendaDetails) {
        Hacienda hacienda = haciendaRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Hacienda no encontrada con id: " + id));
        
        hacienda.setNombre(haciendaDetails.getNombre());
        hacienda.setDetalle(haciendaDetails.getDetalle());
        hacienda.setUbicacion(haciendaDetails.getUbicacion());
        hacienda.setHectareas(haciendaDetails.getHectareas());
        hacienda.setEstado(haciendaDetails.getEstado());
        hacienda.setUsuarioActualizacion(haciendaDetails.getUsuarioActualizacion());
        
        log.info("Actualizando hacienda: {}", hacienda.getId());
        return haciendaRepository.save(hacienda);
    }
    
    public void deleteHacienda(Long id) {
        Hacienda hacienda = haciendaRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Hacienda no encontrada con id: " + id));
        hacienda.setEstado("INACTIVO");
        haciendaRepository.save(hacienda);
        log.info("Hacienda {} marcada como inactiva", id);
    }
    
    public List<Hacienda> searchHaciendas(String nombre) {
        return haciendaRepository.findByNombreContainingIgnoreCaseAndEstado(nombre, "ACTIVO");
    }
}
