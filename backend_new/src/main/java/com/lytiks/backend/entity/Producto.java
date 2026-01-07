package com.lytiks.backend.entity;

import jakarta.persistence.*;
import java.io.Serializable;

@Entity
@Table(name = "producto")
public class Producto implements Serializable {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_producto")
    private Integer idProducto;

    @Column(name = "nombre", nullable = false)
    private String nombre;

    @Column(name = "detalle")
    private String detalle;

    @Column(name = "cantidad")
    private Integer cantidad;

    @Column(name = "peso_kg")
    private Double pesoKg;

    // Getters y Setters
    public Integer getIdProducto() { return idProducto; }
    public void setIdProducto(Integer idProducto) { this.idProducto = idProducto; }

    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }

    public String getDetalle() { return detalle; }
    public void setDetalle(String detalle) { this.detalle = detalle; }

    public Integer getCantidad() { return cantidad; }
    public void setCantidad(Integer cantidad) { this.cantidad = cantidad; }

    public Double getPesoKg() { return pesoKg; }
    public void setPesoKg(Double pesoKg) { this.pesoKg = pesoKg; }
}
