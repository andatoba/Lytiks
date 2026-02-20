package com.lytiks.backend.repository;

import com.lytiks.backend.entity.ItemsTareasMoko;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ItemsTareasMokoRepository extends JpaRepository<ItemsTareasMoko, Long> {
    
    List<ItemsTareasMoko> findByPlanSeguimientoIdAndActivoTrueOrderByOrdenAsc(Long planId);
    
    @Query("SELECT i FROM ItemsTareasMoko i LEFT JOIN FETCH i.producto WHERE i.planSeguimiento.id = :planId AND i.activo = true ORDER BY i.orden ASC")
    List<ItemsTareasMoko> findByPlanIdWithProducto(@Param("planId") Long planId);
    
    List<ItemsTareasMoko> findByActivoTrueOrderByOrdenAsc();
}
