package com.lytiks.backend.repository;

import com.lytiks.backend.entity.PlanSeguimientoMoko;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface PlanSeguimientoMokoRepository extends JpaRepository<PlanSeguimientoMoko, Long> {
    
    List<PlanSeguimientoMoko> findByActivoTrueOrderByOrdenAsc();
    
    @Query("SELECT p FROM PlanSeguimientoMoko p LEFT JOIN FETCH p.tareas t WHERE p.activo = true ORDER BY p.orden ASC, t.orden ASC")
    List<PlanSeguimientoMoko> findAllWithTareas();
}
