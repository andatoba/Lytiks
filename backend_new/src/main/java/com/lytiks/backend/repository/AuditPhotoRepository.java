package com.lytiks.backend.repository;

import com.lytiks.backend.entity.AuditPhoto;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface AuditPhotoRepository extends JpaRepository<AuditPhoto, Long> {
    
    // Buscar fotos por auditoría
    List<AuditPhoto> findByAuditId(Long auditId);
    
    // Buscar fotos por categoría
    List<AuditPhoto> findByCategoriaContainingIgnoreCase(String categoria);
    
    // Buscar fotos por auditoría y categoría
    List<AuditPhoto> findByAuditIdAndCategoriaContainingIgnoreCase(Long auditId, String categoria);
    
    // Contar fotos por auditoría
    long countByAuditId(Long auditId);
    
    // Contar fotos por categoría
    long countByCategoria(String categoria);
    
    // Obtener tamaño total de archivos por auditoría
    @Query("SELECT SUM(p.fileSize) FROM AuditPhoto p WHERE p.audit.id = :auditId")
    Long getTotalFileSizeByAudit(@Param("auditId") Long auditId);
}