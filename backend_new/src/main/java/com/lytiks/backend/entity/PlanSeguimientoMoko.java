package com.lytiks.backend.entity;

import jakarta.persistence.*;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import java.time.LocalDateTime;
import java.util.List;

@Entity
@Table(name = "plan_seguimiento_moko")
@JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
public class PlanSeguimientoMoko {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "nombre", nullable = false, length = 100)
    private String nombre;

    @Column(name = "detalle", columnDefinition = "TEXT")
    private String detalle;

    @Column(name = "orden", nullable = false)
    private Integer orden = 0;

    @Column(name = "activo", nullable = false)
    private Boolean activo = true;

    // Campos de auditoría
    @Column(name = "fecha_creacion", nullable = false)
    private LocalDateTime fechaCreacion;

    @Column(name = "fecha_modificacion")
    private LocalDateTime fechaModificacion;

    @Column(name = "usuario_creacion", length = 100)
    private String usuarioCreacion;

    @Column(name = "usuario_modificacion", length = 100)
    private String usuarioModificacion;

    // Relaciones
    @OneToMany(mappedBy = "planSeguimiento", fetch = FetchType.LAZY)
    @JsonIgnoreProperties({"planSeguimiento"})
    private List<ItemsTareasMoko> tareas;

    // Constructores
    public PlanSeguimientoMoko() {
        this.fechaCreacion = LocalDateTime.now();
        this.activo = true;
    }

    // Getters y Setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public String getDetalle() {
        return detalle;
    }

    public void setDetalle(String detalle) {
        this.detalle = detalle;
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

    public LocalDateTime getFechaCreacion() {
        return fechaCreacion;
    }

    public void setFechaCreacion(LocalDateTime fechaCreacion) {
        this.fechaCreacion = fechaCreacion;
    }

    public LocalDateTime getFechaModificacion() {
        return fechaModificacion;
    }

    public void setFechaModificacion(LocalDateTime fechaModificacion) {
        this.fechaModificacion = fechaModificacion;
    }

    public String getUsuarioCreacion() {
        return usuarioCreacion;
    }

    public void setUsuarioCreacion(String usuarioCreacion) {
        this.usuarioCreacion = usuarioCreacion;
    }

    public String getUsuarioModificacion() {
        return usuarioModificacion;
    }

    public void setUsuarioModificacion(String usuarioModificacion) {
        this.usuarioModificacion = usuarioModificacion;
    }

    public List<ItemsTareasMoko> getTareas() {
        return tareas;
    }

    public void setTareas(List<ItemsTareasMoko> tareas) {
        this.tareas = tareas;
    }
}
