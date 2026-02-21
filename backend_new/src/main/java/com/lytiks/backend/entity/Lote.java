package com.lytiks.backend.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;
import java.util.Objects;

/**
 * Entidad Lote
 */
@Entity
@Table(name = "lote")
public class Lote {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "nombre", nullable = false)
    private String nombre;
    
    @Column(name = "codigo", nullable = false)
    private String codigo;
    
    @Column(name = "detalle", columnDefinition = "TEXT")
    private String detalle;
    
    @Column(name = "hectareas")
    private Double hectareas;
    
    @Column(name = "variedad")
    private String variedad;
    
    @Column(name = "edad")
    private String edad;
    
    @Column(name = "latitud")
    private Double latitud;
    
    @Column(name = "longitud")
    private Double longitud;
    
    @Column(name = "hacienda_id", nullable = false)
    private Long haciendaId;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "hacienda_id", insertable = false, updatable = false)
    private Hacienda hacienda;
    
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

    public Lote() {}

    public Lote(Long id, String nombre, String codigo, String detalle, Double hectareas, 
            String variedad, String edad, Double latitud, Double longitud, Long haciendaId, 
            Hacienda hacienda, String estado, LocalDateTime fechaCreacion, 
            LocalDateTime fechaActualizacion, String usuarioCreacion, String usuarioActualizacion) {
        this.id = id;
        this.nombre = nombre;
        this.codigo = codigo;
        this.detalle = detalle;
        this.hectareas = hectareas;
        this.variedad = variedad;
        this.edad = edad;
        this.latitud = latitud;
        this.longitud = longitud;
        this.haciendaId = haciendaId;
        this.hacienda = hacienda;
        this.estado = estado;
        this.fechaCreacion = fechaCreacion;
        this.fechaActualizacion = fechaActualizacion;
        this.usuarioCreacion = usuarioCreacion;
        this.usuarioActualizacion = usuarioActualizacion;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }

    public String getCodigo() { return codigo; }
    public void setCodigo(String codigo) { this.codigo = codigo; }

    public String getDetalle() { return detalle; }
    public void setDetalle(String detalle) { this.detalle = detalle; }

    public Double getHectareas() { return hectareas; }
    public void setHectareas(Double hectareas) { this.hectareas = hectareas; }

    public String getVariedad() { return variedad; }
    public void setVariedad(String variedad) { this.variedad = variedad; }

    public String getEdad() { return edad; }
    public void setEdad(String edad) { this.edad = edad; }

    public Double getLatitud() { return latitud; }
    public void setLatitud(Double latitud) { this.latitud = latitud; }

    public Double getLongitud() { return longitud; }
    public void setLongitud(Double longitud) { this.longitud = longitud; }

    public Long getHaciendaId() { return haciendaId; }
    public void setHaciendaId(Long haciendaId) { this.haciendaId = haciendaId; }

    public Hacienda getHacienda() { return hacienda; }
    public void setHacienda(Hacienda hacienda) { this.hacienda = hacienda; }

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

    @PrePersist
    protected void onCreate() {
        fechaCreacion = LocalDateTime.now();
        fechaActualizacion = LocalDateTime.now();
    }
    
    @PreUpdate
    protected void onUpdate() {
        fechaActualizacion = LocalDateTime.now();
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Lote lote = (Lote) o;
        return Objects.equals(id, lote.id);
    }

    @Override
    public int hashCode() { return Objects.hash(id); }
}
