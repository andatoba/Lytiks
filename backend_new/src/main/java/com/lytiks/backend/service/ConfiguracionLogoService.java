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
    
    // Logo activo global (sin empresa específica)
    public ConfiguracionLogo getLogoActivo() {
        return logoRepository.findFirstByActivoTrue()
            .orElse(null);
    }
    
    // Logo activo de una empresa específica
    public ConfiguracionLogo getLogoActivoByEmpresa(Integer idEmpresa) {
        if (idEmpresa == null) {
            return getLogoActivo();
        }
        return logoRepository.findFirstByIdEmpresaAndActivoTrue(idEmpresa)
            .orElse(null);
    }
    
    // Obtener todos los logos de una empresa
    public List<ConfiguracionLogo> getLogosByEmpresa(Integer idEmpresa) {
        return logoRepository.findByIdEmpresaOrderByFechaCreacionDesc(idEmpresa);
    }
    
    public List<ConfiguracionLogo> getAllLogos() {
        return logoRepository.findAll();
    }
    
    public Optional<ConfiguracionLogo> getLogoById(Long id) {
        return logoRepository.findById(id);
    }
    
    public ConfiguracionLogo createLogo(ConfiguracionLogo logo) {
        // Si el logo es activo, desactivar todos los demás de esa empresa
        if (logo.getActivo() != null && logo.getActivo()) {
            desactivarLogosPorEmpresa(logo.getIdEmpresa());
        }
        log.info("Creando configuración de logo: {} para empresa: {}", logo.getNombre(), logo.getIdEmpresa());
        return logoRepository.save(logo);
    }
    
    public ConfiguracionLogo updateLogo(Long id, ConfiguracionLogo logoDetails) {
        ConfiguracionLogo logo = logoRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Logo no encontrado con id: " + id));
        
        // Si se activa este logo, desactivar los demás de esa empresa
        if (logoDetails.getActivo() != null && logoDetails.getActivo()) {
            desactivarLogosPorEmpresa(logo.getIdEmpresa());
        }
        
        logo.setNombre(logoDetails.getNombre());
        logo.setRutaLogo(logoDetails.getRutaLogo());
        logo.setLogoBase64(logoDetails.getLogoBase64());
        logo.setTipoMime(logoDetails.getTipoMime());
        logo.setActivo(logoDetails.getActivo());
        logo.setDescripcion(logoDetails.getDescripcion());
        if (logoDetails.getIdEmpresa() != null) {
            logo.setIdEmpresa(logoDetails.getIdEmpresa());
        }
        
        log.info("Actualizando logo: {} de empresa: {}", logo.getId(), logo.getIdEmpresa());
        return logoRepository.save(logo);
    }
    
    public void activarLogo(Long id) {
        ConfiguracionLogo logo = logoRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Logo no encontrado con id: " + id));
        
        // Desactivar solo los logos de la misma empresa
        desactivarLogosPorEmpresa(logo.getIdEmpresa());
        
        logo.setActivo(true);
        logoRepository.save(logo);
        log.info("Logo {} activado para empresa {}", id, logo.getIdEmpresa());
    }
    
    private void desactivarTodosLosLogos() {
        List<ConfiguracionLogo> logos = logoRepository.findAll();
        logos.forEach(l -> l.setActivo(false));
        logoRepository.saveAll(logos);
    }
    
    // Desactivar solo los logos de una empresa específica
    private void desactivarLogosPorEmpresa(Integer idEmpresa) {
        if (idEmpresa == null) {
            desactivarTodosLosLogos();
            return;
        }
        List<ConfiguracionLogo> logos = logoRepository.findByIdEmpresaOrderByFechaCreacionDesc(idEmpresa);
        logos.forEach(l -> l.setActivo(false));
        logoRepository.saveAll(logos);
        log.info("Logos de empresa {} desactivados", idEmpresa);
    }
    
    public void deleteLogo(Long id) {
        logoRepository.deleteById(id);
        log.info("Logo {} eliminado", id);
    }
}
