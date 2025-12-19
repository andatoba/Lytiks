package com.lytiks.backend.dto;

import lombok.Data;
import lombok.Getter;
import lombok.Setter;
import java.math.BigDecimal;

@Data
@Getter
@Setter
public class SigatokaMuestraCompletaDTO {
    private Integer muestraNum;
    
    // Grados de infección
    private String hoja3era;
    private String hoja4ta;
    private String hoja5ta;
    
    // Total hojas
    private Integer totalHojas3era;
    private Integer totalHojas4ta;
    private Integer totalHojas5ta;
    
    // Variables para cálculos (a-e)
    private Integer plantasMuestreadas;
    private Integer plantasConLesiones;
    private Integer totalLesiones;
    private Integer plantas3erEstadio;
    private Integer totalLetras;
    
    // Stover 0 semanas
    private BigDecimal hvle0w;
    private BigDecimal hvlq0w;
    private BigDecimal hvlq5_0w;
    private BigDecimal th0w;
    
    // Stover 10 semanas
    private BigDecimal hvle10w;
    private BigDecimal hvlq10w;
    private BigDecimal hvlq5_10w;
    private BigDecimal th10w;
}
