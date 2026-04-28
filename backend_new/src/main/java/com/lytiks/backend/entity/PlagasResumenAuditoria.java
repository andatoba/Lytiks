package com.lytiks.backend.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "plagas_resumen_auditoria")
public class PlagasResumenAuditoria {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @JsonIgnore
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "client_id", nullable = false)
    private Client client;

    @Column(name = "tecnico_id")
    private Long tecnicoId;

    @Column(name = "fecha", nullable = false)
    private LocalDate fecha;

    @Column(name = "lote", nullable = false)
    private String lote;

    @Column(name = "plaga", nullable = false)
    private String plaga;

    @Column(name = "total_huevo")
    private Integer totalHuevo;

    @Column(name = "total_pequena")
    private Integer totalPequena;

    @Column(name = "total_mediana")
    private Integer totalMediana;

    @Column(name = "total_grande")
    private Integer totalGrande;

    @Column(name = "total_individuos")
    private Integer totalIndividuos;

    @Column(name = "porcentaje_danio", precision = 8, scale = 2)
    private BigDecimal porcentajeDanio;

    @Column(name = "promedio_huevo", precision = 8, scale = 2)
    private BigDecimal promedioHuevo;

    @Column(name = "promedio_pequena", precision = 8, scale = 2)
    private BigDecimal promedioPequena;

    @Column(name = "promedio_mediana", precision = 8, scale = 2)
    private BigDecimal promedioMediana;

    @Column(name = "promedio_grande", precision = 8, scale = 2)
    private BigDecimal promedioGrande;

    @Column(name = "promedio_total", precision = 8, scale = 2)
    private BigDecimal promedioTotal;

    @Column(name = "promedio_danio", precision = 8, scale = 2)
    private BigDecimal promedioDanio;

    @Column(name = "porcentaje_huevo", precision = 8, scale = 2)
    private BigDecimal porcentajeHuevo;

    @Column(name = "porcentaje_pequena", precision = 8, scale = 2)
    private BigDecimal porcentajePequena;

    @Column(name = "porcentaje_mediana", precision = 8, scale = 2)
    private BigDecimal porcentajeMediana;

    @Column(name = "porcentaje_grande", precision = 8, scale = 2)
    private BigDecimal porcentajeGrande;

    @Column(name = "numero_muestras")
    private Integer numeroMuestras;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    @PrePersist
    public void prePersist() {
        if (createdAt == null) {
            createdAt = LocalDateTime.now();
        }
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Client getClient() {
        return client;
    }

    public void setClient(Client client) {
        this.client = client;
    }

    public Long getTecnicoId() {
        return tecnicoId;
    }

    public void setTecnicoId(Long tecnicoId) {
        this.tecnicoId = tecnicoId;
    }

    public LocalDate getFecha() {
        return fecha;
    }

    public void setFecha(LocalDate fecha) {
        this.fecha = fecha;
    }

    public String getLote() {
        return lote;
    }

    public void setLote(String lote) {
        this.lote = lote;
    }

    public String getPlaga() {
        return plaga;
    }

    public void setPlaga(String plaga) {
        this.plaga = plaga;
    }

    public Integer getTotalHuevo() {
        return totalHuevo;
    }

    public void setTotalHuevo(Integer totalHuevo) {
        this.totalHuevo = totalHuevo;
    }

    public Integer getTotalPequena() {
        return totalPequena;
    }

    public void setTotalPequena(Integer totalPequena) {
        this.totalPequena = totalPequena;
    }

    public Integer getTotalMediana() {
        return totalMediana;
    }

    public void setTotalMediana(Integer totalMediana) {
        this.totalMediana = totalMediana;
    }

    public Integer getTotalGrande() {
        return totalGrande;
    }

    public void setTotalGrande(Integer totalGrande) {
        this.totalGrande = totalGrande;
    }

    public Integer getTotalIndividuos() {
        return totalIndividuos;
    }

    public void setTotalIndividuos(Integer totalIndividuos) {
        this.totalIndividuos = totalIndividuos;
    }

    public BigDecimal getPorcentajeDanio() {
        return porcentajeDanio;
    }

    public void setPorcentajeDanio(BigDecimal porcentajeDanio) {
        this.porcentajeDanio = porcentajeDanio;
    }

    public BigDecimal getPromedioHuevo() {
        return promedioHuevo;
    }

    public void setPromedioHuevo(BigDecimal promedioHuevo) {
        this.promedioHuevo = promedioHuevo;
    }

    public BigDecimal getPromedioPequena() {
        return promedioPequena;
    }

    public void setPromedioPequena(BigDecimal promedioPequena) {
        this.promedioPequena = promedioPequena;
    }

    public BigDecimal getPromedioMediana() {
        return promedioMediana;
    }

    public void setPromedioMediana(BigDecimal promedioMediana) {
        this.promedioMediana = promedioMediana;
    }

    public BigDecimal getPromedioGrande() {
        return promedioGrande;
    }

    public void setPromedioGrande(BigDecimal promedioGrande) {
        this.promedioGrande = promedioGrande;
    }

    public BigDecimal getPromedioTotal() {
        return promedioTotal;
    }

    public void setPromedioTotal(BigDecimal promedioTotal) {
        this.promedioTotal = promedioTotal;
    }

    public BigDecimal getPromedioDanio() {
        return promedioDanio;
    }

    public void setPromedioDanio(BigDecimal promedioDanio) {
        this.promedioDanio = promedioDanio;
    }

    public BigDecimal getPorcentajeHuevo() {
        return porcentajeHuevo;
    }

    public void setPorcentajeHuevo(BigDecimal porcentajeHuevo) {
        this.porcentajeHuevo = porcentajeHuevo;
    }

    public BigDecimal getPorcentajePequena() {
        return porcentajePequena;
    }

    public void setPorcentajePequena(BigDecimal porcentajePequena) {
        this.porcentajePequena = porcentajePequena;
    }

    public BigDecimal getPorcentajeMediana() {
        return porcentajeMediana;
    }

    public void setPorcentajeMediana(BigDecimal porcentajeMediana) {
        this.porcentajeMediana = porcentajeMediana;
    }

    public BigDecimal getPorcentajeGrande() {
        return porcentajeGrande;
    }

    public void setPorcentajeGrande(BigDecimal porcentajeGrande) {
        this.porcentajeGrande = porcentajeGrande;
    }

    public Integer getNumeroMuestras() {
        return numeroMuestras;
    }

    public void setNumeroMuestras(Integer numeroMuestras) {
        this.numeroMuestras = numeroMuestras;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
}
