package com.lytiks.backend.entity;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.util.Objects;

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
    
    @Column(name = "promedio_hojas_emitidas", precision = 10, scale = 2)
    private BigDecimal promedioHojasEmitidas;
    
    @Column(name = "promedio_hojas_erectas", precision = 10, scale = 2)
    private BigDecimal promedioHojasErectas;
    
    @Column(name = "promedio_hojas_sintomas", precision = 10, scale = 2)
    private BigDecimal promedioHojasSintomas;
    
    @Column(name = "promedio_hoja_joven_enferma", precision = 10, scale = 2)
    private BigDecimal promedioHojaJovenEnferma;
    
    @Column(name = "promedio_hoja_joven_necrosada", precision = 10, scale = 2)
    private BigDecimal promedioHojaJovenNecrosada;

    public SigatokaMuestra() {
    }

    public SigatokaMuestra(Long id, SigatokaEvaluacion evaluacion, Integer numeroMuestra, String lote, 
            String variedad, String edad, Integer hojasEmitidas, Integer hojasErectas, 
            Integer hojasConSintomas, Integer hojaMasJovenEnferma, Integer hojaMasJovenNecrosada,
            BigDecimal promedioHojasEmitidas, BigDecimal promedioHojasErectas, 
            BigDecimal promedioHojasSintomas, BigDecimal promedioHojaJovenEnferma, 
            BigDecimal promedioHojaJovenNecrosada) {
        this.id = id;
        this.evaluacion = evaluacion;
        this.numeroMuestra = numeroMuestra;
        this.lote = lote;
        this.variedad = variedad;
        this.edad = edad;
        this.hojasEmitidas = hojasEmitidas;
        this.hojasErectas = hojasErectas;
        this.hojasConSintomas = hojasConSintomas;
        this.hojaMasJovenEnferma = hojaMasJovenEnferma;
        this.hojaMasJovenNecrosada = hojaMasJovenNecrosada;
        this.promedioHojasEmitidas = promedioHojasEmitidas;
        this.promedioHojasErectas = promedioHojasErectas;
        this.promedioHojasSintomas = promedioHojasSintomas;
        this.promedioHojaJovenEnferma = promedioHojaJovenEnferma;
        this.promedioHojaJovenNecrosada = promedioHojaJovenNecrosada;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public SigatokaEvaluacion getEvaluacion() { return evaluacion; }
    public void setEvaluacion(SigatokaEvaluacion evaluacion) { this.evaluacion = evaluacion; }
    public Integer getNumeroMuestra() { return numeroMuestra; }
    public void setNumeroMuestra(Integer numeroMuestra) { this.numeroMuestra = numeroMuestra; }
    public String getLote() { return lote; }
    public void setLote(String lote) { this.lote = lote; }
    public String getVariedad() { return variedad; }
    public void setVariedad(String variedad) { this.variedad = variedad; }
    public String getEdad() { return edad; }
    public void setEdad(String edad) { this.edad = edad; }
    public Integer getHojasEmitidas() { return hojasEmitidas; }
    public void setHojasEmitidas(Integer hojasEmitidas) { this.hojasEmitidas = hojasEmitidas; }
    public Integer getHojasErectas() { return hojasErectas; }
    public void setHojasErectas(Integer hojasErectas) { this.hojasErectas = hojasErectas; }
    public Integer getHojasConSintomas() { return hojasConSintomas; }
    public void setHojasConSintomas(Integer hojasConSintomas) { this.hojasConSintomas = hojasConSintomas; }
    public Integer getHojaMasJovenEnferma() { return hojaMasJovenEnferma; }
    public void setHojaMasJovenEnferma(Integer hojaMasJovenEnferma) { this.hojaMasJovenEnferma = hojaMasJovenEnferma; }
    public Integer getHojaMasJovenNecrosada() { return hojaMasJovenNecrosada; }
    public void setHojaMasJovenNecrosada(Integer hojaMasJovenNecrosada) { this.hojaMasJovenNecrosada = hojaMasJovenNecrosada; }
    public BigDecimal getPromedioHojasEmitidas() { return promedioHojasEmitidas; }
    public void setPromedioHojasEmitidas(BigDecimal promedioHojasEmitidas) { this.promedioHojasEmitidas = promedioHojasEmitidas; }
    public BigDecimal getPromedioHojasErectas() { return promedioHojasErectas; }
    public void setPromedioHojasErectas(BigDecimal promedioHojasErectas) { this.promedioHojasErectas = promedioHojasErectas; }
    public BigDecimal getPromedioHojasSintomas() { return promedioHojasSintomas; }
    public void setPromedioHojasSintomas(BigDecimal promedioHojasSintomas) { this.promedioHojasSintomas = promedioHojasSintomas; }
    public BigDecimal getPromedioHojaJovenEnferma() { return promedioHojaJovenEnferma; }
    public void setPromedioHojaJovenEnferma(BigDecimal promedioHojaJovenEnferma) { this.promedioHojaJovenEnferma = promedioHojaJovenEnferma; }
    public BigDecimal getPromedioHojaJovenNecrosada() { return promedioHojaJovenNecrosada; }
    public void setPromedioHojaJovenNecrosada(BigDecimal promedioHojaJovenNecrosada) { this.promedioHojaJovenNecrosada = promedioHojaJovenNecrosada; }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        SigatokaMuestra that = (SigatokaMuestra) o;
        return Objects.equals(id, that.id);
    }

    @Override
    public int hashCode() {
        return Objects.hash(id);
    }
}
