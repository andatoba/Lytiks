package com.lytiks.backend.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import java.math.BigDecimal;
import java.util.Objects;

@Entity
@Table(name = "sigatoka_resumen")
public class SigatokaResumen {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @JsonIgnore
    @OneToOne
    @JoinColumn(name = "evaluacion_id", nullable = false, unique = true)
    private SigatokaEvaluacion evaluacion;
    
    @Column(name = "promedio_hojas_emitidas", precision = 10, scale = 2)
    private BigDecimal promedioHojasEmitidas;
    
    @Column(name = "promedio_hojas_erectas", precision = 10, scale = 2)
    private BigDecimal promedioHojasErectas;
    
    @Column(name = "promedio_hojas_sintomas", precision = 10, scale = 2)
    private BigDecimal promedioHojasSintomas;
    
    @Column(name = "promedio_hoja_joven_enferma", precision = 10, scale = 2)
    private BigDecimal promedioHojaJovenEnferma;
    
    @Column(name = "promedio_hoja_joven_necrosada", precision = 10, scale = 2)
    private BigDecimal promedioHojaJovenNecrosada;

    public SigatokaResumen() {}

    public SigatokaResumen(Long id, SigatokaEvaluacion evaluacion, BigDecimal promedioHojasEmitidas,
            BigDecimal promedioHojasErectas, BigDecimal promedioHojasSintomas,
            BigDecimal promedioHojaJovenEnferma, BigDecimal promedioHojaJovenNecrosada) {
        this.id = id;
        this.evaluacion = evaluacion;
        this.promedioHojasEmitidas = promedioHojasEmitidas;
        this.promedioHojasErectas = promedioHojasErectas;
        this.promedioHojasSintomas = promedioHojasSintomas;
        this.promedioHojaJovenEnferma = promedioHojaJovenEnferma;
        this.promedioHojaJovenNecrosada = promedioHojaJovenNecrosada;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public SigatokaEvaluacion getEvaluacion() { return evaluacion; }
    public void setEvaluacion(SigatokaEvaluacion evaluacion) { this.evaluacion = evaluacion; }
    public BigDecimal getPromedioHojasEmitidas() { return promedioHojasEmitidas; }
    public void setPromedioHojasEmitidas(BigDecimal promedioHojasEmitidas) { this.promedioHojasEmitidas = promedioHojasEmitidas; }
    public BigDecimal getPromedioHojasErectas() { return promedioHojasErectas; }
    public void setPromedioHojasErectas(BigDecimal promedioHojasErectas) { this.promedioHojasErectas = promedioHojasErectas; }
    public BigDecimal getPromedioHojasSintomas() { return promedioHojasSintomas; }
    public void setPromedioHojasSintomas(BigDecimal promedioHojasSintomas) { this.promedioHojasSintomas = promedioHojasSintomas; }
    public BigDecimal getPromedioHojaJovenEnferma() { return promedioHojaJovenEnferma; }
    public void setPromedioHojaJovenEnferma(BigDecimal promedioHojaJovenEnferma) { this.promedioHojaJovenEnferma = promedioHojaJovenEnferma; }
    public BigDecimal getPromedioHojaJovenNecrosada() { return promedioHojaJovenNecrosada; }
    public void setPromedioHojaJovenNecrosada(BigDecimal promedioHojaJovenNecrosada) { this.promedioHojaJovenNecrosada = promedioHojaJovenNecrosada; }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        SigatokaResumen that = (SigatokaResumen) o;
        return Objects.equals(id, that.id);
    }

    @Override
    public int hashCode() { return Objects.hash(id); }
}
