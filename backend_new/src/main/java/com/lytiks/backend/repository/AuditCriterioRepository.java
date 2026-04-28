package com.lytiks.backend.repository;

import com.lytiks.backend.entity.AuditCriterio;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface AuditCriterioRepository extends JpaRepository<AuditCriterio, Long> {
    
    List<AuditCriterio> findByCategoriaIdAndActivoTrueOrderByOrdenAsc(Long categoriaId);
    
    List<AuditCriterio> findByCategoriaIdOrderByOrdenAsc(Long categoriaId);
}
