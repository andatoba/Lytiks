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
    private BigDecimal ee3eraHoja; // EE3era = f×120×k
    
    @Column(name = "ee_4ta_hoja", precision = 10, scale = 2)
    private BigDecimal ee4taHoja; // EE4ta = f×100×k
    
    @Column(name = "ee_5ta_hoja", precision = 10, scale = 2)
    private BigDecimal ee5taHoja; // EE5ta = f×80×k
    
    @Column(name = "nivel_infeccion", length = 50)
    private String nivelInfeccion;
}
