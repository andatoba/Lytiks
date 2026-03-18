package com.lytiks.backend.dto;

import java.math.BigDecimal;

public class PlagasResumenDTO {
    private Long clientId;
    private String cedulaCliente;
    private Long tecnicoId;
    private String fecha;
    private String lote;
    private String plaga;

    private Integer totalHuevo;
    private Integer totalPequena;
    private Integer totalMediana;
    private Integer totalGrande;
    private Integer totalIndividuos;
    private BigDecimal porcentajeDanio;

    private BigDecimal promedioHuevo;
    private BigDecimal promedioPequena;
    private BigDecimal promedioMediana;
    private BigDecimal promedioGrande;
    private BigDecimal promedioTotal;
    private BigDecimal promedioDanio;

    private BigDecimal porcentajeHuevo;
    private BigDecimal porcentajePequena;
    private BigDecimal porcentajeMediana;
    private BigDecimal porcentajeGrande;

    private Integer numeroMuestras;

    public Long getClientId() {
        return clientId;
    }

    public void setClientId(Long clientId) {
        this.clientId = clientId;
    }

    public String getCedulaCliente() {
        return cedulaCliente;
    }

    public void setCedulaCliente(String cedulaCliente) {
        this.cedulaCliente = cedulaCliente;
    }

    public Long getTecnicoId() {
        return tecnicoId;
    }

    public void setTecnicoId(Long tecnicoId) {
        this.tecnicoId = tecnicoId;
    }

    public String getFecha() {
        return fecha;
    }

    public void setFecha(String fecha) {
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
}
