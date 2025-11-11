package com.lytiks.backend.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

@Entity
@Table(name = "productos_contencion")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class ProductoContencion {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "nombre")
    private String nombre;

    @Column(name = "presentacion")
    private String presentacion;

    @Column(name = "dosis_sugerida")
    private String dosisSugerida;

    @Column(name = "url", length = 1000)
    private String url;
}
