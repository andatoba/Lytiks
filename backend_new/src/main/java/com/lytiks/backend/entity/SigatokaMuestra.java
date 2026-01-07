package com.lytiks.backend.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import java.math.BigDecimal;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "sigatoka_muestra")
public class SigatokaMuestra {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne
    @JoinColumn(name = "evaluacion_id", nullable = false)
    private SigatokaEvaluacion evaluacion;
    
    @Column(name = "numero_muestra", nullable = false)
    private Integer numeroMuestra;
    
    @Column(nullable = false, length = 100)
    private String lote;
    
    @Column(length = 50)
    private String variedad;
    
    @Column(length = 50)
    private String edad;
    
    @Column(name = "hojas_emitidas")
    private Integer hojasEmitidas;
    
    @Column(name = "hojas_erectas")
    private Integer hojasErectas;
    
    @Column(name = "hojas_con_sintomas")
    private Integer hojasConSintomas;
    
    @Column(name = "hoja_mas_joven_enferma")
    private Integer hojaMasJovenEnferma;
    
    @Column(name = "hoja_mas_joven_necrosada")
    private Integer hojaMasJovenNecrosada;
    
    // Campos calculados (fórmulas a-e)
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
