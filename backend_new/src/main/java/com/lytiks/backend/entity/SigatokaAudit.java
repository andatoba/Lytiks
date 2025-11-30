package com.lytiks.backend.entity;

import jakarta.persistence.*;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonManagedReference;
import java.time.LocalDateTime;
import java.util.List;

@Entity
@Table(name = "sigatoka_audits")
@JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
public class SigatokaAudit {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "tipo_auditoria", nullable = false)
    private String tipoAuditoria = "CONTROL_SIGATOKA";
    
    @Column(name = "fecha", nullable = false)
    private LocalDateTime fecha;
    
    @Column(name = "nivel_analisis", nullable = false)
    private String nivelAnalisis; // BASICO o COMPLETO
    
    @Column(name = "tipo_cultivo", nullable = false)
    private String tipoCultivo; // BANANO o PALMA
    
    @Column(name = "tecnico_id")
    private Long tecnicoId;
    
    @Column(name = "cliente_id")
    private Long clienteId;
    
    @Column(name = "hacienda")
    private String hacienda;
    
    @Column(name = "lote")
    private String lote;
    
    @Column(name = "estado")
    private String estado = "PENDIENTE";
    
    @Column(name = "observaciones", columnDefinition = "TEXT")
    private String observaciones;
    
    @Column(name = "recomendaciones", columnDefinition = "TEXT")
    private String recomendaciones;
    
    @Column(name = "stover_real")
    private Double stoverReal;
    
    @Column(name = "stover_recomendado")
    private Double stoverRecomendado;
    
    @Column(name = "estado_general")
    private String estadoGeneral; // OPTIMO, MODERADO, CRITICO
    
    @OneToMany(mappedBy = "sigatokaAudit", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    @JsonManagedReference
    private List<SigatokaParameter> parameters;
    
    @OneToMany(mappedBy = "sigatokaAudit", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    @JsonManagedReference
    private List<SigatokaPhoto> photos;

        @Transient
        private String cedulaCliente;

        public String getCedulaCliente() {
            return cedulaCliente;
        }

        public void setCedulaCliente(String cedulaCliente) {
            this.cedulaCliente = cedulaCliente;
        }
    
    // Constructors
    public SigatokaAudit() {}
    
    public SigatokaAudit(String nivelAnalisis, String tipoCultivo, String hacienda, String lote, Long tecnicoId) {
        this.nivelAnalisis = nivelAnalisis;
        this.tipoCultivo = tipoCultivo;
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
    
    public String getNivelAnalisis() {
        return nivelAnalisis;
    }
    
    public void setNivelAnalisis(String nivelAnalisis) {
        this.nivelAnalisis = nivelAnalisis;
    }
    
    public String getTipoCultivo() {
        return tipoCultivo;
    }
    
    public void setTipoCultivo(String tipoCultivo) {
        this.tipoCultivo = tipoCultivo;
    }
    
    public Long getTecnicoId() {
        return tecnicoId;
    }
    
    public void setTecnicoId(Long tecnicoId) {
        this.tecnicoId = tecnicoId;
    }
    
    public Long getClienteId() {
        return clienteId;
    }
    
    public void setClienteId(Long clienteId) {
        this.clienteId = clienteId;
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
    
    public String getRecomendaciones() {
        return recomendaciones;
    }
    
    public void setRecomendaciones(String recomendaciones) {
        this.recomendaciones = recomendaciones;
    }
    
    public Double getStoverReal() {
        return stoverReal;
    }
    
    public void setStoverReal(Double stoverReal) {
        this.stoverReal = stoverReal;
    }
    
    public Double getStoverRecomendado() {
        return stoverRecomendado;
    }
    
    public void setStoverRecomendado(Double stoverRecomendado) {
        this.stoverRecomendado = stoverRecomendado;
    }
    
    public String getEstadoGeneral() {
        return estadoGeneral;
    }
    
    public void setEstadoGeneral(String estadoGeneral) {
        this.estadoGeneral = estadoGeneral;
    }
    
    public List<SigatokaParameter> getParameters() {
        return parameters;
    }
    
    public void setParameters(List<SigatokaParameter> parameters) {
        this.parameters = parameters;
    }
    
    public List<SigatokaPhoto> getPhotos() {
        return photos;
    }
    
    public void setPhotos(List<SigatokaPhoto> photos) {
        this.photos = photos;
    }
}