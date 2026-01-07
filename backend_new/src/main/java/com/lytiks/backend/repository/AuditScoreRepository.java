package com.lytiks.backend.repository;

import com.lytiks.backend.entity.AuditScore;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface AuditScoreRepository extends JpaRepository<AuditScore, Long> {
    
    // Buscar puntuaciones por auditoría
    List<AuditScore> findByAuditId(Long auditId);
    
    // Buscar puntuaciones por categoría
    List<AuditScore> findByCategoriaContainingIgnoreCase(String categoria);
    
    // Buscar puntuaciones por auditoría y categoría
    List<AuditScore> findByAuditIdAndCategoriaContainingIgnoreCase(Long auditId, String categoria);
    
    // Calcular promedio de puntuaciones por auditoría
    @Query("SELECT AVG(s.puntuacion) FROM AuditScore s WHERE s.audit.id = :auditId")
    Double getAverageScoreByAudit(@Param("auditId") Long auditId);
    
    // Obtener puntuaciones bajas (menos de cierto umbral)
    @Query("SELECT s FROM AuditScore s WHERE s.puntuacion < :threshold")
    List<AuditScore> findLowScores(@Param("threshold") Integer threshold);
    
    // Contar puntuaciones por categoría
    long countByCategoria(String categoria);
}