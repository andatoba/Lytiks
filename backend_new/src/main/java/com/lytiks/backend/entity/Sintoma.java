package com.lytiks.backend.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "sintomas")
public class Sintoma {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "categoria")
    private String categoria;
    
    @Column(name = "sintoma_observable")
    private String sintomaObservable;
    
    @Column(name = "descripcion_tecnica", length = 1000)
    private String descripcionTecnica;
    
    @Column(name = "severidad")
    private String severidad;
    
    public Sintoma() {}
    
    public Sintoma(Long id, String categoria, String sintomaObservable, String descripcionTecnica, String severidad) {
        this.id = id;
        this.categoria = categoria;
        this.sintomaObservable = sintomaObservable;
        this.descripcionTecnica = descripcionTecnica;
        this.severidad = severidad;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getCategoria() { return categoria; }
    public void setCategoria(String categoria) { this.categoria = categoria; }
    public String getSintomaObservable() { return sintomaObservable; }
    public void setSintomaObservable(String sintomaObservable) { this.sintomaObservable = sintomaObservable; }
    public String getDescripcionTecnica() { return descripcionTecnica; }
    public void setDescripcionTecnica(String descripcionTecnica) { this.descripcionTecnica = descripcionTecnica; }
    public String getSeveridad() { return severidad; }
    public void setSeveridad(String severidad) { this.severidad = severidad; }
}
