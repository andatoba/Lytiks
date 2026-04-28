package com.lytiks.backend.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;
import java.util.Objects;

/**
 * Entidad para la configuración del logo
 */
@Entity
@Table(name = "configuracion_logo")
public class ConfiguracionLogo {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "id_empresa")
    private Integer idEmpresa;
    
    @Column(name = "nombre", nullable = false)
    private String nombre;
    
    @Column(name = "ruta_logo", nullable = false)
    private String rutaLogo;
    
    @Column(name = "logo_base64", columnDefinition = "LONGTEXT")
    private String logoBase64;
    
    @Column(name = "tipo_mime")
    private String tipoMime;
    
    @Column(name = "activo")
    private Boolean activo = true;
    
    @Column(name = "descripcion", columnDefinition = "TEXT")
    private String descripcion;
    
    @Column(name = "fecha_creacion", updatable = false)
    private LocalDateTime fechaCreacion;
    
    @Column(name = "fecha_actualizacion")
    private LocalDateTime fechaActualizacion;

    public ConfiguracionLogo() {}

    public ConfiguracionLogo(Long id, Integer idEmpresa, String nombre, String rutaLogo, 
            String logoBase64, String tipoMime, Boolean activo, String descripcion, 
            LocalDateTime fechaCreacion, LocalDateTime fechaActualizacion) {
        this.id = id;
        this.idEmpresa = idEmpresa;
        this.nombre = nombre;
        this.rutaLogo = rutaLogo;
        this.logoBase64 = logoBase64;
        this.tipoMime = tipoMime;
        this.activo = activo;
        this.descripcion = descripcion;
        this.fechaCreacion = fechaCreacion;
        this.fechaActualizacion = fechaActualizacion;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Integer getIdEmpresa() { return idEmpresa; }
    public void setIdEmpresa(Integer idEmpresa) { this.idEmpresa = idEmpresa; }

    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }

    public String getRutaLogo() { return rutaLogo; }
    public void setRutaLogo(String rutaLogo) { this.rutaLogo = rutaLogo; }

    public String getLogoBase64() { return logoBase64; }
    public void setLogoBase64(String logoBase64) { this.logoBase64 = logoBase64; }

    public String getTipoMime() { return tipoMime; }
    public void setTipoMime(String tipoMime) { this.tipoMime = tipoMime; }

    public Boolean getActivo() { return activo; }
    public void setActivo(Boolean activo) { this.activo = activo; }

    public String getDescripcion() { return descripcion; }
    public void setDescripcion(String descripcion) { this.descripcion = descripcion; }

    public LocalDateTime getFechaCreacion() { return fechaCreacion; }
    public void setFechaCreacion(LocalDateTime fechaCreacion) { this.fechaCreacion = fechaCreacion; }

    public LocalDateTime getFechaActualizacion() { return fechaActualizacion; }
    public void setFechaActualizacion(LocalDateTime fechaActualizacion) { this.fechaActualizacion = fechaActualizacion; }

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
        ConfiguracionLogo that = (ConfiguracionLogo) o;
        return Objects.equals(id, that.id);
    }

    @Override
    public int hashCode() { return Objects.hash(id); }
}
