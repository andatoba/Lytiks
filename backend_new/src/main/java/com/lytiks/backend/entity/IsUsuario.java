package com.lytiks.backend.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import java.time.LocalDateTime;

@Entity
@Table(name = "is_usuarios")
@Data
@NoArgsConstructor
@AllArgsConstructor
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
}