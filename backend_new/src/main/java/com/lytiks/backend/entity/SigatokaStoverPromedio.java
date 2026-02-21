package com.lytiks.backend.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import java.math.BigDecimal;

@Entity
@Table(name = "sigatoka_stover_promedio")
public class SigatokaStoverPromedio {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @JsonIgnore
    @OneToOne
    @JoinColumn(name = "evaluacion_id", nullable = false, unique = true)
    private SigatokaEvaluacion evaluacion;
    
    @Column(name = "stover_3era_hoja", precision = 10, scale = 2)
    private BigDecimal stover3eraHoja;
    
    @Column(name = "stover_4ta_hoja", precision = 10, scale = 2)
    private BigDecimal stover4taHoja;
    
    @Column(name = "stover_5ta_hoja", precision = 10, scale = 2)
    private BigDecimal stover5taHoja;
    
    @Column(name = "stover_promedio", precision = 10, scale = 2)
    private BigDecimal stoverPromedio;
    
    @Column(name = "nivel_infeccion", length = 50)
    private String nivelInfeccion;

    public SigatokaStoverPromedio() {}

    public SigatokaStoverPromedio(Long id, SigatokaEvaluacion evaluacion, BigDecimal stover3eraHoja,
            BigDecimal stover4taHoja, BigDecimal stover5taHoja, BigDecimal stoverPromedio, String nivelInfeccion) {
        this.id = id;
        this.evaluacion = evaluacion;
        this.stover3eraHoja = stover3eraHoja;
        this.stover4taHoja = stover4taHoja;
        this.stover5taHoja = stover5taHoja;
        this.stoverPromedio = stoverPromedio;
        this.nivelInfeccion = nivelInfeccion;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public SigatokaEvaluacion getEvaluacion() { return evaluacion; }
    public void setEvaluacion(SigatokaEvaluacion evaluacion) { this.evaluacion = evaluacion; }
    public BigDecimal getStover3eraHoja() { return stover3eraHoja; }
    public void setStover3eraHoja(BigDecimal stover3eraHoja) { this.stover3eraHoja = stover3eraHoja; }
    public BigDecimal getStover4taHoja() { return stover4taHoja; }
    public void setStover4taHoja(BigDecimal stover4taHoja) { this.stover4taHoja = stover4taHoja; }
    public BigDecimal getStover5taHoja() { return stover5taHoja; }
    public void setStover5taHoja(BigDecimal stover5taHoja) { this.stover5taHoja = stover5taHoja; }
    public BigDecimal getStoverPromedio() { return stoverPromedio; }
    public void setStoverPromedio(BigDecimal stoverPromedio) { this.stoverPromedio = stoverPromedio; }
    public String getNivelInfeccion() { return nivelInfeccion; }
    public void setNivelInfeccion(String nivelInfeccion) { this.nivelInfeccion = nivelInfeccion; }
}
