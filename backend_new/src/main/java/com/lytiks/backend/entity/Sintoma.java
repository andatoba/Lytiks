package com.lytiks.backend.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

@Entity
@Table(name = "sintomas")
@Data
@NoArgsConstructor
@AllArgsConstructor
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
}