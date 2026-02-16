package com.lytiks.backend.repository;

import com.lytiks.backend.entity.ConfiguracionLogo;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface ConfiguracionLogoRepository extends JpaRepository<ConfiguracionLogo, Long> {
    
    // Buscar logo activo global (sin empresa específica)
    Optional<ConfiguracionLogo> findFirstByActivoTrue();
    
    // Buscar logo activo de una empresa específica
    Optional<ConfiguracionLogo> findFirstByIdEmpresaAndActivoTrue(Integer idEmpresa);
    
    // Buscar todos los logos de una empresa
    java.util.List<ConfiguracionLogo> findByIdEmpresaOrderByFechaCreacionDesc(Integer idEmpresa);
    
    Optional<ConfiguracionLogo> findByNombre(String nombre);
}
