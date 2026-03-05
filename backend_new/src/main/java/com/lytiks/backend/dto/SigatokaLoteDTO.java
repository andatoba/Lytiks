package com.lytiks.backend.dto;

public class SigatokaLoteDTO {
    private String loteCodigo;
    private Double latitud;
    private Double longitud;

    public SigatokaLoteDTO() {}

    public String getLoteCodigo() { return loteCodigo; }
    public void setLoteCodigo(String loteCodigo) { this.loteCodigo = loteCodigo; }
    public Double getLatitud() { return latitud; }
    public void setLatitud(Double latitud) { this.latitud = latitud; }
    public Double getLongitud() { return longitud; }
    public void setLongitud(Double longitud) { this.longitud = longitud; }
}
