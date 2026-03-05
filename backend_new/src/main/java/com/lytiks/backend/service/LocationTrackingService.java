package com.lytiks.backend.service;

import com.lytiks.backend.dto.LocationTrackingDTO;
import com.lytiks.backend.entity.LocationTracking;
import com.lytiks.backend.repository.LocationTrackingRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

@Service
public class LocationTrackingService {
    
    @Autowired
    private LocationTrackingRepository locationTrackingRepository;
    
    /**
     * Guardar una nueva ubicación del técnico
     */
    @Transactional
    public LocationTracking saveLocation(LocationTrackingDTO dto) {
        LocationTracking location = new LocationTracking();
        location.setUserId(dto.getUserId());
        location.setUserName(dto.getUserName());
        location.setLatitude(dto.getLatitude());
        location.setLongitude(dto.getLongitude());
        location.setAccuracy(dto.getAccuracy());
        location.setMatrixLatitude(dto.getMatrixLatitude());
        location.setMatrixLongitude(dto.getMatrixLongitude());
        
        // Parsear timestamp desde ISO 8601
        if (dto.getTimestamp() != null && !dto.getTimestamp().isEmpty()) {
            location.setTimestamp(LocalDateTime.parse(dto.getTimestamp(), 
                DateTimeFormatter.ISO_DATE_TIME));
        } else {
            location.setTimestamp(LocalDateTime.now());
        }
        
        return locationTrackingRepository.save(location);
    }
    
    /**
     * Obtener todas las ubicaciones de un usuario
     */
    public List<LocationTracking> getLocationsByUserId(String userId) {
        return locationTrackingRepository.findByUserIdOrderByTimestampDesc(userId);
    }
    
    /**
     * Obtener ubicaciones de un usuario en un rango de fechas
     */
    public List<LocationTracking> getLocationsByUserIdAndDateRange(
            String userId, LocalDateTime start, LocalDateTime end) {
        return locationTrackingRepository.findByUserIdAndTimestampBetweenOrderByTimestampDesc(
            userId, start, end
        );
    }
    
    /**
     * Obtener todas las ubicaciones de hoy
     */
    public List<LocationTracking> getTodayLocations() {
        return locationTrackingRepository.findTodayLocations();
    }
    
    /**
     * Obtener ubicaciones de un usuario para hoy
     */
    public List<LocationTracking> getTodayLocationsByUserId(String userId) {
        LocalDateTime startOfDay = LocalDate.now().atStartOfDay();
        LocalDateTime endOfDay = startOfDay.plusDays(1);
        return locationTrackingRepository.findByUserIdAndTimestampBetweenOrderByTimestampDesc(
            userId, startOfDay, endOfDay
        );
    }
    
    /**
     * Obtener ubicaciones durante el horario laboral (8AM - 4PM)
     */
    public List<LocationTracking> getWorkHoursLocationsByUserId(String userId) {
        return locationTrackingRepository.findByUserIdAndHourRange(userId, 8, 16);
    }
    
    /**
     * Obtener todas las ubicaciones (para administración)
     */
    public List<LocationTracking> getAllLocations() {
        return locationTrackingRepository.findAll();
    }
    
    /**
     * Eliminar ubicaciones antiguas (más de 90 días)
     */
    @Transactional
    public int cleanOldLocations(int daysToKeep) {
        LocalDateTime cutoffDate = LocalDateTime.now().minusDays(daysToKeep);
        List<LocationTracking> oldLocations = locationTrackingRepository.findAll()
            .stream()
            .filter(loc -> loc.getTimestamp().isBefore(cutoffDate))
            .toList();
        
        locationTrackingRepository.deleteAll(oldLocations);
        return oldLocations.size();
    }
}
