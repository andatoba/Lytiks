package com.lytiks.backend.repository;

import com.lytiks.backend.entity.MokoAuditPhoto;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface MokoAuditPhotoRepository extends JpaRepository<MokoAuditPhoto, Long> {
    // Buscar fotos por auditoría Moko
    List<MokoAuditPhoto> findByMokoAuditId(Long mokoAuditId);

    // Buscar fotos por categoría
    List<MokoAuditPhoto> findByCategoriaContainingIgnoreCase(String categoria);

    // Buscar fotos por auditoría y categoría
    List<MokoAuditPhoto> findByMokoAuditIdAndCategoriaContainingIgnoreCase(Long mokoAuditId, String categoria);

    // Contar fotos por auditoría
    long countByMokoAuditId(Long mokoAuditId);

    // Contar fotos por categoría
    long countByCategoria(String categoria);

    // Obtener tamaño total de archivos por auditoría
    @Query("SELECT SUM(p.fileSize) FROM MokoAuditPhoto p WHERE p.mokoAudit.id = :mokoAuditId")
    Long getTotalFileSizeByMokoAudit(@Param("mokoAuditId") Long mokoAuditId);
}
