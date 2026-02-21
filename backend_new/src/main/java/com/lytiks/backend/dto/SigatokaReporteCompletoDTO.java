package com.lytiks.backend.dto;

import com.lytiks.backend.entity.*;
import java.util.List;

public class SigatokaReporteCompletoDTO {
    // Encabezado
    private SigatokaEvaluacion evaluacion;
    
    // Lotes y muestras
    private List<SigatokaLote> lotes;
    private List<SigatokaMuestraCompleta> muestras;
    
    // Cálculos
    private SigatokaResumen resumen;
    private SigatokaIndicadores indicadores;
    private SigatokaEstadoEvolutivo estadoEvolutivo;
    private SigatokaStoverPromedio stoverPromedio;

    public SigatokaReporteCompletoDTO() {}

    public SigatokaEvaluacion getEvaluacion() { return evaluacion; }
    public void setEvaluacion(SigatokaEvaluacion evaluacion) { this.evaluacion = evaluacion; }

    public List<SigatokaLote> getLotes() { return lotes; }
    public void setLotes(List<SigatokaLote> lotes) { this.lotes = lotes; }

    public List<SigatokaMuestraCompleta> getMuestras() { return muestras; }
    public void setMuestras(List<SigatokaMuestraCompleta> muestras) { this.muestras = muestras; }

    public SigatokaResumen getResumen() { return resumen; }
    public void setResumen(SigatokaResumen resumen) { this.resumen = resumen; }

    public SigatokaIndicadores getIndicadores() { return indicadores; }
    public void setIndicadores(SigatokaIndicadores indicadores) { this.indicadores = indicadores; }

    public SigatokaEstadoEvolutivo getEstadoEvolutivo() { return estadoEvolutivo; }
    public void setEstadoEvolutivo(SigatokaEstadoEvolutivo estadoEvolutivo) { this.estadoEvolutivo = estadoEvolutivo; }

    public SigatokaStoverPromedio getStoverPromedio() { return stoverPromedio; }
    public void setStoverPromedio(SigatokaStoverPromedio stoverPromedio) { this.stoverPromedio = stoverPromedio; }
}
