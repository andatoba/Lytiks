package com.lytiks.backend.entity;

import jakarta.persistence.*;
import java.util.Objects;

@Entity
@Table(name = "productos_contencion")
public class ProductoContencion {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_producto")
    private Producto producto;

    @Column(name = "presentacion")
    private String presentacion;

    @Column(name = "dosis_sugerida")
    private String dosisSugerida;

    @Column(name = "url", length = 1000)
    private String url;

    public ProductoContencion() {}

    public ProductoContencion(Long id, Producto producto, String presentacion, String dosisSugerida, String url) {
        this.id = id;
        this.producto = producto;
        this.presentacion = presentacion;
        this.dosisSugerida = dosisSugerida;
        this.url = url;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Producto getProducto() { return producto; }
    public void setProducto(Producto producto) { this.producto = producto; }
    public String getPresentacion() { return presentacion; }
    public void setPresentacion(String presentacion) { this.presentacion = presentacion; }
    public String getDosisSugerida() { return dosisSugerida; }
    public void setDosisSugerida(String dosisSugerida) { this.dosisSugerida = dosisSugerida; }
    public String getUrl() { return url; }
    public void setUrl(String url) { this.url = url; }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        ProductoContencion that = (ProductoContencion) o;
        return Objects.equals(id, that.id);
    }

    @Override
    public int hashCode() { return Objects.hash(id); }
}
