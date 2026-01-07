package com.lytiks.backend.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import java.time.LocalDateTime;

@Entity
@Table(name = "is_roles")
@Data
@NoArgsConstructor
@AllArgsConstructor
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
}