package com.lytiks.backend.entity;

import jakarta.persistence.*;
import lombok.Data;

import java.time.LocalDateTime;

@Entity
@Table(name = "moko_capacitacion")
@Data
public class MokoCapacitacion {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "cliente_id", nullable = false)
    private Long clienteId;

    @Column(name = "hacienda_id")
    private Long haciendaId;

    @Column(name = "lote_id")
    private Long loteId;

    @Column(name = "hacienda")
    private String hacienda;

    @Column(name = "lote", nullable = false)
    private String lote;

    @Column(name = "tema", nullable = false)
    private String tema;

    @Column(name = "descripcion", columnDefinition = "TEXT")
    private String descripcion;

    @Column(name = "participantes")
    private Integer participantes;

    @Column(name = "fotos_json", columnDefinition = "LONGTEXT")
    private String fotosJson;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at", nullable = false)
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
}
