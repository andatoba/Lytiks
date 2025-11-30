package com.lytiks.backend.service;

import com.lytiks.backend.entity.RegistroMoko;
import com.lytiks.backend.repository.RegistroMokoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class RegistroMokoService {
    
    @Autowired
    private RegistroMokoRepository registroMokoRepository;
    
    public int getNextFocoNumber() {
        return registroMokoRepository.getNextFocoNumber();
    }
    
    public RegistroMoko save(RegistroMoko registro) {
        return registroMokoRepository.save(registro);
    }
    
    public List<RegistroMoko> getAllRegistros() {
        return registroMokoRepository.findByOrderByFechaCreacionDesc();
    }
    
    public Optional<RegistroMoko> getRegistroById(Long id) {
        return registroMokoRepository.findById(id);
    }
    
    public List<RegistroMoko> getRegistrosByClienteId(Long clienteId) {
        return registroMokoRepository.findByClienteIdOrderByFechaCreacionDesc(clienteId);
    }

    public List<RegistroMoko> getRegistrosByCedula(String cedula) {
        return registroMokoRepository.findByCedulaCliente(cedula);
    }
    
    public boolean deleteRegistro(Long id) {
        Optional<RegistroMoko> registro = registroMokoRepository.findById(id);
        if (registro.isPresent()) {
            registroMokoRepository.delete(registro.get());
            return true;
        }
        return false;
    }
    
    // Métodos adicionales para lista de focos
    
    public List<RegistroMoko> getRegistrosBySeveridad(String severidad) {
        return registroMokoRepository.findBySeveridadOrderByFechaCreacionDesc(severidad);
    }
    
    public List<RegistroMoko> buscarRegistros(String query) {
        return registroMokoRepository.buscarRegistros(query);
    }
    
    public List<RegistroMoko> getRegistrosByFechaRange(java.time.LocalDateTime inicio, java.time.LocalDateTime fin) {
        return registroMokoRepository.findByFechaDeteccionBetweenOrderByFechaDeteccionDesc(inicio, fin);
    }
    
    public Long contarTotalRegistros() {
        return registroMokoRepository.count();
    }
    
    public Long contarBySeveridad(String severidad) {
        return registroMokoRepository.countBySeveridad(severidad);
    }
    
    public Optional<RegistroMoko> getUltimoRegistro() {
        List<RegistroMoko> registros = registroMokoRepository.findByOrderByFechaCreacionDesc();
        return registros.isEmpty() ? Optional.empty() : Optional.of(registros.get(0));
    }
    
    public List<RegistroMoko> getRegistrosRecientes(int limite) {
        return registroMokoRepository.findTopNByOrderByFechaCreacionDesc(limite);
    }
    
    public List<RegistroMoko> getRegistrosConFotos() {
        return registroMokoRepository.findByFotoPathIsNotNullOrderByFechaCreacionDesc();
    }
}