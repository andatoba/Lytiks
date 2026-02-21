package com.lytiks.backend.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "aplicaciones")
public class Aplicacion {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "cliente_id")
    private Long clienteId;

    @Column(name = "producto_id")
    private Long productoId;

    @Column(name = "producto_nombre")
    private String productoNombre;

    @Column(name = "plan")
    private String plan;

    @Column(name = "lote")
    private String lote;

    @Column(name = "area_hectareas")
    private Double areaHectareas;

    @Column(name = "dosis")
    private String dosis;

    @Column(name = "fecha_inicio")
    private LocalDateTime fechaInicio;

    @Column(name = "frecuencia_dias")
    private Integer frecuenciaDias;

    @Column(name = "repeticiones")
    private Integer repeticiones;

    @Column(name = "recordatorio_hora")
    private String recordatorioHora;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    public Aplicacion() {}

    public Aplicacion(Long id, Long clienteId, Long productoId, String productoNombre, String plan,
            String lote, Double areaHectareas, String dosis, LocalDateTime fechaInicio,
            Integer frecuenciaDias, Integer repeticiones, String recordatorioHora, LocalDateTime createdAt) {
        this.id = id;
        this.clienteId = clienteId;
        this.productoId = productoId;
        this.productoNombre = productoNombre;
        this.plan = plan;
        this.lote = lote;
        this.areaHectareas = areaHectareas;
        this.dosis = dosis;
        this.fechaInicio = fechaInicio;
        this.frecuenciaDias = frecuenciaDias;
        this.repeticiones = repeticiones;
        this.recordatorioHora = recordatorioHora;
        this.createdAt = createdAt;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Long getClienteId() { return clienteId; }
    public void setClienteId(Long clienteId) { this.clienteId = clienteId; }
    public Long getProductoId() { return productoId; }
    public void setProductoId(Long productoId) { this.productoId = productoId; }
    public String getProductoNombre() { return productoNombre; }
    public void setProductoNombre(String productoNombre) { this.productoNombre = productoNombre; }
    public String getPlan() { return plan; }
    public void setPlan(String plan) { this.plan = plan; }
    public String getLote() { return lote; }
    public void setLote(String lote) { this.lote = lote; }
    public Double getAreaHectareas() { return areaHectareas; }
    public void setAreaHectareas(Double areaHectareas) { this.areaHectareas = areaHectareas; }
    public String getDosis() { return dosis; }
    public void setDosis(String dosis) { this.dosis = dosis; }
    public LocalDateTime getFechaInicio() { return fechaInicio; }
    public void setFechaInicio(LocalDateTime fechaInicio) { this.fechaInicio = fechaInicio; }
    public Integer getFrecuenciaDias() { return frecuenciaDias; }
    public void setFrecuenciaDias(Integer frecuenciaDias) { this.frecuenciaDias = frecuenciaDias; }
    public Integer getRepeticiones() { return repeticiones; }
    public void setRepeticiones(Integer repeticiones) { this.repeticiones = repeticiones; }
    public String getRecordatorioHora() { return recordatorioHora; }
    public void setRecordatorioHora(String recordatorioHora) { this.recordatorioHora = recordatorioHora; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
