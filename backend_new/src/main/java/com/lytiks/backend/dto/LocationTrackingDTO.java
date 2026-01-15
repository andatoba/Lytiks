package com.lytiks.backend.dto;

import java.time.LocalDateTime;

public class LocationTrackingDTO {
    
    private String userId;
    private String userName;
    private Double latitude;
    private Double longitude;
    private Double accuracy;
    private Double matrixLatitude;
    private Double matrixLongitude;
    private String timestamp; // ISO 8601 format from Flutter
    
    // Constructors
    public LocationTrackingDTO() {}
    
    public LocationTrackingDTO(String userId, String userName, Double latitude, Double longitude, 
                              Double accuracy, Double matrixLatitude, Double matrixLongitude, 
                              String timestamp) {
        this.userId = userId;
        this.userName = userName;
        this.latitude = latitude;
        this.longitude = longitude;
        this.accuracy = accuracy;
        this.matrixLatitude = matrixLatitude;
        this.matrixLongitude = matrixLongitude;
        this.timestamp = timestamp;
    }
    
    // Getters and Setters
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
    
    public String getTimestamp() {
        return timestamp;
    }
    
    public void setTimestamp(String timestamp) {
        this.timestamp = timestamp;
    }
}
