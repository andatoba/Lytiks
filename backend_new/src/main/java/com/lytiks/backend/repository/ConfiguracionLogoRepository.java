package com.lytiks.backend.repository;

import com.lytiks.backend.entity.ConfiguracionLogo;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface ConfiguracionLogoRepository extends JpaRepository<ConfiguracionLogo, Long> {
    
    Optional<ConfiguracionLogo> findFirstByActivoTrue();
    
    Optional<ConfiguracionLogo> findByNombre(String nombre);
}
