package com.lytiks.backend.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import java.math.BigDecimal;
import java.util.Objects;

@Entity
@Table(name = "sigatoka_indicadores")
public class SigatokaIndicadores {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @JsonIgnore
    @OneToOne
    @JoinColumn(name = "evaluacion_id", nullable = false, unique = true)
    private SigatokaEvaluacion evaluacion;
    
    @Column(name = "incidencia_promedio", precision = 10, scale = 2)
    private BigDecimal incidenciaPromedio;
    
    @Column(name = "severidad_promedio", precision = 10, scale = 2)
    private BigDecimal severidadPromedio;
    
    @Column(name = "indice_hojas_erectas", precision = 10, scale = 2)
    private BigDecimal indiceHojasErectas;
    
    @Column(name = "ritmo_emision", precision = 10, scale = 2)
    private BigDecimal ritmoEmision;
    
    @Column(name = "velocidad_evolucion", precision = 10, scale = 2)
    private BigDecimal velocidadEvolucion;
    
    @Column(name = "velocidad_necrosis", precision = 10, scale = 2)
    private BigDecimal velocidadNecrosis;

    public SigatokaIndicadores() {}

    public SigatokaIndicadores(Long id, SigatokaEvaluacion evaluacion, BigDecimal incidenciaPromedio,
            BigDecimal severidadPromedio, BigDecimal indiceHojasErectas, BigDecimal ritmoEmision,
            BigDecimal velocidadEvolucion, BigDecimal velocidadNecrosis) {
        this.id = id; this.evaluacion = evaluacion; this.incidenciaPromedio = incidenciaPromedio;
        this.severidadPromedio = severidadPromedio; this.indiceHojasErectas = indiceHojasErectas;
        this.ritmoEmision = ritmoEmision; this.velocidadEvolucion = velocidadEvolucion;
        this.velocidadNecrosis = velocidadNecrosis;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public SigatokaEvaluacion getEvaluacion() { return evaluacion; }
    public void setEvaluacion(SigatokaEvaluacion evaluacion) { this.evaluacion = evaluacion; }
    public BigDecimal getIncidenciaPromedio() { return incidenciaPromedio; }
    public void setIncidenciaPromedio(BigDecimal incidenciaPromedio) { this.incidenciaPromedio = incidenciaPromedio; }
    public BigDecimal getSeveridadPromedio() { return severidadPromedio; }
    public void setSeveridadPromedio(BigDecimal severidadPromedio) { this.severidadPromedio = severidadPromedio; }
    public BigDecimal getIndiceHojasErectas() { return indiceHojasErectas; }
    public void setIndiceHojasErectas(BigDecimal indiceHojasErectas) { this.indiceHojasErectas = indiceHojasErectas; }
    public BigDecimal getRitmoEmision() { return ritmoEmision; }
    public void setRitmoEmision(BigDecimal ritmoEmision) { this.ritmoEmision = ritmoEmision; }
    public BigDecimal getVelocidadEvolucion() { return velocidadEvolucion; }
    public void setVelocidadEvolucion(BigDecimal velocidadEvolucion) { this.velocidadEvolucion = velocidadEvolucion; }
    public BigDecimal getVelocidadNecrosis() { return velocidadNecrosis; }
    public void setVelocidadNecrosis(BigDecimal velocidadNecrosis) { this.velocidadNecrosis = velocidadNecrosis; }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        SigatokaIndicadores that = (SigatokaIndicadores) o;
        return Objects.equals(id, that.id);
    }

    @Override
    public int hashCode() { return Objects.hash(id); }
}
