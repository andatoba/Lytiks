package com.lytiks.backend.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;
import java.util.Objects;

@Entity
@Table(name = "seguimiento_aplicaciones")
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
    private String estado;

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

    public SeguimientoAplicacion() {}

    public SeguimientoAplicacion(Long id, Long aplicacionId, Integer numeroAplicacion,
            LocalDateTime fechaProgramada, LocalDateTime fechaAplicada, String estado,
            String dosisAplicada, String lote, String observaciones, String fotoEvidencia,
            Boolean recordatorioActivo, String horaRecordatorio, LocalDateTime fechaCreacion,
            LocalDateTime fechaActualizacion) {
        this.id = id; this.aplicacionId = aplicacionId; this.numeroAplicacion = numeroAplicacion;
        this.fechaProgramada = fechaProgramada; this.fechaAplicada = fechaAplicada;
        this.estado = estado; this.dosisAplicada = dosisAplicada; this.lote = lote;
        this.observaciones = observaciones; this.fotoEvidencia = fotoEvidencia;
        this.recordatorioActivo = recordatorioActivo; this.horaRecordatorio = horaRecordatorio;
        this.fechaCreacion = fechaCreacion; this.fechaActualizacion = fechaActualizacion;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Long getAplicacionId() { return aplicacionId; }
    public void setAplicacionId(Long aplicacionId) { this.aplicacionId = aplicacionId; }
    public Integer getNumeroAplicacion() { return numeroAplicacion; }
    public void setNumeroAplicacion(Integer numeroAplicacion) { this.numeroAplicacion = numeroAplicacion; }
    public LocalDateTime getFechaProgramada() { return fechaProgramada; }
    public void setFechaProgramada(LocalDateTime fechaProgramada) { this.fechaProgramada = fechaProgramada; }
    public LocalDateTime getFechaAplicada() { return fechaAplicada; }
    public void setFechaAplicada(LocalDateTime fechaAplicada) { this.fechaAplicada = fechaAplicada; }
    public String getEstado() { return estado; }
    public void setEstado(String estado) { this.estado = estado; }
    public String getDosisAplicada() { return dosisAplicada; }
    public void setDosisAplicada(String dosisAplicada) { this.dosisAplicada = dosisAplicada; }
    public String getLote() { return lote; }
    public void setLote(String lote) { this.lote = lote; }
    public String getObservaciones() { return observaciones; }
    public void setObservaciones(String observaciones) { this.observaciones = observaciones; }
    public String getFotoEvidencia() { return fotoEvidencia; }
    public void setFotoEvidencia(String fotoEvidencia) { this.fotoEvidencia = fotoEvidencia; }
    public Boolean getRecordatorioActivo() { return recordatorioActivo; }
    public void setRecordatorioActivo(Boolean recordatorioActivo) { this.recordatorioActivo = recordatorioActivo; }
    public String getHoraRecordatorio() { return horaRecordatorio; }
    public void setHoraRecordatorio(String horaRecordatorio) { this.horaRecordatorio = horaRecordatorio; }
    public LocalDateTime getFechaCreacion() { return fechaCreacion; }
    public void setFechaCreacion(LocalDateTime fechaCreacion) { this.fechaCreacion = fechaCreacion; }
    public LocalDateTime getFechaActualizacion() { return fechaActualizacion; }
    public void setFechaActualizacion(LocalDateTime fechaActualizacion) { this.fechaActualizacion = fechaActualizacion; }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        SeguimientoAplicacion that = (SeguimientoAplicacion) o;
        return Objects.equals(id, that.id);
    }

    @Override
    public int hashCode() { return Objects.hash(id); }
}
