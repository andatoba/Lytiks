package com.lytiks.backend.entity;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import jakarta.persistence.*;
import java.time.LocalDateTime;

/**
 * Entidad Lote
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "lote")
public class Lote {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "nombre", nullable = false)
    private String nombre;
    
    @Column(name = "codigo", nullable = false)
    private String codigo;
    
    @Column(name = "detalle", columnDefinition = "TEXT")
    private String detalle;
    
    @Column(name = "hectareas")
    private Double hectareas;
    
    @Column(name = "variedad")
    private String variedad;
    
    @Column(name = "edad")
    private String edad;
    
    @Column(name = "latitud")
    private Double latitud;
    
    @Column(name = "longitud")
    private Double longitud;
    
    @Column(name = "hacienda_id", nullable = false)
    private Long haciendaId;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "hacienda_id", insertable = false, updatable = false)
    private Hacienda hacienda;
    
    @Column(name = "estado")
    private String estado = "ACTIVO";
    
    @Column(name = "fecha_creacion", updatable = false)
    private LocalDateTime fechaCreacion;
    
    @Column(name = "fecha_actualizacion")
    private LocalDateTime fechaActualizacion;
    
    @Column(name = "usuario_creacion")
    private String usuarioCreacion;
    
    @Column(name = "usuario_actualizacion")
    private String usuarioActualizacion;
    
    @PrePersist
    protected void onCreate() {
        fechaCreacion = LocalDateTime.now();
        fechaActualizacion = LocalDateTime.now();
    }
    
    @PreUpdate
    protected void onUpdate() {
        fechaActualizacion = LocalDateTime.now();
    }
}
