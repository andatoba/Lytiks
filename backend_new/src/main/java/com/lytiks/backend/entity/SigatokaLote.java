package com.lytiks.backend.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "sigatoka_lote")
public class SigatokaLote {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @JsonIgnore
    @ManyToOne
    @JoinColumn(name = "evaluacion_id", nullable = false)
    private SigatokaEvaluacion evaluacion;
    
    @Column(name = "lote_codigo", nullable = false, length = 100)
    private String loteCodigo;

    @Column(name = "latitud")
    private Double latitud;

    @Column(name = "longitud")
    private Double longitud;
    
    @OneToMany(mappedBy = "lote", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<SigatokaMuestraCompleta> muestras = new ArrayList<>();

    public SigatokaLote() {}

    public SigatokaLote(Long id, SigatokaEvaluacion evaluacion, String loteCodigo,
            Double latitud, Double longitud, List<SigatokaMuestraCompleta> muestras) {
        this.id = id;
        this.evaluacion = evaluacion;
        this.loteCodigo = loteCodigo;
        this.latitud = latitud;
        this.longitud = longitud;
        this.muestras = muestras;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public SigatokaEvaluacion getEvaluacion() { return evaluacion; }
    public void setEvaluacion(SigatokaEvaluacion evaluacion) { this.evaluacion = evaluacion; }
    public String getLoteCodigo() { return loteCodigo; }
    public void setLoteCodigo(String loteCodigo) { this.loteCodigo = loteCodigo; }
    public Double getLatitud() { return latitud; }
    public void setLatitud(Double latitud) { this.latitud = latitud; }
    public Double getLongitud() { return longitud; }
    public void setLongitud(Double longitud) { this.longitud = longitud; }
    public List<SigatokaMuestraCompleta> getMuestras() { return muestras; }
    public void setMuestras(List<SigatokaMuestraCompleta> muestras) { this.muestras = muestras; }
}
