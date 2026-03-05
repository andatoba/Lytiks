package com.lytiks.backend.dto;

import java.math.BigDecimal;
import java.util.Map;

/**
 * DTO unificado para recibir TODOS los datos calculados desde el frontend
 * en un solo POST
 */
public class SigatokaResumenCompletoInputDTO {
    
    private Map<String, Object> resumen;
    private Map<String, Object> indicadores;
    private Map<String, Object> stover;

    // Getters y Setters
    public Map<String, Object> getResumen() { return resumen; }
    public void setResumen(Map<String, Object> resumen) { this.resumen = resumen; }
    
    public Map<String, Object> getIndicadores() { return indicadores; }
    public void setIndicadores(Map<String, Object> indicadores) { this.indicadores = indicadores; }
    
    public Map<String, Object> getStover() { return stover; }
    public void setStover(Map<String, Object> stover) { this.stover = stover; }
    
    // Métodos helper para obtener valores de resumen
    public BigDecimal getResumenBigDecimal(String key) {
        if (resumen == null || !resumen.containsKey(key)) return null;
        Object val = resumen.get(key);
        if (val == null) return null;
        if (val instanceof BigDecimal) return (BigDecimal) val;
        if (val instanceof Number) return BigDecimal.valueOf(((Number) val).doubleValue());
        return new BigDecimal(val.toString());
    }
    
    public Integer getResumenInteger(String key) {
        if (resumen == null || !resumen.containsKey(key)) return null;
        Object val = resumen.get(key);
        if (val == null) return null;
        if (val instanceof Integer) return (Integer) val;
        if (val instanceof Number) return ((Number) val).intValue();
        return Integer.parseInt(val.toString());
    }
    
    // Métodos helper para obtener valores de indicadores
    public BigDecimal getIndicadorBigDecimal(String key) {
        if (indicadores == null || !indicadores.containsKey(key)) return null;
        Object val = indicadores.get(key);
        if (val == null) return null;
        if (val instanceof BigDecimal) return (BigDecimal) val;
        if (val instanceof Number) return BigDecimal.valueOf(((Number) val).doubleValue());
        return new BigDecimal(val.toString());
    }
    
    // Métodos helper para obtener valores de stover
    public BigDecimal getStoverBigDecimal(String key) {
        if (stover == null || !stover.containsKey(key)) return null;
        Object val = stover.get(key);
        if (val == null) return null;
        if (val instanceof BigDecimal) return (BigDecimal) val;
        if (val instanceof Number) return BigDecimal.valueOf(((Number) val).doubleValue());
        return new BigDecimal(val.toString());
    }
}
