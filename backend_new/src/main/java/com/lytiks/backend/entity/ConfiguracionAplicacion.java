package com.lytiks.backend.entity;

import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDateTime;

@Entity
@Table(name = "configuraciones_aplicacion")
@Data
public class ConfiguracionAplicacion {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "foco_id", nullable = false)
    private Long focoId;

    @Column(name = "fase_id", nullable = false)
    private Long faseId;

    @Column(name = "tarea_id", nullable = false)
    private Long tareaId;

    @Column(name = "nombre_tarea", nullable = false, length = 500)
    private String nombreTarea;

    @Column(name = "fecha_programada", nullable = false)
    private LocalDateTime fechaProgramada;

    @Column(name = "frecuencia", nullable = false)
    private Integer frecuencia; // En días

    @Column(name = "repeticiones", nullable = false)
    private Integer repeticiones;

    @Column(name = "recordatorio", nullable = false)
    private String recordatorio;

    @Column(name = "completado", nullable = false)
    private Boolean completado = false;

    @Column(name = "fecha_creacion", nullable = false)
    private LocalDateTime fechaCreacion;

    @Column(name = "fecha_completado")
    private LocalDateTime fechaCompletado;

    @Column(name = "observaciones", columnDefinition = "TEXT")
    private String observaciones;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
        if (fechaCreacion == null) {
            fechaCreacion = LocalDateTime.now();
        }
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}
