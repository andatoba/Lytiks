package com.lytiks.backend.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import java.math.BigDecimal;

@Data
@NoArgsConstructor
@AllArgsConstructor
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
    private BigDecimal incidenciaPromedio; // f = c/a
    
    @Column(name = "severidad_promedio", precision = 10, scale = 2)
    private BigDecimal severidadPromedio; // g = (d/b)×100
    
    @Column(name = "indice_hojas_erectas", precision = 10, scale = 2)
    private BigDecimal indiceHojasErectas; // h = (b/a)×100
    
    @Column(name = "ritmo_emision", precision = 10, scale = 2)
    private BigDecimal ritmoEmision; // i
    
    @Column(name = "velocidad_evolucion", precision = 10, scale = 2)
    private BigDecimal velocidadEvolucion; // j = i/a
    
    @Column(name = "velocidad_necrosis", precision = 10, scale = 2)
    private BigDecimal velocidadNecrosis; // k = e/a
}
