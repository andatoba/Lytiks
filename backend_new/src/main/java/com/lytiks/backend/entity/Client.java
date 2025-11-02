package com.lytiks.backend.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "clients")
public class Client {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "cedula", unique = true, nullable = false)
    private String cedula;
    
    @Column(name = "nombre", nullable = false)
    private String nombre;
    
    @Column(name = "apellidos")
    private String apellidos;
    
    @Column(name = "telefono")
    private String telefono;
    
    @Column(name = "email")
    private String email;
    
    @Column(name = "direccion", columnDefinition = "TEXT")
    private String direccion;
    
    @Column(name = "parroquia")
    private String parroquia;
    
    
    @Column(name = "finca_nombre")
    private String fincaNombre;
    
    @Column(name = "finca_hectareas")
    private Double fincaHectareas;
    
    @Column(name = "cultivos_principales")
    private String cultivosPrincipales;
    
    // ...existing code...
    
    @Column(name = "geolocalizacion_lat")
    private Double geolocalizacionLat;
    
    @Column(name = "geolocalizacion_lng")
    private Double geolocalizacionLng;
    
    @Column(name = "observaciones", columnDefinition = "TEXT")
    private String observaciones;
    
    @Column(name = "estado")
    private String estado = "ACTIVO"; // ACTIVO, INACTIVO
    
    @Column(name = "fecha_registro")
    private LocalDateTime fechaRegistro;
    
    @Column(name = "fecha_actualizacion")
    private LocalDateTime fechaActualizacion;
    
    @Column(name = "tecnico_asignado_id")
    private Long tecnicoAsignadoId;
    
    // Constructors
    public Client() {
        this.fechaRegistro = LocalDateTime.now();
        this.fechaActualizacion = LocalDateTime.now();
    }
    
    public Client(String cedula, String nombre) {
        this();
        this.cedula = cedula;
        this.nombre = nombre;
    }
    
    // Getters and Setters
    public Long getId() {
        return id;
    }
    
    public void setId(Long id) {
        this.id = id;
    }
    
    public String getCedula() {
        return cedula;
    }
    
    public void setCedula(String cedula) {
        this.cedula = cedula;
    }
    
    public String getNombre() {
        return nombre;
    }
    
    public void setNombre(String nombre) {
        this.nombre = nombre;
    }
    
    public String getApellidos() {
        return apellidos;
    }
    
    public void setApellidos(String apellidos) {
        this.apellidos = apellidos;
    }
    
    public String getTelefono() {
        return telefono;
    }
    
    public void setTelefono(String telefono) {
        this.telefono = telefono;
    }
    
    public String getEmail() {
        return email;
    }
    
    public void setEmail(String email) {
        this.email = email;
    }
    
    public String getDireccion() {
        return direccion;
    }
    
    public void setDireccion(String direccion) {
        this.direccion = direccion;
    }
    
    public String getParroquia() {
        return parroquia;
    }
    
    public void setParroquia(String parroquia) {
        this.parroquia = parroquia;
    }
    
    // eliminado departamento
    
    public String getFincaNombre() {
        return fincaNombre;
    }
    
    public void setFincaNombre(String fincaNombre) {
        this.fincaNombre = fincaNombre;
    }
    
    public Double getFincaHectareas() {
        return fincaHectareas;
    }
    
    public void setFincaHectareas(Double fincaHectareas) {
        this.fincaHectareas = fincaHectareas;
    }
    
    public String getCultivosPrincipales() {
        return cultivosPrincipales;
    }
    
    public void setCultivosPrincipales(String cultivosPrincipales) {
        this.cultivosPrincipales = cultivosPrincipales;
    }
    
    // ...existing code...
    
    public Double getGeolocalizacionLat() {
        return geolocalizacionLat;
    }
    
    public void setGeolocalizacionLat(Double geolocalizacionLat) {
        this.geolocalizacionLat = geolocalizacionLat;
    }
    
    public Double getGeolocalizacionLng() {
        return geolocalizacionLng;
    }
    
    public void setGeolocalizacionLng(Double geolocalizacionLng) {
        this.geolocalizacionLng = geolocalizacionLng;
    }
    
    public String getObservaciones() {
        return observaciones;
    }
    
    public void setObservaciones(String observaciones) {
        this.observaciones = observaciones;
    }
    
    public String getEstado() {
        return estado;
    }
    
    public void setEstado(String estado) {
        this.estado = estado;
    }
    
    public LocalDateTime getFechaRegistro() {
        return fechaRegistro;
    }
    
    public void setFechaRegistro(LocalDateTime fechaRegistro) {
        this.fechaRegistro = fechaRegistro;
    }
    
    public LocalDateTime getFechaActualizacion() {
        return fechaActualizacion;
    }
    
    public void setFechaActualizacion(LocalDateTime fechaActualizacion) {
        this.fechaActualizacion = fechaActualizacion;
    }
    
    public Long getTecnicoAsignadoId() {
        return tecnicoAsignadoId;
    }
    
    public void setTecnicoAsignadoId(Long tecnicoAsignadoId) {
        this.tecnicoAsignadoId = tecnicoAsignadoId;
    }
    
    // Método helper para obtener nombre completo
    public String getNombreCompleto() {
        return nombre + (apellidos != null ? " " + apellidos : "");
    }
}