package com.lytiks.backend.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

@Entity
@Table(name = "sigatoka_evaluacion")
public class SigatokaEvaluacion {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "cliente_id", nullable = false)
    private Long clienteId;
    
    @Column(nullable = false, length = 200)
    private String hacienda;
    
    @Column(nullable = false)
    private LocalDate fecha;
    
    @Column(name = "semana_epidemiologica")
    private Integer semanaEpidemiologica;
    
    @Column(length = 50)
    private String periodo;
    
    @Column(nullable = false, length = 100)
    private String evaluador;
    
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;
    
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
    
    @OneToMany(mappedBy = "evaluacion", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<SigatokaLote> lotes = new ArrayList<>();
    
    @JsonIgnore
    @OneToOne(mappedBy = "evaluacion", cascade = CascadeType.ALL, orphanRemoval = true)
    private SigatokaResumen resumen;
    
    @JsonIgnore
    @OneToOne(mappedBy = "evaluacion", cascade = CascadeType.ALL, orphanRemoval = true)
    private SigatokaIndicadores indicadores;
    
    @JsonIgnore
    @OneToOne(mappedBy = "evaluacion", cascade = CascadeType.ALL, orphanRemoval = true)
    private SigatokaEstadoEvolutivo estadoEvolutivo;
    
    @JsonIgnore
    @OneToOne(mappedBy = "evaluacion", cascade = CascadeType.ALL, orphanRemoval = true)
    private SigatokaStoverPromedio stoverPromedio;
    
    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }
    
    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }

    public SigatokaEvaluacion() {}

    public SigatokaEvaluacion(Long id, Long clienteId, String hacienda, LocalDate fecha,
            Integer semanaEpidemiologica, String periodo, String evaluador, LocalDateTime createdAt,
            LocalDateTime updatedAt, List<SigatokaLote> lotes, SigatokaResumen resumen,
            SigatokaIndicadores indicadores, SigatokaEstadoEvolutivo estadoEvolutivo,
            SigatokaStoverPromedio stoverPromedio) {
        this.id = id; this.clienteId = clienteId; this.hacienda = hacienda; this.fecha = fecha;
        this.semanaEpidemiologica = semanaEpidemiologica; this.periodo = periodo;
        this.evaluador = evaluador; this.createdAt = createdAt; this.updatedAt = updatedAt;
        this.lotes = lotes; this.resumen = resumen; this.indicadores = indicadores;
        this.estadoEvolutivo = estadoEvolutivo; this.stoverPromedio = stoverPromedio;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Long getClienteId() { return clienteId; }
    public void setClienteId(Long clienteId) { this.clienteId = clienteId; }
    public String getHacienda() { return hacienda; }
    public void setHacienda(String hacienda) { this.hacienda = hacienda; }
    public LocalDate getFecha() { return fecha; }
    public void setFecha(LocalDate fecha) { this.fecha = fecha; }
    public Integer getSemanaEpidemiologica() { return semanaEpidemiologica; }
    public void setSemanaEpidemiologica(Integer semanaEpidemiologica) { this.semanaEpidemiologica = semanaEpidemiologica; }
    public String getPeriodo() { return periodo; }
    public void setPeriodo(String periodo) { this.periodo = periodo; }
    public String getEvaluador() { return evaluador; }
    public void setEvaluador(String evaluador) { this.evaluador = evaluador; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
    public List<SigatokaLote> getLotes() { return lotes; }
    public void setLotes(List<SigatokaLote> lotes) { this.lotes = lotes; }
    public SigatokaResumen getResumen() { return resumen; }
    public void setResumen(SigatokaResumen resumen) { this.resumen = resumen; }
    public SigatokaIndicadores getIndicadores() { return indicadores; }
    public void setIndicadores(SigatokaIndicadores indicadores) { this.indicadores = indicadores; }
    public SigatokaEstadoEvolutivo getEstadoEvolutivo() { return estadoEvolutivo; }
    public void setEstadoEvolutivo(SigatokaEstadoEvolutivo estadoEvolutivo) { this.estadoEvolutivo = estadoEvolutivo; }
    public SigatokaStoverPromedio getStoverPromedio() { return stoverPromedio; }
    public void setStoverPromedio(SigatokaStoverPromedio stoverPromedio) { this.stoverPromedio = stoverPromedio; }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        SigatokaEvaluacion that = (SigatokaEvaluacion) o;
        return Objects.equals(id, that.id);
    }

    @Override
    public int hashCode() { return Objects.hash(id); }
}
