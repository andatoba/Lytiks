package com.lytiks.backend.dto;

import java.math.BigDecimal;

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

    public SigatokaMuestraCompletaDTO() {}

    public Integer getMuestraNum() { return muestraNum; }
    public void setMuestraNum(Integer muestraNum) { this.muestraNum = muestraNum; }

    public String getHoja3era() { return hoja3era; }
    public void setHoja3era(String hoja3era) { this.hoja3era = hoja3era; }

    public String getHoja4ta() { return hoja4ta; }
    public void setHoja4ta(String hoja4ta) { this.hoja4ta = hoja4ta; }

    public String getHoja5ta() { return hoja5ta; }
    public void setHoja5ta(String hoja5ta) { this.hoja5ta = hoja5ta; }

    public Integer getTotalHojas3era() { return totalHojas3era; }
    public void setTotalHojas3era(Integer totalHojas3era) { this.totalHojas3era = totalHojas3era; }

    public Integer getTotalHojas4ta() { return totalHojas4ta; }
    public void setTotalHojas4ta(Integer totalHojas4ta) { this.totalHojas4ta = totalHojas4ta; }

    public Integer getTotalHojas5ta() { return totalHojas5ta; }
    public void setTotalHojas5ta(Integer totalHojas5ta) { this.totalHojas5ta = totalHojas5ta; }

    public Integer getPlantasMuestreadas() { return plantasMuestreadas; }
    public void setPlantasMuestreadas(Integer plantasMuestreadas) { this.plantasMuestreadas = plantasMuestreadas; }

    public Integer getPlantasConLesiones() { return plantasConLesiones; }
    public void setPlantasConLesiones(Integer plantasConLesiones) { this.plantasConLesiones = plantasConLesiones; }

    public Integer getTotalLesiones() { return totalLesiones; }
    public void setTotalLesiones(Integer totalLesiones) { this.totalLesiones = totalLesiones; }

    public Integer getPlantas3erEstadio() { return plantas3erEstadio; }
    public void setPlantas3erEstadio(Integer plantas3erEstadio) { this.plantas3erEstadio = plantas3erEstadio; }

    public Integer getTotalLetras() { return totalLetras; }
    public void setTotalLetras(Integer totalLetras) { this.totalLetras = totalLetras; }

    public BigDecimal getHvle0w() { return hvle0w; }
    public void setHvle0w(BigDecimal hvle0w) { this.hvle0w = hvle0w; }

    public BigDecimal getHvlq0w() { return hvlq0w; }
    public void setHvlq0w(BigDecimal hvlq0w) { this.hvlq0w = hvlq0w; }

    public BigDecimal getHvlq5_0w() { return hvlq5_0w; }
    public void setHvlq5_0w(BigDecimal hvlq5_0w) { this.hvlq5_0w = hvlq5_0w; }

    public BigDecimal getTh0w() { return th0w; }
    public void setTh0w(BigDecimal th0w) { this.th0w = th0w; }

    public BigDecimal getHvle10w() { return hvle10w; }
    public void setHvle10w(BigDecimal hvle10w) { this.hvle10w = hvle10w; }

    public BigDecimal getHvlq10w() { return hvlq10w; }
    public void setHvlq10w(BigDecimal hvlq10w) { this.hvlq10w = hvlq10w; }

    public BigDecimal getHvlq5_10w() { return hvlq5_10w; }
    public void setHvlq5_10w(BigDecimal hvlq5_10w) { this.hvlq5_10w = hvlq5_10w; }

    public BigDecimal getTh10w() { return th10w; }
    public void setTh10w(BigDecimal th10w) { this.th10w = th10w; }
}
