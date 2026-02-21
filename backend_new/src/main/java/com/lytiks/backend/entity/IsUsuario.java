package com.lytiks.backend.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;
import java.util.Objects;

@Entity
@Table(name = "is_usuarios")
public class IsUsuario {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_usuarios")
    private Long idUsuarios;
    
    @Column(name = "id_roles")
    private Long idRoles;
    
    @Column(name = "id_area")
    private Long idArea;
    
    @Column(name = "usuario", length = 200)
    private String usuario;
    
    @Column(name = "clave", length = 200)
    private String clave;
    
    @Column(name = "tipo_persona", length = 1)
    private String tipoPersona;
    
    @Column(name = "cedula", length = 13)
    private String cedula;
    
    @Column(name = "nombres", length = 200)
    private String nombres;
    
    @Column(name = "apellidos", length = 200)
    private String apellidos;
    
    @Column(name = "direccion_dom", length = 2000)
    private String direccionDom;
    
    @Column(name = "telefono_casa", length = 9)
    private String telefonoCasa;
    
    @Column(name = "telefono_cel", length = 10)
    private String telefonoCel;
    
    @Column(name = "correo", length = 200)
    private String correo;
    
    @Column(name = "logo", length = 300)
    private String logo;
    
    @Column(name = "logo_ruta", length = 1000)
    private String logoRuta;
    
    @Column(name = "detalle", length = 1000)
    private String detalle;
    
    @Column(name = "intentos")
    private Integer intentos;
    
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

    public IsUsuario() {}

    public IsUsuario(Long idUsuarios, Long idRoles, Long idArea, String usuario, String clave,
            String tipoPersona, String cedula, String nombres, String apellidos, String direccionDom,
            String telefonoCasa, String telefonoCel, String correo, String logo, String logoRuta,
            String detalle, Integer intentos, Long idEmpresa, Long idCiudad, Long idSector,
            String estado, String usuarioIngreso, LocalDateTime fechaIngreso,
            String usuarioModificacion, LocalDateTime fechaModificacion) {
        this.idUsuarios = idUsuarios; this.idRoles = idRoles; this.idArea = idArea;
        this.usuario = usuario; this.clave = clave; this.tipoPersona = tipoPersona;
        this.cedula = cedula; this.nombres = nombres; this.apellidos = apellidos;
        this.direccionDom = direccionDom; this.telefonoCasa = telefonoCasa;
        this.telefonoCel = telefonoCel; this.correo = correo; this.logo = logo;
        this.logoRuta = logoRuta; this.detalle = detalle; this.intentos = intentos;
        this.idEmpresa = idEmpresa; this.idCiudad = idCiudad; this.idSector = idSector;
        this.estado = estado; this.usuarioIngreso = usuarioIngreso;
        this.fechaIngreso = fechaIngreso; this.usuarioModificacion = usuarioModificacion;
        this.fechaModificacion = fechaModificacion;
    }

    public Long getIdUsuarios() { return idUsuarios; }
    public void setIdUsuarios(Long idUsuarios) { this.idUsuarios = idUsuarios; }
    public Long getIdRoles() { return idRoles; }
    public void setIdRoles(Long idRoles) { this.idRoles = idRoles; }
    public Long getIdArea() { return idArea; }
    public void setIdArea(Long idArea) { this.idArea = idArea; }
    public String getUsuario() { return usuario; }
    public void setUsuario(String usuario) { this.usuario = usuario; }
    public String getClave() { return clave; }
    public void setClave(String clave) { this.clave = clave; }
    public String getTipoPersona() { return tipoPersona; }
    public void setTipoPersona(String tipoPersona) { this.tipoPersona = tipoPersona; }
    public String getCedula() { return cedula; }
    public void setCedula(String cedula) { this.cedula = cedula; }
    public String getNombres() { return nombres; }
    public void setNombres(String nombres) { this.nombres = nombres; }
    public String getApellidos() { return apellidos; }
    public void setApellidos(String apellidos) { this.apellidos = apellidos; }
    public String getDireccionDom() { return direccionDom; }
    public void setDireccionDom(String direccionDom) { this.direccionDom = direccionDom; }
    public String getTelefonoCasa() { return telefonoCasa; }
    public void setTelefonoCasa(String telefonoCasa) { this.telefonoCasa = telefonoCasa; }
    public String getTelefonoCel() { return telefonoCel; }
    public void setTelefonoCel(String telefonoCel) { this.telefonoCel = telefonoCel; }
    public String getCorreo() { return correo; }
    public void setCorreo(String correo) { this.correo = correo; }
    public String getLogo() { return logo; }
    public void setLogo(String logo) { this.logo = logo; }
    public String getLogoRuta() { return logoRuta; }
    public void setLogoRuta(String logoRuta) { this.logoRuta = logoRuta; }
    public String getDetalle() { return detalle; }
    public void setDetalle(String detalle) { this.detalle = detalle; }
    public Integer getIntentos() { return intentos; }
    public void setIntentos(Integer intentos) { this.intentos = intentos; }
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

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        IsUsuario that = (IsUsuario) o;
        return Objects.equals(idUsuarios, that.idUsuarios);
    }

    @Override
    public int hashCode() { return Objects.hash(idUsuarios); }
}
