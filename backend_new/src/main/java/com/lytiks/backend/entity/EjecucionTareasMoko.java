package com.lytiks.backend.entity;

import jakarta.persistence.*;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import java.time.LocalDateTime;

@Entity
@Table(name = "ejecucion_tareas_moko")
@JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
public class EjecucionTareasMoko {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "ejecucion_plan_id", nullable = false)
    @JsonIgnoreProperties({"tareasEjecutadas", "hibernateLazyInitializer", "handler"})
    private EjecucionPlanMoko ejecucionPlan;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_item_tarea", nullable = false)
    @JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
    private ItemsTareasMoko itemTarea;

    @Column(name = "completado", nullable = false)
    private Boolean completado = false;

    @Column(name = "fecha_completado")
    private LocalDateTime fechaCompletado;

    @Column(name = "observaciones", columnDefinition = "TEXT")
    private String observaciones;

    // Campos de auditoría
    @Column(name = "fecha_creacion", nullable = false)
    private LocalDateTime fechaCreacion;

    @Column(name = "fecha_modificacion")
    private LocalDateTime fechaModificacion;

    @Column(name = "usuario_creacion", length = 100)
    private String usuarioCreacion;

    @Column(name = "usuario_modificacion", length = 100)
    private String usuarioModificacion;

    // Constructores
    public EjecucionTareasMoko() {
        this.fechaCreacion = LocalDateTime.now();
        this.completado = false;
    }

    // Getters y Setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public EjecucionPlanMoko getEjecucionPlan() {
        return ejecucionPlan;
    }

    public void setEjecucionPlan(EjecucionPlanMoko ejecucionPlan) {
        this.ejecucionPlan = ejecucionPlan;
    }

    public ItemsTareasMoko getItemTarea() {
        return itemTarea;
    }

    public void setItemTarea(ItemsTareasMoko itemTarea) {
        this.itemTarea = itemTarea;
    }

    public Boolean getCompletado() {
        return completado;
    }

    public void setCompletado(Boolean completado) {
        this.completado = completado;
    }

    public LocalDateTime getFechaCompletado() {
        return fechaCompletado;
    }

    public void setFechaCompletado(LocalDateTime fechaCompletado) {
        this.fechaCompletado = fechaCompletado;
    }

    public String getObservaciones() {
        return observaciones;
    }

    public void setObservaciones(String observaciones) {
        this.observaciones = observaciones;
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
}
