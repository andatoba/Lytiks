package com.lytiks.backend.repository;

import com.lytiks.backend.entity.Audit;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface AuditRepository extends JpaRepository<Audit, Long> {
    
    // Buscar auditorías por técnico
    List<Audit> findByTecnicoId(Long tecnicoId);
    
    // Buscar auditorías por estado
    List<Audit> findByEstado(String estado);
    
    // Buscar auditorías por técnico y estado
    List<Audit> findByTecnicoIdAndEstado(Long tecnicoId, String estado);
    
    // Buscar auditorías por hacienda
    List<Audit> findByHaciendaContainingIgnoreCase(String hacienda);
    
    // Buscar auditorías por cultivo
    List<Audit> findByCultivoContainingIgnoreCase(String cultivo);
    
    // Buscar auditorías por rango de fechas
    List<Audit> findByFechaBetween(LocalDateTime fechaInicio, LocalDateTime fechaFin);
    
    // Buscar auditorías por técnico en un rango de fechas
    List<Audit> findByTecnicoIdAndFechaBetween(Long tecnicoId, LocalDateTime fechaInicio, LocalDateTime fechaFin);
    
    // Contar auditorías por técnico
    long countByTecnicoId(Long tecnicoId);
    
    // Contar auditorías por estado
    long countByEstado(String estado);
    
    // Contar auditorías de hoy para un técnico
    @Query("SELECT COUNT(a) FROM Audit a WHERE a.tecnicoId = :tecnicoId AND DATE(a.fecha) = CURRENT_DATE")
    long countTodayAuditsByTecnico(@Param("tecnicoId") Long tecnicoId);
    
    // Obtener auditorías recientes por técnico
    @Query("SELECT a FROM Audit a WHERE a.tecnicoId = :tecnicoId ORDER BY a.fecha DESC")
    List<Audit> findRecentAuditsByTecnico(@Param("tecnicoId") Long tecnicoId);
}