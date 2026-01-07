package com.lytiks.backend.service;

import com.lytiks.backend.entity.Sintoma;
import com.lytiks.backend.repository.SintomaRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class SintomaService {
    
    @Autowired
    private SintomaRepository sintomaRepository;
    
    public List<Sintoma> getAllSintomas() {
        return sintomaRepository.findAll();
    }
    
    public Optional<Sintoma> getSintomaById(Long id) {
        return sintomaRepository.findById(id);
    }
    
    public List<Sintoma> getSintomasByCategoria(String categoria) {
        return sintomaRepository.findByCategoria(categoria);
    }
    
    public List<Sintoma> getSintomasBySeveridad(String severidad) {
        return sintomaRepository.findBySeveridad(severidad);
    }
    
    public Sintoma save(Sintoma sintoma) {
        return sintomaRepository.save(sintoma);
    }
}