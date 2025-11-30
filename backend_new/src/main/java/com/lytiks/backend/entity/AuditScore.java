package com.lytiks.backend.entity;

import jakarta.persistence.*;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonBackReference;

@Entity
@Table(name = "audit_scores")
@JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
public class AuditScore {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "audit_id", nullable = false)
    @JsonBackReference
    private Audit audit;
    
    @Column(name = "categoria", nullable = false)
    private String categoria;
    
    @Column(name = "puntuacion", nullable = false)
    private Integer puntuacion;
    
    @Column(name = "max_puntuacion")
    private Integer maxPuntuacion = 100;
    
    @Column(name = "observaciones", columnDefinition = "TEXT")
    private String observaciones;
    
    @Column(name = "photo_path")
    private String photoPath;
    
    // Constructors
    public AuditScore() {}
    
    public AuditScore(Audit audit, String categoria, Integer puntuacion) {
        this.audit = audit;
        this.categoria = categoria;
        this.puntuacion = puntuacion;
    }
    
    // Getters and Setters
    public Long getId() {
        return id;
    }
    
    public void setId(Long id) {
        this.id = id;
    }
    
    public Audit getAudit() {
        return audit;
    }
    
    public void setAudit(Audit audit) {
        this.audit = audit;
    }
    
    public String getCategoria() {
        return categoria;
    }
    
    public void setCategoria(String categoria) {
        this.categoria = categoria;
    }
    
    public Integer getPuntuacion() {
        return puntuacion;
    }
    
    public void setPuntuacion(Integer puntuacion) {
        this.puntuacion = puntuacion;
    }
    
    public Integer getMaxPuntuacion() {
        return maxPuntuacion;
    }
    
    public void setMaxPuntuacion(Integer maxPuntuacion) {
        this.maxPuntuacion = maxPuntuacion;
    }
    
    public String getObservaciones() {
        return observaciones;
    }
    
    public void setObservaciones(String observaciones) {
        this.observaciones = observaciones;
    }
    
    public String getPhotoPath() {
        return photoPath;
    }
    
    public void setPhotoPath(String photoPath) {
        this.photoPath = photoPath;
    }
}