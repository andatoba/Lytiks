package com.lytiks.backend.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "sigatoka_photos")
public class SigatokaPhoto {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "sigatoka_audit_id", nullable = false)
    private SigatokaAudit sigatokaAudit;
    
    @Column(name = "photo_path", nullable = false)
    private String photoPath;
    
    @Column(name = "description")
    private String description;
    
    @Column(name = "photo_type")
    private String photoType; // EVIDENCIA, SINTOMA, TRATAMIENTO, etc.
    
    // Constructors
    public SigatokaPhoto() {}
    
    public SigatokaPhoto(SigatokaAudit sigatokaAudit, String photoPath, String description, String photoType) {
        this.sigatokaAudit = sigatokaAudit;
        this.photoPath = photoPath;
        this.description = description;
        this.photoType = photoType;
    }
    
    // Getters and Setters
    public Long getId() {
        return id;
    }
    
    public void setId(Long id) {
        this.id = id;
    }
    
    public SigatokaAudit getSigatokaAudit() {
        return sigatokaAudit;
    }
    
    public void setSigatokaAudit(SigatokaAudit sigatokaAudit) {
        this.sigatokaAudit = sigatokaAudit;
    }
    
    public String getPhotoPath() {
        return photoPath;
    }
    
    public void setPhotoPath(String photoPath) {
        this.photoPath = photoPath;
    }
    
    public String getDescription() {
        return description;
    }
    
    public void setDescription(String description) {
        this.description = description;
    }
    
    public String getPhotoType() {
        return photoType;
    }
    
    public void setPhotoType(String photoType) {
        this.photoType = photoType;
    }
}