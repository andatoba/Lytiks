package com.lytiks.backend.repository;

import com.lytiks.backend.entity.SeguimientoMoko;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface SeguimientoMokoRepository extends JpaRepository<SeguimientoMoko, Long> {

    // Encontrar todos los seguimientos de un foco específico
    List<SeguimientoMoko> findByFocoIdOrderByFechaSeguimientoDesc(Long focoId);

    // Encontrar seguimientos por número de foco
    List<SeguimientoMoko> findByNumeroFocoOrderByFechaSeguimientoDesc(Integer numeroFoco);

    // Obtener el último seguimiento de un foco
    @Query("SELECT s FROM SeguimientoMoko s WHERE s.focoId = :focoId ORDER BY s.fechaSeguimiento DESC")
    List<SeguimientoMoko> findLastSeguimientoByFocoId(@Param("focoId") Long focoId);

    // Contar seguimientos por foco
    @Query("SELECT COUNT(s) FROM SeguimientoMoko s WHERE s.focoId = :focoId")
    Long countSeguimientosByFocoId(@Param("focoId") Long focoId);

    // Buscar seguimientos por semana
    List<SeguimientoMoko> findBySemanaInicio(Integer semanaInicio);

    // Obtener seguimientos con pediluvio activo
    @Query("SELECT s FROM SeguimientoMoko s WHERE s.pediluvioActivo = true ORDER BY s.fechaSeguimiento DESC")
    List<SeguimientoMoko> findSeguimientosConPediluvioActivo();

    // Obtener seguimientos con cuarentena activa
    @Query("SELECT s FROM SeguimientoMoko s WHERE s.cuarentenaActiva = true ORDER BY s.fechaSeguimiento DESC")
    List<SeguimientoMoko> findSeguimientosConCuarentenaActiva();
}