package com.lytiks.backend.entity;

import jakarta.persistence.*;
import lombok.Data;

import java.time.LocalDateTime;

@Entity
@Table(name = "moko_muestra")
@Data
public class MokoMuestra {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "cliente_id", nullable = false)
    private Long clienteId;

    @Column(name = "hacienda_id")
    private Long haciendaId;

    @Column(name = "lote_id")
    private Long loteId;

    @Column(name = "lote", nullable = false)
    private String lote;

    @Column(name = "tipo_muestra", nullable = false, length = 30)
    private String tipoMuestra;

    @Column(name = "muestra_numero", nullable = false)
    private Integer muestraNumero;

    @Column(name = "codigo", nullable = false, length = 120)
    private String codigo;

    @Column(name = "descripcion", columnDefinition = "TEXT")
    private String descripcion;

    @Column(name = "foto_path")
    private String fotoPath;

    @Column(name = "resultado_laboratorio", columnDefinition = "TEXT")
    private String resultadoLaboratorio;

    @Column(name = "documento_laboratorio_path")
    private String documentoLaboratorioPath;

    @Column(name = "documento_laboratorio_nombre")
    private String documentoLaboratorioNombre;

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
