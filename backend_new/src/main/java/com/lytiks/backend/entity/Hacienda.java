package com.lytiks.backend.entity;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import jakarta.persistence.*;
import java.time.LocalDateTime;

/**
 * Entidad Hacienda
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "hacienda")
public class Hacienda {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "nombre", nullable = false)
    private String nombre;
    
    @Column(name = "detalle", columnDefinition = "TEXT")
    private String detalle;
    
    @Column(name = "ubicacion")
    private String ubicacion;
    
    @Column(name = "hectareas")
    private Double hectareas;
    
    @Column(name = "cliente_id", nullable = false)
    private Long clienteId;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "cliente_id", insertable = false, updatable = false)
    private Client cliente;
    
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
