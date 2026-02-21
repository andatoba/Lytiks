package com.lytiks.backend.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;
import java.util.Objects;

@Entity
@Table(name = "hacienda")
public class Hacienda {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "nombre", nullable = false)
    private String nombre;
    
    @Column(name = "detalle", columnDefinition = "TEXT")
    private String detalle;
    
    @Column(name = "ubicacion")
    private String ubicacion;
    
    @Column(name = "hectareas")
    private Double hectareas;
    
    @Column(name = "latitud")
    private Double latitud;
    
    @Column(name = "longitud")
    private Double longitud;
    
    @Column(name = "cliente_id", nullable = false)
    private Long clienteId;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "cliente_id", insertable = false, updatable = false)
    private Client cliente;
    
    @Column(name = "estado")
    private String estado = "ACTIVO";
    
    @Column(name = "fecha_creacion", updatable = false)
    private LocalDateTime fechaCreacion;
    
    @Column(name = "fecha_actualizacion")
    private LocalDateTime fechaActualizacion;
    
    @Column(name = "usuario_creacion")
    private String usuarioCreacion;
    
    @Column(name = "usuario_actualizacion")
    private String usuarioActualizacion;
    
    @PrePersist
    protected void onCreate() {
        fechaCreacion = LocalDateTime.now();
        fechaActualizacion = LocalDateTime.now();
    }
    
    @PreUpdate
    protected void onUpdate() {
        fechaActualizacion = LocalDateTime.now();
    }

    public Hacienda() {}

    public Hacienda(Long id, String nombre, String detalle, String ubicacion, Double hectareas,
            Double latitud, Double longitud, Long clienteId, Client cliente, String estado,
            LocalDateTime fechaCreacion, LocalDateTime fechaActualizacion, String usuarioCreacion,
            String usuarioActualizacion) {
        this.id = id; this.nombre = nombre; this.detalle = detalle; this.ubicacion = ubicacion;
        this.hectareas = hectareas; this.latitud = latitud; this.longitud = longitud;
        this.clienteId = clienteId; this.cliente = cliente; this.estado = estado;
        this.fechaCreacion = fechaCreacion; this.fechaActualizacion = fechaActualizacion;
        this.usuarioCreacion = usuarioCreacion; this.usuarioActualizacion = usuarioActualizacion;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }
    public String getDetalle() { return detalle; }
    public void setDetalle(String detalle) { this.detalle = detalle; }
    public String getUbicacion() { return ubicacion; }
    public void setUbicacion(String ubicacion) { this.ubicacion = ubicacion; }
    public Double getHectareas() { return hectareas; }
    public void setHectareas(Double hectareas) { this.hectareas = hectareas; }
    public Double getLatitud() { return latitud; }
    public void setLatitud(Double latitud) { this.latitud = latitud; }
    public Double getLongitud() { return longitud; }
    public void setLongitud(Double longitud) { this.longitud = longitud; }
    public Long getClienteId() { return clienteId; }
    public void setClienteId(Long clienteId) { this.clienteId = clienteId; }
    public Client getCliente() { return cliente; }
    public void setCliente(Client cliente) { this.cliente = cliente; }
    public String getEstado() { return estado; }
    public void setEstado(String estado) { this.estado = estado; }
    public LocalDateTime getFechaCreacion() { return fechaCreacion; }
    public void setFechaCreacion(LocalDateTime fechaCreacion) { this.fechaCreacion = fechaCreacion; }
    public LocalDateTime getFechaActualizacion() { return fechaActualizacion; }
    public void setFechaActualizacion(LocalDateTime fechaActualizacion) { this.fechaActualizacion = fechaActualizacion; }
    public String getUsuarioCreacion() { return usuarioCreacion; }
    public void setUsuarioCreacion(String usuarioCreacion) { this.usuarioCreacion = usuarioCreacion; }
    public String getUsuarioActualizacion() { return usuarioActualizacion; }
    public void setUsuarioActualizacion(String usuarioActualizacion) { this.usuarioActualizacion = usuarioActualizacion; }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Hacienda that = (Hacienda) o;
        return Objects.equals(id, that.id);
    }

    @Override
    public int hashCode() { return Objects.hash(id); }
}
