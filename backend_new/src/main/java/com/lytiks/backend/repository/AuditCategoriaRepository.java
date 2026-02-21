package com.lytiks.backend.repository;

import com.lytiks.backend.entity.AuditCategoria;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface AuditCategoriaRepository extends JpaRepository<AuditCategoria, Long> {
    
    List<AuditCategoria> findByActivoTrueOrderByOrdenAsc();
    
    Optional<AuditCategoria> findByCodigo(String codigo);
    
    List<AuditCategoria> findAllByOrderByOrdenAsc();
}
