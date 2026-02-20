package com.lytiks.backend.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import java.math.BigDecimal;
import java.util.Objects;

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
    
    @Column(name = "hoja_3era", length = 10)
    private String hoja3era;
    
    @Column(name = "hoja_4ta", length = 10)
    private String hoja4ta;
    
    @Column(name = "hoja_5ta", length = 10)
    private String hoja5ta;
    
    @Column(name = "total_hojas_3era")
    private Integer totalHojas3era;
    
    @Column(name = "total_hojas_4ta")
    private Integer totalHojas4ta;
    
    @Column(name = "total_hojas_5ta")
    private Integer totalHojas5ta;
    
    @Column(name = "plantas_muestreadas")
    private Integer plantasMuestreadas;
    
    @Column(name = "plantas_con_lesiones")
    private Integer plantasConLesiones;
    
    @Column(name = "total_lesiones")
    private Integer totalLesiones;
    
    @Column(name = "plantas_3er_estadio")
    private Integer plantas3erEstadio;
    
    @Column(name = "total_letras")
    private Integer totalLetras;
    
    @Column(name = "h_v_l_e_0w", precision = 5, scale = 2)
    private BigDecimal hvle0w;
    
    @Column(name = "h_v_l_q_0w", precision = 5, scale = 2)
    private BigDecimal hvlq0w;
    
    @Column(name = "h_v_l_q5_0w", precision = 5, scale = 2)
    private BigDecimal hvlq5_0w;
    
    @Column(name = "t_h_0w", precision = 5, scale = 2)
    private BigDecimal th0w;
    
    @Column(name = "h_v_l_e_10w", precision = 5, scale = 2)
    private BigDecimal hvle10w;
    
    @Column(name = "h_v_l_q_10w", precision = 5, scale = 2)
    private BigDecimal hvlq10w;
    
    @Column(name = "h_v_l_q5_10w", precision = 5, scale = 2)
    private BigDecimal hvlq5_10w;
    
    @Column(name = "t_h_10w", precision = 5, scale = 2)
    private BigDecimal th10w;

    public SigatokaMuestraCompleta() {}

    public SigatokaMuestraCompleta(Long id, SigatokaLote lote, Integer muestraNum, String hoja3era,
            String hoja4ta, String hoja5ta, Integer totalHojas3era, Integer totalHojas4ta,
            Integer totalHojas5ta, Integer plantasMuestreadas, Integer plantasConLesiones,
            Integer totalLesiones, Integer plantas3erEstadio, Integer totalLetras,
            BigDecimal hvle0w, BigDecimal hvlq0w, BigDecimal hvlq5_0w, BigDecimal th0w,
            BigDecimal hvle10w, BigDecimal hvlq10w, BigDecimal hvlq5_10w, BigDecimal th10w) {
        this.id = id; this.lote = lote; this.muestraNum = muestraNum; this.hoja3era = hoja3era;
        this.hoja4ta = hoja4ta; this.hoja5ta = hoja5ta; this.totalHojas3era = totalHojas3era;
        this.totalHojas4ta = totalHojas4ta; this.totalHojas5ta = totalHojas5ta;
        this.plantasMuestreadas = plantasMuestreadas; this.plantasConLesiones = plantasConLesiones;
        this.totalLesiones = totalLesiones; this.plantas3erEstadio = plantas3erEstadio;
        this.totalLetras = totalLetras; this.hvle0w = hvle0w; this.hvlq0w = hvlq0w;
        this.hvlq5_0w = hvlq5_0w; this.th0w = th0w; this.hvle10w = hvle10w;
        this.hvlq10w = hvlq10w; this.hvlq5_10w = hvlq5_10w; this.th10w = th10w;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public SigatokaLote getLote() { return lote; }
    public void setLote(SigatokaLote lote) { this.lote = lote; }
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

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        SigatokaMuestraCompleta that = (SigatokaMuestraCompleta) o;
        return Objects.equals(id, that.id);
    }

    @Override
    public int hashCode() { return Objects.hash(id); }
}
