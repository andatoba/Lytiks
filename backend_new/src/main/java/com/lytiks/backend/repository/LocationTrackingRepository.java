package com.lytiks.backend.repository;

import com.lytiks.backend.entity.LocationTracking;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface LocationTrackingRepository extends JpaRepository<LocationTracking, Long> {
    
    // Buscar por usuario
    List<LocationTracking> findByUserIdOrderByTimestampDesc(String userId);
    
    // Buscar por usuario en un rango de fechas
    List<LocationTracking> findByUserIdAndTimestampBetweenOrderByTimestampDesc(
        String userId, LocalDateTime start, LocalDateTime end
    );
    
    // Buscar todos los registros de un día específico
    @Query("SELECT lt FROM LocationTracking lt WHERE DATE(lt.timestamp) = DATE(:date) ORDER BY lt.timestamp DESC")
    List<LocationTracking> findByDate(@Param("date") LocalDateTime date);
    
    // Obtener los últimos N registros de un usuario
    @Query("SELECT lt FROM LocationTracking lt WHERE lt.userId = :userId ORDER BY lt.timestamp DESC")
    List<LocationTracking> findTopNByUserId(@Param("userId") String userId);
    
    // Buscar todos los registros de hoy
    @Query("SELECT lt FROM LocationTracking lt WHERE DATE(lt.timestamp) = CURRENT_DATE ORDER BY lt.timestamp DESC")
    List<LocationTracking> findTodayLocations();
    
    // Buscar registros entre horas específicas (para el rango 8AM-4PM)
    @Query("SELECT lt FROM LocationTracking lt WHERE lt.userId = :userId " +
           "AND HOUR(lt.timestamp) >= :startHour AND HOUR(lt.timestamp) < :endHour " +
           "ORDER BY lt.timestamp DESC")
    List<LocationTracking> findByUserIdAndHourRange(
        @Param("userId") String userId, 
        @Param("startHour") int startHour, 
        @Param("endHour") int endHour
    );
}
