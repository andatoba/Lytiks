package com.lytiks.backend.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import java.math.BigDecimal;

@Entity
@Table(name = "sigatoka_estado_evolutivo")
public class SigatokaEstadoEvolutivo {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @JsonIgnore
    @OneToOne
    @JoinColumn(name = "evaluacion_id", nullable = false, unique = true)
    private SigatokaEvaluacion evaluacion;
    
    @Column(name = "ee_3era_hoja", precision = 10, scale = 2)
    private BigDecimal ee3eraHoja;
    
    @Column(name = "ee_4ta_hoja", precision = 10, scale = 2)
    private BigDecimal ee4taHoja;
    
    @Column(name = "ee_5ta_hoja", precision = 10, scale = 2)
    private BigDecimal ee5taHoja;
    
    @Column(name = "nivel_infeccion", length = 50)
    private String nivelInfeccion;

    public SigatokaEstadoEvolutivo() {}

    public SigatokaEstadoEvolutivo(Long id, SigatokaEvaluacion evaluacion, BigDecimal ee3eraHoja,
            BigDecimal ee4taHoja, BigDecimal ee5taHoja, String nivelInfeccion) {
        this.id = id;
        this.evaluacion = evaluacion;
        this.ee3eraHoja = ee3eraHoja;
        this.ee4taHoja = ee4taHoja;
        this.ee5taHoja = ee5taHoja;
        this.nivelInfeccion = nivelInfeccion;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public SigatokaEvaluacion getEvaluacion() { return evaluacion; }
    public void setEvaluacion(SigatokaEvaluacion evaluacion) { this.evaluacion = evaluacion; }
    public BigDecimal getEe3eraHoja() { return ee3eraHoja; }
    public void setEe3eraHoja(BigDecimal ee3eraHoja) { this.ee3eraHoja = ee3eraHoja; }
    public BigDecimal getEe4taHoja() { return ee4taHoja; }
    public void setEe4taHoja(BigDecimal ee4taHoja) { this.ee4taHoja = ee4taHoja; }
    public BigDecimal getEe5taHoja() { return ee5taHoja; }
    public void setEe5taHoja(BigDecimal ee5taHoja) { this.ee5taHoja = ee5taHoja; }
    public String getNivelInfeccion() { return nivelInfeccion; }
    public void setNivelInfeccion(String nivelInfeccion) { this.nivelInfeccion = nivelInfeccion; }
}
