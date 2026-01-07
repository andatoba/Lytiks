package com.lytiks.backend.entity;

import jakarta.persistence.*;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import java.time.LocalDateTime;

@Entity
@Table(name = "registro_moko")
@JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
public class RegistroMoko {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "numero_foco", nullable = false)
    private Integer numeroFoco;

    @Column(name = "cliente_id", nullable = false)
    private Long clienteId;

    @Column(name = "gps_coordinates")
    private String gpsCoordinates;

    @Column(name = "plantas_afectadas", nullable = false)
    private Integer plantasAfectadas;

    @Column(name = "fecha_deteccion", nullable = false)
    private LocalDateTime fechaDeteccion;

    @Column(name = "sintoma_id")
    private Long sintomaId;

    @Column(name = "sintomas_json", columnDefinition = "TEXT")
    private String sintomasJson;

    @Column(name = "lote")
    private String lote;

    @Column(name = "area_hectareas")
    private Double areaHectareas;

    @Column(name = "severidad")
    private String severidad;

    @Column(name = "metodo_comprobacion")
    private String metodoComprobacion;

    @Column(name = "observaciones", columnDefinition = "TEXT")
    private String observaciones;

    @Column(name = "foto_path")
    private String fotoPath;

    @Column(name = "fecha_creacion", nullable = false)
    private LocalDateTime fechaCreacion;

    @Transient
    private String cedulaCliente;

    // Constructores
    public RegistroMoko() {
        this.fechaCreacion = LocalDateTime.now();
    }

    // Getters y Setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Integer getNumeroFoco() {
        return numeroFoco;
    }

    public void setNumeroFoco(Integer numeroFoco) {
        this.numeroFoco = numeroFoco;
    }

    public Long getClienteId() {
        return clienteId;
    }

    public void setClienteId(Long clienteId) {
        this.clienteId = clienteId;
    }

    public String getGpsCoordinates() {
        return gpsCoordinates;
    }

    public void setGpsCoordinates(String gpsCoordinates) {
        this.gpsCoordinates = gpsCoordinates;
    }

    public Integer getPlantasAfectadas() {
        return plantasAfectadas;
    }

    public void setPlantasAfectadas(Integer plantasAfectadas) {
        this.plantasAfectadas = plantasAfectadas;
    }

    public LocalDateTime getFechaDeteccion() {
        return fechaDeteccion;
    }

    public void setFechaDeteccion(LocalDateTime fechaDeteccion) {
        this.fechaDeteccion = fechaDeteccion;
    }

    public Long getSintomaId() {
        return sintomaId;
    }

    public void setSintomaId(Long sintomaId) {
        this.sintomaId = sintomaId;
    }

    public String getSintomasJson() {
        return sintomasJson;
    }

    public void setSintomasJson(String sintomasJson) {
        this.sintomasJson = sintomasJson;
    }

    public String getLote() {
        return lote;
    }

    public void setLote(String lote) {
        this.lote = lote;
    }

    public Double getAreaHectareas() {
        return areaHectareas;
    }

    public void setAreaHectareas(Double areaHectareas) {
        this.areaHectareas = areaHectareas;
    }

    public String getSeveridad() {
        return severidad;
    }

    public void setSeveridad(String severidad) {
        this.severidad = severidad;
    }

    public String getMetodoComprobacion() {
        return metodoComprobacion;
    }

    public void setMetodoComprobacion(String metodoComprobacion) {
        this.metodoComprobacion = metodoComprobacion;
    }

    public String getObservaciones() {
        return observaciones;
    }

    public void setObservaciones(String observaciones) {
        this.observaciones = observaciones;
    }

    public String getFotoPath() {
        return fotoPath;
    }

    public void setFotoPath(String fotoPath) {
        this.fotoPath = fotoPath;
    }

    public LocalDateTime getFechaCreacion() {
        return fechaCreacion;
    }

    public void setFechaCreacion(LocalDateTime fechaCreacion) {
        this.fechaCreacion = fechaCreacion;
    }

    public String getCedulaCliente() {
        return cedulaCliente;
    }

    public void setCedulaCliente(String cedulaCliente) {
        this.cedulaCliente = cedulaCliente;
    }
}