package com.lytiks.backend.repository;

import com.lytiks.backend.entity.ConfiguracionAplicacion;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ConfiguracionAplicacionRepository extends JpaRepository<ConfiguracionAplicacion, Long> {

    List<ConfiguracionAplicacion> findByFocoIdOrderByFechaProgramadaAsc(Long focoId);

    List<ConfiguracionAplicacion> findByFocoIdAndFaseIdOrderByFechaProgramadaAsc(Long focoId, Long faseId);

    List<ConfiguracionAplicacion> findByFocoIdAndCompletadoOrderByFechaProgramadaAsc(Long focoId, Boolean completado);

    Optional<ConfiguracionAplicacion> findByFocoIdAndFaseIdAndTareaId(Long focoId, Long faseId, Long tareaId);

    @Query("SELECT c FROM ConfiguracionAplicacion c WHERE c.focoId = :focoId AND c.faseId = :faseId AND c.completado = :completado ORDER BY c.fechaProgramada ASC")
    List<ConfiguracionAplicacion> findPendientesByFocoAndFase(
        @Param("focoId") Long focoId,
        @Param("faseId") Long faseId,
        @Param("completado") Boolean completado
    );

    @Query("SELECT COUNT(c) FROM ConfiguracionAplicacion c WHERE c.focoId = :focoId AND c.completado = false")
    Long countPendientesByFoco(@Param("focoId") Long focoId);
}
