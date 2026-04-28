package com.lytiks.backend.repository;

import com.lytiks.backend.entity.MokoMuestra;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface MokoMuestraRepository extends JpaRepository<MokoMuestra, Long> {

    @Query("""
            SELECT m FROM MokoMuestra m
            WHERE m.clienteId = :clienteId
              AND (:lote IS NULL OR :lote = '' OR LOWER(m.lote) = LOWER(:lote))
              AND (:tipo IS NULL OR :tipo = '' OR UPPER(m.tipoMuestra) = UPPER(:tipo))
              AND (
                   :query IS NULL OR :query = '' OR
                   LOWER(m.codigo) LIKE LOWER(CONCAT('%', :query, '%')) OR
                   LOWER(COALESCE(m.descripcion, '')) LIKE LOWER(CONCAT('%', :query, '%'))
              )
            ORDER BY m.createdAt DESC, m.muestraNumero ASC
            """)
    List<MokoMuestra> buscarPorCliente(
            @Param("clienteId") Long clienteId,
            @Param("lote") String lote,
            @Param("tipo") String tipo,
            @Param("query") String query
    );
}
