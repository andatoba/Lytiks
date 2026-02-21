package com.lytiks.backend.entity;

import jakarta.persistence.*;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import java.time.LocalDateTime;
import java.util.List;

@Entity
@Table(name = "ejecucion_plan_moko")
@JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
public class EjecucionPlanMoko {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "foco_id", nullable = false)
    private Long focoId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_plan_seg_moko", nullable = false)
    @JsonIgnoreProperties({"tareas", "hibernateLazyInitializer", "handler"})
    private PlanSeguimientoMoko planSeguimiento;

    @Column(name = "completado", nullable = false)
    private Boolean completado = false;

    @Column(name = "fecha_inicio")
    private LocalDateTime fechaInicio;

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

    // Relaciones
    @OneToMany(mappedBy = "ejecucionPlan", fetch = FetchType.LAZY, cascade = CascadeType.ALL)
    @JsonIgnoreProperties({"ejecucionPlan"})
    private List<EjecucionTareasMoko> tareasEjecutadas;

    // Constructores
    public EjecucionPlanMoko() {
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

    public Long getFocoId() {
        return focoId;
    }

    public void setFocoId(Long focoId) {
        this.focoId = focoId;
    }

    public PlanSeguimientoMoko getPlanSeguimiento() {
        return planSeguimiento;
    }

    public void setPlanSeguimiento(PlanSeguimientoMoko planSeguimiento) {
        this.planSeguimiento = planSeguimiento;
    }

    public Boolean getCompletado() {
        return completado;
    }

    public void setCompletado(Boolean completado) {
        this.completado = completado;
    }

    public LocalDateTime getFechaInicio() {
        return fechaInicio;
    }

    public void setFechaInicio(LocalDateTime fechaInicio) {
        this.fechaInicio = fechaInicio;
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

    public List<EjecucionTareasMoko> getTareasEjecutadas() {
        return tareasEjecutadas;
    }

    public void setTareasEjecutadas(List<EjecucionTareasMoko> tareasEjecutadas) {
        this.tareasEjecutadas = tareasEjecutadas;
    }
}
