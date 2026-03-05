package com.lytiks.backend.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "is_roles")
public class IsRol {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_roles")
    private Long idRoles;
    
    @Column(name = "nombre", length = 200)
    private String nombre;
    
    @Column(name = "detalle", length = 1000)
    private String detalle;
    
    @Column(name = "id_empresa")
    private Long idEmpresa;
    
    @Column(name = "id_ciudad")
    private Long idCiudad;
    
    @Column(name = "id_sector")
    private Long idSector;
    
    @Column(name = "estado", length = 1)
    private String estado;
    
    @Column(name = "usuario_ingreso", length = 100)
    private String usuarioIngreso;
    
    @Column(name = "fecha_ingreso")
    private LocalDateTime fechaIngreso;
    
    @Column(name = "usuario_modificacion", length = 100)
    private String usuarioModificacion;
    
    @Column(name = "fecha_modificacion")
    private LocalDateTime fechaModificacion;

    public IsRol() {}

    public IsRol(Long idRoles, String nombre, String detalle, Long idEmpresa, Long idCiudad,
            Long idSector, String estado, String usuarioIngreso, LocalDateTime fechaIngreso,
            String usuarioModificacion, LocalDateTime fechaModificacion) {
        this.idRoles = idRoles;
        this.nombre = nombre;
        this.detalle = detalle;
        this.idEmpresa = idEmpresa;
        this.idCiudad = idCiudad;
        this.idSector = idSector;
        this.estado = estado;
        this.usuarioIngreso = usuarioIngreso;
        this.fechaIngreso = fechaIngreso;
        this.usuarioModificacion = usuarioModificacion;
        this.fechaModificacion = fechaModificacion;
    }

    public Long getIdRoles() { return idRoles; }
    public void setIdRoles(Long idRoles) { this.idRoles = idRoles; }
    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }
    public String getDetalle() { return detalle; }
    public void setDetalle(String detalle) { this.detalle = detalle; }
    public Long getIdEmpresa() { return idEmpresa; }
    public void setIdEmpresa(Long idEmpresa) { this.idEmpresa = idEmpresa; }
    public Long getIdCiudad() { return idCiudad; }
    public void setIdCiudad(Long idCiudad) { this.idCiudad = idCiudad; }
    public Long getIdSector() { return idSector; }
    public void setIdSector(Long idSector) { this.idSector = idSector; }
    public String getEstado() { return estado; }
    public void setEstado(String estado) { this.estado = estado; }
    public String getUsuarioIngreso() { return usuarioIngreso; }
    public void setUsuarioIngreso(String usuarioIngreso) { this.usuarioIngreso = usuarioIngreso; }
    public LocalDateTime getFechaIngreso() { return fechaIngreso; }
    public void setFechaIngreso(LocalDateTime fechaIngreso) { this.fechaIngreso = fechaIngreso; }
    public String getUsuarioModificacion() { return usuarioModificacion; }
    public void setUsuarioModificacion(String usuarioModificacion) { this.usuarioModificacion = usuarioModificacion; }
    public LocalDateTime getFechaModificacion() { return fechaModificacion; }
    public void setFechaModificacion(LocalDateTime fechaModificacion) { this.fechaModificacion = fechaModificacion; }
}
