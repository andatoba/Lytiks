package com.lytiks.backend.entity;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import jakarta.persistence.*;
import java.time.LocalDateTime;

/**
 * Entidad para la configuración del logo
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
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
    
    @PrePersist
    protected void onCreate() {
        fechaCreacion = LocalDateTime.now();
        fechaActualizacion = LocalDateTime.now();
    }
    
    @PreUpdate
    protected void onUpdate() {
        fechaActualizacion = LocalDateTime.now();
    }
}
