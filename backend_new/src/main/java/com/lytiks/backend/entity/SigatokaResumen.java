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
    private BigDecimal promedioHojasEmitidas; // a
    
    @Column(name = "promedio_hojas_erectas", precision = 10, scale = 2)
    private BigDecimal promedioHojasErectas; // b
    
    @Column(name = "promedio_hojas_sintomas", precision = 10, scale = 2)
    private BigDecimal promedioHojasSintomas; // c
    
    @Column(name = "promedio_hoja_joven_enferma", precision = 10, scale = 2)
    private BigDecimal promedioHojaJovenEnferma; // d
    
    @Column(name = "promedio_hoja_joven_necrosada", precision = 10, scale = 2)
    private BigDecimal promedioHojaJovenNecrosada; // e
}
