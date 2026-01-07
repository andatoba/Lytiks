package com.lytiks.backend.dto;

import com.lytiks.backend.entity.*;
import lombok.Data;
import java.util.List;

@Data
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
}
