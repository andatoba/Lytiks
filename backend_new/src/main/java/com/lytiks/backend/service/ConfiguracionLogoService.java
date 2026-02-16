package com.lytiks.backend.service;

import com.lytiks.backend.entity.ConfiguracionLogo;
import com.lytiks.backend.repository.ConfiguracionLogoRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Service
@Slf4j
@Transactional
public class ConfiguracionLogoService {
    
    @Autowired
    private ConfiguracionLogoRepository logoRepository;
    
    public ConfiguracionLogo getLogoActivo() {
        return logoRepository.findFirstByActivoTrue()
            .orElse(null);
    }
    
    public List<ConfiguracionLogo> getAllLogos() {
        return logoRepository.findAll();
    }
    
    public Optional<ConfiguracionLogo> getLogoById(Long id) {
        return logoRepository.findById(id);
    }
    
    public ConfiguracionLogo createLogo(ConfiguracionLogo logo) {
        // Si el logo es activo, desactivar todos los demás
        if (logo.getActivo() != null && logo.getActivo()) {
            desactivarTodosLosLogos();
        }
        log.info("Creando configuración de logo: {}", logo.getNombre());
        return logoRepository.save(logo);
    }
    
    public ConfiguracionLogo updateLogo(Long id, ConfiguracionLogo logoDetails) {
        ConfiguracionLogo logo = logoRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Logo no encontrado con id: " + id));
        
        // Si se activa este logo, desactivar los demás
        if (logoDetails.getActivo() != null && logoDetails.getActivo()) {
            desactivarTodosLosLogos();
        }
        
        logo.setNombre(logoDetails.getNombre());
        logo.setRutaLogo(logoDetails.getRutaLogo());
        logo.setLogoBase64(logoDetails.getLogoBase64());
        logo.setTipoMime(logoDetails.getTipoMime());
        logo.setActivo(logoDetails.getActivo());
        logo.setDescripcion(logoDetails.getDescripcion());
        
        log.info("Actualizando logo: {}", logo.getId());
        return logoRepository.save(logo);
    }
    
    public void activarLogo(Long id) {
        desactivarTodosLosLogos();
        ConfiguracionLogo logo = logoRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Logo no encontrado con id: " + id));
        logo.setActivo(true);
        logoRepository.save(logo);
        log.info("Logo {} activado", id);
    }
    
    private void desactivarTodosLosLogos() {
        List<ConfiguracionLogo> logos = logoRepository.findAll();
        logos.forEach(l -> l.setActivo(false));
        logoRepository.saveAll(logos);
    }
    
    public void deleteLogo(Long id) {
        logoRepository.deleteById(id);
        log.info("Logo {} eliminado", id);
    }
}
