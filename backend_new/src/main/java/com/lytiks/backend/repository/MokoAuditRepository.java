package com.lytiks.backend.repository;

import com.lytiks.backend.entity.MokoAudit;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface MokoAuditRepository extends JpaRepository<MokoAudit, Long> {
    
    // Buscar auditorías de Moko por técnico
    List<MokoAudit> findByTecnicoId(Long tecnicoId);
    
    // Buscar auditorías de Moko por estado
    List<MokoAudit> findByEstado(String estado);
    
    // Buscar auditorías de Moko por técnico y estado
    List<MokoAudit> findByTecnicoIdAndEstado(Long tecnicoId, String estado);
    
    // Buscar auditorías de Moko por hacienda
    List<MokoAudit> findByHaciendaContainingIgnoreCase(String hacienda);
    
    // Buscar auditorías de Moko por lote
    List<MokoAudit> findByLoteContainingIgnoreCase(String lote);
    
    // Buscar auditorías de Moko por rango de fechas
    List<MokoAudit> findByFechaBetween(LocalDateTime fechaInicio, LocalDateTime fechaFin);
    
    // Buscar auditorías de Moko por técnico en un rango de fechas
    List<MokoAudit> findByTecnicoIdAndFechaBetween(Long tecnicoId, LocalDateTime fechaInicio, LocalDateTime fechaFin);
    
    // Contar auditorías de Moko por técnico
    long countByTecnicoId(Long tecnicoId);
    
    // Contar auditorías de Moko por estado
    long countByEstado(String estado);
    
    // Contar auditorías de Moko de hoy para un técnico
    @Query("SELECT COUNT(m) FROM MokoAudit m WHERE m.tecnicoId = :tecnicoId AND DATE(m.fecha) = CURRENT_DATE")
    long countTodayMokoAuditsByTecnico(@Param("tecnicoId") Long tecnicoId);
    
    // Obtener auditorías de Moko recientes por técnico
    @Query("SELECT m FROM MokoAudit m WHERE m.tecnicoId = :tecnicoId ORDER BY m.fecha DESC")
    List<MokoAudit> findRecentMokoAuditsByTecnico(@Param("tecnicoId") Long tecnicoId);
    
    // Obtener promedio de cumplimiento general por técnico
    @Query("SELECT AVG(m.cumplimientoGeneral) FROM MokoAudit m WHERE m.tecnicoId = :tecnicoId")
    Double getAverageCumplimientoByTecnico(@Param("tecnicoId") Long tecnicoId);
    
    // Buscar auditorías con cumplimiento bajo (menos de cierto porcentaje)
    @Query("SELECT m FROM MokoAudit m WHERE m.cumplimientoGeneral < :threshold")
    List<MokoAudit> findLowCumplimientoAudits(@Param("threshold") Double threshold);
}