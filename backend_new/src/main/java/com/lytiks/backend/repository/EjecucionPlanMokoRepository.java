package com.lytiks.backend.repository;

import com.lytiks.backend.entity.EjecucionPlanMoko;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface EjecucionPlanMokoRepository extends JpaRepository<EjecucionPlanMoko, Long> {
    
    List<EjecucionPlanMoko> findByFocoIdOrderByPlanSeguimientoOrdenAsc(Long focoId);
    
    @Query("SELECT e FROM EjecucionPlanMoko e LEFT JOIN FETCH e.planSeguimiento p LEFT JOIN FETCH e.tareasEjecutadas WHERE e.focoId = :focoId ORDER BY p.orden ASC")
    List<EjecucionPlanMoko> findByFocoIdWithDetails(@Param("focoId") Long focoId);
    
    Optional<EjecucionPlanMoko> findByFocoIdAndPlanSeguimientoId(Long focoId, Long planId);
    
    @Query("SELECT COUNT(e) FROM EjecucionPlanMoko e WHERE e.focoId = :focoId AND e.completado = true")
    Long countCompletadosByFocoId(@Param("focoId") Long focoId);
    
    @Query("SELECT e FROM EjecucionPlanMoko e WHERE e.focoId = :focoId AND e.completado = false ORDER BY e.planSeguimiento.orden ASC")
    List<EjecucionPlanMoko> findPendientesByFocoId(@Param("focoId") Long focoId);
}
