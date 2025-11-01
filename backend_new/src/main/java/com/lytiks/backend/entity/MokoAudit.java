package com.lytiks.backend.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;
import java.util.List;

@Entity
@Table(name = "moko_audits")
public class MokoAudit {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "tipo_auditoria", nullable = false)
    private String tipoAuditoria = "CONTROL_MOKO";
    
    @Column(name = "fecha", nullable = false)
    private LocalDateTime fecha;
    
    @Column(name = "evaluaciones_totales")
    private Integer evaluacionesTotales;
    
    @Column(name = "programa_manejo_score")
    private Integer programaManejoScore;
    
    @Column(name = "programa_manejo_total")
    private Integer programaManejoTotal;
    
    @Column(name = "labores_moko_score")
    private Integer laboresMokoScore;
    
    @Column(name = "labores_moko_total")
    private Integer laboresMokoTotal;
    
    @Column(name = "cumplimiento_general")
    private Double cumplimientoGeneral;
    
    @Column(name = "estado_implementacion")
    private String estadoImplementacion;
    
    @Column(name = "tecnico_id")
    private Long tecnicoId;
    
    @Column(name = "hacienda")
    private String hacienda;
    
    @Column(name = "lote")
    private String lote;
    
    @Column(name = "estado")
    private String estado = "PENDIENTE";
    
    @Column(name = "observaciones", columnDefinition = "TEXT")
    private String observaciones;
    
    @Column(name = "photo_base64_observaciones", columnDefinition = "TEXT")
    private String photoBase64Observaciones;

    @Column(name = "photo_base64_seguimiento", columnDefinition = "TEXT")
    private String photoBase64Seguimiento;
    
    @OneToMany(mappedBy = "mokoAudit", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<MokoAuditDetail> details;
    
    @OneToMany(mappedBy = "mokoAudit", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<MokoAuditPhoto> photos;
    
    // Constructors
    public MokoAudit() {}
    
    public MokoAudit(String hacienda, String lote, Long tecnicoId) {
        this.hacienda = hacienda;
        this.lote = lote;
        this.tecnicoId = tecnicoId;
        this.fecha = LocalDateTime.now();
    }
    
    // Getters and Setters
    public Long getId() {
        return id;
    }
    
    public void setId(Long id) {
        this.id = id;
    }
    
    public String getTipoAuditoria() {
        return tipoAuditoria;
    }
    
    public void setTipoAuditoria(String tipoAuditoria) {
        this.tipoAuditoria = tipoAuditoria;
    }
    
    public LocalDateTime getFecha() {
        return fecha;
    }
    
    public void setFecha(LocalDateTime fecha) {
        this.fecha = fecha;
    }
    
    public Integer getEvaluacionesTotales() {
        return evaluacionesTotales;
    }
    
    public void setEvaluacionesTotales(Integer evaluacionesTotales) {
        this.evaluacionesTotales = evaluacionesTotales;
    }
    
    public Integer getProgramaManejoScore() {
        return programaManejoScore;
    }
    
    public void setProgramaManejoScore(Integer programaManejoScore) {
        this.programaManejoScore = programaManejoScore;
    }
    
    public Integer getProgramaManejoTotal() {
        return programaManejoTotal;
    }
    
    public void setProgramaManejoTotal(Integer programaManejoTotal) {
        this.programaManejoTotal = programaManejoTotal;
    }
    
    public Integer getLaboresMokoScore() {
        return laboresMokoScore;
    }
    
    public void setLaboresMokoScore(Integer laboresMokoScore) {
        this.laboresMokoScore = laboresMokoScore;
    }
    
    public Integer getLaboresMokoTotal() {
        return laboresMokoTotal;
    }
    
    public void setLaboresMokoTotal(Integer laboresMokoTotal) {
        this.laboresMokoTotal = laboresMokoTotal;
    }
    
    public Double getCumplimientoGeneral() {
        return cumplimientoGeneral;
    }
    
    public void setCumplimientoGeneral(Double cumplimientoGeneral) {
        this.cumplimientoGeneral = cumplimientoGeneral;
    }
    
    public String getEstadoImplementacion() {
        return estadoImplementacion;
    }
    
    public void setEstadoImplementacion(String estadoImplementacion) {
        this.estadoImplementacion = estadoImplementacion;
    }
    
    public Long getTecnicoId() {
        return tecnicoId;
    }
    
    public void setTecnicoId(Long tecnicoId) {
        this.tecnicoId = tecnicoId;
    }
    
    public String getHacienda() {
        return hacienda;
    }
    
    public void setHacienda(String hacienda) {
        this.hacienda = hacienda;
    }
    
    public String getLote() {
        return lote;
    }
    
    public void setLote(String lote) {
        this.lote = lote;
    }
    
    public String getEstado() {
        return estado;
    }
    
    public void setEstado(String estado) {
        this.estado = estado;
    }
    
    public String getObservaciones() {
        return observaciones;
    }
    
    public void setObservaciones(String observaciones) {
        this.observaciones = observaciones;
    }
    
    public String getPhotoBase64Observaciones() {
        return photoBase64Observaciones;
    }

    public void setPhotoBase64Observaciones(String photoBase64Observaciones) {
        this.photoBase64Observaciones = photoBase64Observaciones;
    }

    public String getPhotoBase64Seguimiento() {
        return photoBase64Seguimiento;
    }

    public void setPhotoBase64Seguimiento(String photoBase64Seguimiento) {
        this.photoBase64Seguimiento = photoBase64Seguimiento;
    }
    
    public List<MokoAuditDetail> getDetails() {
        return details;
    }
    
    public void setDetails(List<MokoAuditDetail> details) {
        this.details = details;
    }
    
    public List<MokoAuditPhoto> getPhotos() {
        return photos;
    }
    
    public void setPhotos(List<MokoAuditPhoto> photos) {
        this.photos = photos;
    }
}