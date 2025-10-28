package com.lytiks.backend.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "moko_audit_details")
public class MokoAuditDetail {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "moko_audit_id", nullable = false)
    private MokoAudit mokoAudit;
    
    @Column(name = "categoria", nullable = false)
    private String categoria;
    
    @Column(name = "subcategoria")
    private String subcategoria;
    
    @Column(name = "pregunta", columnDefinition = "TEXT")
    private String pregunta;
    
    @Column(name = "respuesta")
    private String respuesta; // SI/NO/PARCIAL
    
    @Column(name = "puntuacion")
    private Integer puntuacion;
    
    @Column(name = "puntuacion_maxima")
    private Integer puntuacionMaxima;
    
    @Column(name = "es_critico")
    private Boolean esCritico = false;
    
    @Column(name = "observaciones", columnDefinition = "TEXT")
    private String observaciones;
    
    @Column(name = "recomendaciones", columnDefinition = "TEXT")
    private String recomendaciones;
    
    // Constructors
    public MokoAuditDetail() {}
    
    public MokoAuditDetail(MokoAudit mokoAudit, String categoria, String pregunta) {
        this.mokoAudit = mokoAudit;
        this.categoria = categoria;
        this.pregunta = pregunta;
    }
    
    // Getters and Setters
    public Long getId() {
        return id;
    }
    
    public void setId(Long id) {
        this.id = id;
    }
    
    public MokoAudit getMokoAudit() {
        return mokoAudit;
    }
    
    public void setMokoAudit(MokoAudit mokoAudit) {
        this.mokoAudit = mokoAudit;
    }
    
    public String getCategoria() {
        return categoria;
    }
    
    public void setCategoria(String categoria) {
        this.categoria = categoria;
    }
    
    public String getSubcategoria() {
        return subcategoria;
    }
    
    public void setSubcategoria(String subcategoria) {
        this.subcategoria = subcategoria;
    }
    
    public String getPregunta() {
        return pregunta;
    }
    
    public void setPregunta(String pregunta) {
        this.pregunta = pregunta;
    }
    
    public String getRespuesta() {
        return respuesta;
    }
    
    public void setRespuesta(String respuesta) {
        this.respuesta = respuesta;
    }
    
    public Integer getPuntuacion() {
        return puntuacion;
    }
    
    public void setPuntuacion(Integer puntuacion) {
        this.puntuacion = puntuacion;
    }
    
    public Integer getPuntuacionMaxima() {
        return puntuacionMaxima;
    }
    
    public void setPuntuacionMaxima(Integer puntuacionMaxima) {
        this.puntuacionMaxima = puntuacionMaxima;
    }
    
    public Boolean getEsCritico() {
        return esCritico;
    }
    
    public void setEsCritico(Boolean esCritico) {
        this.esCritico = esCritico;
    }
    
    public String getObservaciones() {
        return observaciones;
    }
    
    public void setObservaciones(String observaciones) {
        this.observaciones = observaciones;
    }
    
    public String getRecomendaciones() {
        return recomendaciones;
    }
    
    public void setRecomendaciones(String recomendaciones) {
        this.recomendaciones = recomendaciones;
    }
}