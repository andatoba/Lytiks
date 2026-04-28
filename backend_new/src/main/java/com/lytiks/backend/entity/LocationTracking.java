package com.lytiks.backend.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "location_tracking")
public class LocationTracking {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "user_id", nullable = false)
    private String userId;
    
    @Column(name = "user_name")
    private String userName;
    
    @Column(nullable = false)
    private Double latitude;
    
    @Column(nullable = false)
    private Double longitude;
    
    @Column
    private Double accuracy;
    
    @Column(name = "matrix_latitude")
    private Double matrixLatitude;
    
    @Column(name = "matrix_longitude")
    private Double matrixLongitude;
    
    @Column(nullable = false)
    private LocalDateTime timestamp;
    
    @Column(name = "created_at")
    private LocalDateTime createdAt;
    
    // Constructors
    public LocationTracking() {
        this.createdAt = LocalDateTime.now();
    }
    
    public LocationTracking(String userId, String userName, Double latitude, Double longitude, 
                           Double accuracy, Double matrixLatitude, Double matrixLongitude, 
                           LocalDateTime timestamp) {
        this.userId = userId;
        this.userName = userName;
        this.latitude = latitude;
        this.longitude = longitude;
        this.accuracy = accuracy;
        this.matrixLatitude = matrixLatitude;
        this.matrixLongitude = matrixLongitude;
        this.timestamp = timestamp;
        this.createdAt = LocalDateTime.now();
    }
    
    // Getters and Setters
    public Long getId() {
        return id;
    }
    
    public void setId(Long id) {
        this.id = id;
    }
    
    public String getUserId() {
        return userId;
    }
    
    public void setUserId(String userId) {
        this.userId = userId;
    }
    
    public String getUserName() {
        return userName;
    }
    
    public void setUserName(String userName) {
        this.userName = userName;
    }
    
    public Double getLatitude() {
        return latitude;
    }
    
    public void setLatitude(Double latitude) {
        this.latitude = latitude;
    }
    
    public Double getLongitude() {
        return longitude;
    }
    
    public void setLongitude(Double longitude) {
        this.longitude = longitude;
    }
    
    public Double getAccuracy() {
        return accuracy;
    }
    
    public void setAccuracy(Double accuracy) {
        this.accuracy = accuracy;
    }
    
    public Double getMatrixLatitude() {
        return matrixLatitude;
    }
    
    public void setMatrixLatitude(Double matrixLatitude) {
        this.matrixLatitude = matrixLatitude;
    }
    
    public Double getMatrixLongitude() {
        return matrixLongitude;
    }
    
    public void setMatrixLongitude(Double matrixLongitude) {
        this.matrixLongitude = matrixLongitude;
    }
    
    public LocalDateTime getTimestamp() {
        return timestamp;
    }
    
    public void setTimestamp(LocalDateTime timestamp) {
        this.timestamp = timestamp;
    }
    
    public LocalDateTime getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
}
