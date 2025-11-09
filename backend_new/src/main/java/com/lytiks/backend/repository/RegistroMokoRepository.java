package com.lytiks.backend.repository;

import com.lytiks.backend.entity.RegistroMoko;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface RegistroMokoRepository extends JpaRepository<RegistroMoko, Long> {
    
    @Query("SELECT COALESCE(MAX(r.numeroFoco), 0) + 1 FROM RegistroMoko r")
    Integer getNextFocoNumber();
    
    List<RegistroMoko> findByClienteIdOrderByFechaCreacionDesc(Long clienteId);
    
    List<RegistroMoko> findByOrderByFechaCreacionDesc();
    
    // Métodos adicionales para lista de focos
    
    List<RegistroMoko> findBySeveridadOrderByFechaCreacionDesc(String severidad);
    
    @Query("SELECT r FROM RegistroMoko r WHERE " +
           "CAST(r.numeroFoco AS string) LIKE CONCAT('%', :query, '%') OR " +
           "LOWER(r.severidad) LIKE LOWER(CONCAT('%', :query, '%')) OR " +
           "LOWER(r.metodoComprobacion) LIKE LOWER(CONCAT('%', :query, '%')) OR " +
           "LOWER(r.observaciones) LIKE LOWER(CONCAT('%', :query, '%')) " +
           "ORDER BY r.fechaCreacion DESC")
    List<RegistroMoko> buscarRegistros(String query);
    
    List<RegistroMoko> findByFechaDeteccionBetweenOrderByFechaDeteccionDesc(
        java.time.LocalDateTime inicio, java.time.LocalDateTime fin);
    
    Long countBySeveridad(String severidad);
    
    @Query(value = "SELECT * FROM registro_moko ORDER BY fecha_creacion DESC LIMIT ?1", nativeQuery = true)
    List<RegistroMoko> findTopNByOrderByFechaCreacionDesc(int limite);
    
    List<RegistroMoko> findByFotoPathIsNotNullOrderByFechaCreacionDesc();
    
    @Query("SELECT COUNT(r) FROM RegistroMoko r WHERE DATE(r.fechaDeteccion) = CURRENT_DATE")
    Long countRegistrosHoy();
    
    @Query("SELECT COUNT(r) FROM RegistroMoko r WHERE WEEK(r.fechaDeteccion) = WEEK(CURRENT_DATE)")
    Long countRegistrosEstaSemana();
    
    @Query("SELECT COUNT(r) FROM RegistroMoko r WHERE MONTH(r.fechaDeteccion) = MONTH(CURRENT_DATE)")
    Long countRegistrosEsteMes();
}