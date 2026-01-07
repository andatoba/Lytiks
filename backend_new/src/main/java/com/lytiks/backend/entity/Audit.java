package com.lytiks.backend.entity;

import jakarta.persistence.*;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonManagedReference;
import java.time.LocalDateTime;
import java.util.List;

@Entity
@Table(name = "audits")
@JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
public class Audit {
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "client_id")
    @JsonManagedReference
    private Client client;

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "hacienda", nullable = false)
    private String hacienda;
    
    @Column(name = "cultivo", nullable = false)
    private String cultivo;
    
    @Column(name = "fecha", nullable = false)
    private LocalDateTime fecha;
    
    @Column(name = "evaluaciones")
    private String evaluaciones;
    
    @Column(name = "tecnico_id")
    private Long tecnicoId;
    
    @Column(name = "estado")
    private String estado = "PENDIENTE";
    
    @Column(name = "observaciones", columnDefinition = "TEXT")
    private String observaciones;
    
    @OneToMany(mappedBy = "audit", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    @JsonManagedReference
    private List<AuditScore> scores;
    
    @OneToMany(mappedBy = "audit", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    @JsonManagedReference
    private List<AuditPhoto> photos;
    
    // Constructors
    public Audit() {}
    
    public Audit(String hacienda, String cultivo, LocalDateTime fecha, Long tecnicoId) {
        this.hacienda = hacienda;
        this.cultivo = cultivo;
        this.fecha = fecha;
        this.tecnicoId = tecnicoId;
    }
    
    // Getters and Setters
    public Long getId() {
        return id;
    }
    
    public void setId(Long id) {
        this.id = id;
    }
    
    public String getHacienda() {
        return hacienda;
    }
    
    public void setHacienda(String hacienda) {
        this.hacienda = hacienda;
    }
    
    public String getCultivo() {
        return cultivo;
    }
    
    public void setCultivo(String cultivo) {
        this.cultivo = cultivo;
    }
    
    public LocalDateTime getFecha() {
        return fecha;
    }
    
    public void setFecha(LocalDateTime fecha) {
        this.fecha = fecha;
    }
    
    public String getEvaluaciones() {
        return evaluaciones;
    }
    
    public void setEvaluaciones(String evaluaciones) {
        this.evaluaciones = evaluaciones;
    }
    
    public Long getTecnicoId() {
        return tecnicoId;
    }
    
    public void setTecnicoId(Long tecnicoId) {
        this.tecnicoId = tecnicoId;
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
    
    public List<AuditScore> getScores() {
        return scores;
    }
    
    public void setScores(List<AuditScore> scores) {
        this.scores = scores;
    }
    
    public List<AuditPhoto> getPhotos() {
        return photos;
    }
    
    public void setPhotos(List<AuditPhoto> photos) {
        this.photos = photos;
    }

    public Client getClient() {
        return client;
    }

    public void setClient(Client client) {
        this.client = client;
    }

        @Transient
        private String cedulaCliente;

        public String getCedulaCliente() {
            return cedulaCliente;
        }

        public void setCedulaCliente(String cedulaCliente) {
            this.cedulaCliente = cedulaCliente;
        }
}