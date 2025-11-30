package com.lytiks.backend.repository;

import com.lytiks.backend.entity.SigatokaAudit;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface SigatokaAuditRepository extends JpaRepository<SigatokaAudit, Long> {
        @Query("SELECT sa FROM SigatokaAudit sa JOIN Client c ON sa.clienteId = c.id WHERE c.cedula = :cedula ORDER BY sa.fecha DESC")
        List<SigatokaAudit> findByCedulaCliente(String cedula);
    
    List<SigatokaAudit> findByTecnicoId(Long tecnicoId);
    
    List<SigatokaAudit> findByHacienda(String hacienda);
    
    List<SigatokaAudit> findByEstado(String estado);
    
    List<SigatokaAudit> findByTecnicoIdAndEstado(Long tecnicoId, String estado);
    
    @Query("SELECT sa FROM SigatokaAudit sa WHERE sa.fecha BETWEEN :startDate AND :endDate")
    List<SigatokaAudit> findByFechaBetween(@Param("startDate") LocalDateTime startDate, @Param("endDate") LocalDateTime endDate);
    
    @Query("SELECT sa FROM SigatokaAudit sa WHERE sa.tecnicoId = :tecnicoId AND sa.fecha BETWEEN :startDate AND :endDate")
    List<SigatokaAudit> findByTecnicoIdAndFechaBetween(@Param("tecnicoId") Long tecnicoId, @Param("startDate") LocalDateTime startDate, @Param("endDate") LocalDateTime endDate);
    
    List<SigatokaAudit> findByNivelAnalisis(String nivelAnalisis);
    
    List<SigatokaAudit> findByTipoCultivo(String tipoCultivo);
}