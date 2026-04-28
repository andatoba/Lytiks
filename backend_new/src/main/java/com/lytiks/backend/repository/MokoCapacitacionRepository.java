package com.lytiks.backend.repository;

import com.lytiks.backend.entity.MokoCapacitacion;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface MokoCapacitacionRepository extends JpaRepository<MokoCapacitacion, Long> {

    @Query("""
            SELECT c FROM MokoCapacitacion c
            WHERE c.clienteId = :clienteId
              AND (:hacienda IS NULL OR :hacienda = '' OR LOWER(COALESCE(c.hacienda, '')) = LOWER(:hacienda))
              AND (:lote IS NULL OR :lote = '' OR LOWER(c.lote) = LOWER(:lote))
            ORDER BY c.createdAt DESC
            """)
    List<MokoCapacitacion> findByClienteAndLote(
            @Param("clienteId") Long clienteId,
            @Param("hacienda") String hacienda,
            @Param("lote") String lote
    );

    @Query("""
            SELECT COUNT(c) FROM MokoCapacitacion c
            WHERE c.clienteId = :clienteId
              AND (:hacienda IS NULL OR :hacienda = '' OR LOWER(COALESCE(c.hacienda, '')) = LOWER(:hacienda))
              AND (:lote IS NULL OR :lote = '' OR LOWER(c.lote) = LOWER(:lote))
            """)
    Long countByClienteAndLote(
            @Param("clienteId") Long clienteId,
            @Param("hacienda") String hacienda,
            @Param("lote") String lote
    );
}
