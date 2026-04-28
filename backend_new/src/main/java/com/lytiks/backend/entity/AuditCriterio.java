package com.lytiks.backend.entity;

import com.fasterxml.jackson.annotation.JsonBackReference;
import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "audit_criterio")
public class AuditCriterio {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "categoria_id", nullable = false)
    @JsonBackReference
    private AuditCategoria categoria;
    
    @Column(name = "nombre", nullable = false, columnDefinition = "TEXT")
    private String nombre;
    
    @Column(name = "puntuacion_maxima", nullable = false)
    private Integer puntuacionMaxima = 100;
    
    @Column(name = "orden")
    private Integer orden;
    
    @Column(name = "activo")
    private Boolean activo = true;
    
    @Column(name = "created_at")
    private LocalDateTime createdAt;
    
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
    
    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }
    
    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
    
    // Constructores
    public AuditCriterio() {
    }
    
    public AuditCriterio(AuditCategoria categoria, String nombre, Integer puntuacionMaxima, Integer orden) {
        this.categoria = categoria;
        this.nombre = nombre;
        this.puntuacionMaxima = puntuacionMaxima;
        this.orden = orden;
        this.activo = true;
    }
    
    // Getters y Setters
    public Long getId() {
        return id;
    }
    
    public void setId(Long id) {
        this.id = id;
    }
    
    public AuditCategoria getCategoria() {
        return categoria;
    }
    
    public void setCategoria(AuditCategoria categoria) {
        this.categoria = categoria;
    }
    
    public String getNombre() {
        return nombre;
    }
    
    public void setNombre(String nombre) {
        this.nombre = nombre;
    }
    
    public Integer getPuntuacionMaxima() {
        return puntuacionMaxima;
    }
    
    public void setPuntuacionMaxima(Integer puntuacionMaxima) {
        this.puntuacionMaxima = puntuacionMaxima;
    }
    
    public Integer getOrden() {
        return orden;
    }
    
    public void setOrden(Integer orden) {
        this.orden = orden;
    }
    
    public Boolean getActivo() {
        return activo;
    }
    
    public void setActivo(Boolean activo) {
        this.activo = activo;
    }
    
    public LocalDateTime getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
    
    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }
    
    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }
    
    @Override
    public String toString() {
        return "AuditCriterio{" +
                "id=" + id +
                ", nombre='" + nombre + '\'' +
                ", puntuacionMaxima=" + puntuacionMaxima +
                ", orden=" + orden +
                ", activo=" + activo +
                '}';
    }
}
