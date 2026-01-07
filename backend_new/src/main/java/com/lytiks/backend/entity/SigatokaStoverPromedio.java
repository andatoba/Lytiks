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
}
