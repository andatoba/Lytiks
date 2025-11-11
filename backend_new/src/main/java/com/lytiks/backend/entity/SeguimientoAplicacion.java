package com.lytiks.backend.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import java.time.LocalDateTime;

@Entity
@Table(name = "seguimiento_aplicaciones")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class SeguimientoAplicacion {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "aplicacion_id")
    private Long aplicacionId;

    @Column(name = "numero_aplicacion")
    private Integer numeroAplicacion;

    @Column(name = "fecha_programada")
    private LocalDateTime fechaProgramada;

    @Column(name = "fecha_aplicada")
    private LocalDateTime fechaAplicada;

    @Column(name = "estado")
    private String estado; // completada, programada, proxima, vencida

    @Column(name = "dosis_aplicada")
    private String dosisAplicada;

    @Column(name = "lote")
    private String lote;

    @Column(name = "observaciones", length = 1000)
    private String observaciones;

    @Column(name = "foto_evidencia", length = 500)
    private String fotoEvidencia;

    @Column(name = "recordatorio_activo")
    private Boolean recordatorioActivo = false;

    @Column(name = "hora_recordatorio")
    private String horaRecordatorio;

    @Column(name = "fecha_creacion")
    private LocalDateTime fechaCreacion;

    @Column(name = "fecha_actualizacion")
    private LocalDateTime fechaActualizacion;
}