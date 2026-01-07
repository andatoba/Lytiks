package com.lytiks.backend.repository;

import com.lytiks.backend.entity.SeguimientoAplicacion;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface SeguimientoAplicacionRepository extends JpaRepository<SeguimientoAplicacion, Long> {

    List<SeguimientoAplicacion> findByAplicacionIdOrderByNumeroAplicacionAsc(Long aplicacionId);

    List<SeguimientoAplicacion> findByEstado(String estado);

    @Query("SELECT s FROM SeguimientoAplicacion s WHERE s.aplicacionId = :aplicacionId AND s.estado = :estado")
    List<SeguimientoAplicacion> findByAplicacionIdAndEstado(@Param("aplicacionId") Long aplicacionId, @Param("estado") String estado);

    @Query("SELECT s FROM SeguimientoAplicacion s WHERE s.fechaProgramada BETWEEN :fechaInicio AND :fechaFin")
    List<SeguimientoAplicacion> findByFechaProgramadaBetween(@Param("fechaInicio") LocalDateTime fechaInicio, @Param("fechaFin") LocalDateTime fechaFin);

    @Query("SELECT COUNT(s) FROM SeguimientoAplicacion s WHERE s.aplicacionId = :aplicacionId AND s.estado = 'completada'")
    Long countCompletadasByAplicacionId(@Param("aplicacionId") Long aplicacionId);

    @Query("SELECT COUNT(s) FROM SeguimientoAplicacion s WHERE s.aplicacionId = :aplicacionId")
    Long countTotalByAplicacionId(@Param("aplicacionId") Long aplicacionId);
}