package com.lytiks.backend.repository;

import com.lytiks.backend.entity.EjecucionTareasMoko;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface EjecucionTareasMokoRepository extends JpaRepository<EjecucionTareasMoko, Long> {
    
    List<EjecucionTareasMoko> findByEjecucionPlanIdOrderByItemTareaOrdenAsc(Long ejecucionPlanId);
    
    @Query("SELECT e FROM EjecucionTareasMoko e LEFT JOIN FETCH e.itemTarea WHERE e.ejecucionPlan.id = :ejecucionPlanId ORDER BY e.itemTarea.orden ASC")
    List<EjecucionTareasMoko> findByEjecucionPlanIdWithTarea(@Param("ejecucionPlanId") Long ejecucionPlanId);
    
    Optional<EjecucionTareasMoko> findByEjecucionPlanIdAndItemTareaId(Long ejecucionPlanId, Long itemTareaId);
    
    @Query("SELECT COUNT(e) FROM EjecucionTareasMoko e WHERE e.ejecucionPlan.id = :ejecucionPlanId AND e.completado = true")
    Long countCompletadasByEjecucionPlanId(@Param("ejecucionPlanId") Long ejecucionPlanId);
    
    @Query("SELECT COUNT(e) FROM EjecucionTareasMoko e WHERE e.ejecucionPlan.id = :ejecucionPlanId")
    Long countTotalByEjecucionPlanId(@Param("ejecucionPlanId") Long ejecucionPlanId);
}
