package com.lytiks.backend.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import java.math.BigDecimal;

/**
 * Representa una muestra individual de Sigatoka
 * Incluye TODOS los campos del formato Excel
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "sigatoka_muestra")
public class SigatokaMuestraCompleta {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @JsonIgnore
    @ManyToOne
    @JoinColumn(name = "lote_id", nullable = false)
    private SigatokaLote lote;
    
    @Column(name = "muestra_num", nullable = false)
    private Integer muestraNum;
    
    // === GRADOS DE INFECCIÓN (3era, 4ta, 5ta hoja) ===
    @Column(name = "hoja_3era", length = 10)
    private String hoja3era; // ej: "2a", "3c"
    
    @Column(name = "hoja_4ta", length = 10)
    private String hoja4ta;
    
    @Column(name = "hoja_5ta", length = 10)
    private String hoja5ta;
    
    // === TOTAL DE HOJAS POR NIVEL ===
    @Column(name = "total_hojas_3era")
    private Integer totalHojas3era;
    
    @Column(name = "total_hojas_4ta")
    private Integer totalHojas4ta;
    
    @Column(name = "total_hojas_5ta")
    private Integer totalHojas5ta;
    
    // === VARIABLES PARA CÁLCULOS (a-e) ===
    @Column(name = "plantas_muestreadas")
    private Integer plantasMuestreadas; // a)
    
    @Column(name = "plantas_con_lesiones")
    private Integer plantasConLesiones; // b)
    
    @Column(name = "total_lesiones")
    private Integer totalLesiones; // c)
    
    @Column(name = "plantas_3er_estadio")
    private Integer plantas3erEstadio; // d)
    
    @Column(name = "total_letras")
    private Integer totalLetras; // e)
    
    // === VALORES STOVER 0 SEMANAS ===
    @Column(name = "h_v_l_e_0w", precision = 5, scale = 2)
    private BigDecimal hvle0w; // H.V.L.E.
    
    @Column(name = "h_v_l_q_0w", precision = 5, scale = 2)
    private BigDecimal hvlq0w; // H.V.L.Q.
    
    @Column(name = "h_v_l_q5_0w", precision = 5, scale = 2)
    private BigDecimal hvlq5_0w; // H.V.L.Q.5%
    
    @Column(name = "t_h_0w", precision = 5, scale = 2)
    private BigDecimal th0w; // T.H.
    
    // === VALORES STOVER 10 SEMANAS ===
    @Column(name = "h_v_l_e_10w", precision = 5, scale = 2)
    private BigDecimal hvle10w;
    
    @Column(name = "h_v_l_q_10w", precision = 5, scale = 2)
    private BigDecimal hvlq10w;
    
    @Column(name = "h_v_l_q5_10w", precision = 5, scale = 2)
    private BigDecimal hvlq5_10w;
    
    @Column(name = "t_h_10w", precision = 5, scale = 2)
    private BigDecimal th10w;
}
