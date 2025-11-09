package com.lytiks.backend.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "seguimiento_moko")
public class SeguimientoMoko {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "foco_id", nullable = false)
    private Long focoId;

    @Column(name = "numero_foco", nullable = false)
    private Integer numeroFoco;

    @Column(name = "semana_inicio")
    private Integer semanaInicio;

    @Column(name = "plantas_afectadas", nullable = false)
    private Integer plantasAfectadas;

    @Column(name = "plantas_inyectadas", nullable = false)
    private Integer plantasInyectadas;

    @Column(name = "control_vectores", nullable = false)
    private Boolean controlVectores = false;

    @Column(name = "cuarentena_activa", nullable = false)
    private Boolean cuarentenaActiva = false;

    @Column(name = "unica_entrada_habilitada", nullable = false)
    private Boolean unicaEntradaHabilitada = false;

    @Column(name = "eliminacion_maleza_hospedera", nullable = false)
    private Boolean eliminacionMalezaHospedera = false;

    @Column(name = "control_picudo_aplicado", nullable = false)
    private Boolean controlPicudoAplicado = false;

    @Column(name = "inspeccion_plantas_vecinas", nullable = false)
    private Boolean inspeccionPlantasVecinas = false;

    @Column(name = "corte_riego", nullable = false)
    private Boolean corteRiego = false;

    @Column(name = "pediluvio_activo", nullable = false)
    private Boolean pediluvioActivo = false;

    @Column(name = "ppm_solucion_desinfectante")
    private Integer ppmSolucionDesinfectante;

    @Column(name = "fecha_seguimiento", nullable = false)
    private LocalDateTime fechaSeguimiento;

    @Column(name = "fecha_creacion", nullable = false)
    private LocalDateTime fechaCreacion;

    // Constructores
    public SeguimientoMoko() {
        this.fechaCreacion = LocalDateTime.now();
        this.fechaSeguimiento = LocalDateTime.now();
    }

    // Getters y Setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Long getFocoId() {
        return focoId;
    }

    public void setFocoId(Long focoId) {
        this.focoId = focoId;
    }

    public Integer getNumeroFoco() {
        return numeroFoco;
    }

    public void setNumeroFoco(Integer numeroFoco) {
        this.numeroFoco = numeroFoco;
    }

    public Integer getSemanaInicio() {
        return semanaInicio;
    }

    public void setSemanaInicio(Integer semanaInicio) {
        this.semanaInicio = semanaInicio;
    }

    public Integer getPlantasAfectadas() {
        return plantasAfectadas;
    }

    public void setPlantasAfectadas(Integer plantasAfectadas) {
        this.plantasAfectadas = plantasAfectadas;
    }

    public Integer getPlantasInyectadas() {
        return plantasInyectadas;
    }

    public void setPlantasInyectadas(Integer plantasInyectadas) {
        this.plantasInyectadas = plantasInyectadas;
    }

    public Boolean getControlVectores() {
        return controlVectores;
    }

    public void setControlVectores(Boolean controlVectores) {
        this.controlVectores = controlVectores;
    }

    public Boolean getCuarentenaActiva() {
        return cuarentenaActiva;
    }

    public void setCuarentenaActiva(Boolean cuarentenaActiva) {
        this.cuarentenaActiva = cuarentenaActiva;
    }

    public Boolean getUnicaEntradaHabilitada() {
        return unicaEntradaHabilitada;
    }

    public void setUnicaEntradaHabilitada(Boolean unicaEntradaHabilitada) {
        this.unicaEntradaHabilitada = unicaEntradaHabilitada;
    }

    public Boolean getEliminacionMalezaHospedera() {
        return eliminacionMalezaHospedera;
    }

    public void setEliminacionMalezaHospedera(Boolean eliminacionMalezaHospedera) {
        this.eliminacionMalezaHospedera = eliminacionMalezaHospedera;
    }

    public Boolean getControlPicudoAplicado() {
        return controlPicudoAplicado;
    }

    public void setControlPicudoAplicado(Boolean controlPicudoAplicado) {
        this.controlPicudoAplicado = controlPicudoAplicado;
    }

    public Boolean getInspeccionPlantasVecinas() {
        return inspeccionPlantasVecinas;
    }

    public void setInspeccionPlantasVecinas(Boolean inspeccionPlantasVecinas) {
        this.inspeccionPlantasVecinas = inspeccionPlantasVecinas;
    }

    public Boolean getCorteRiego() {
        return corteRiego;
    }

    public void setCorteRiego(Boolean corteRiego) {
        this.corteRiego = corteRiego;
    }

    public Boolean getPediluvioActivo() {
        return pediluvioActivo;
    }

    public void setPediluvioActivo(Boolean pediluvioActivo) {
        this.pediluvioActivo = pediluvioActivo;
    }

    public Integer getPpmSolucionDesinfectante() {
        return ppmSolucionDesinfectante;
    }

    public void setPpmSolucionDesinfectante(Integer ppmSolucionDesinfectante) {
        this.ppmSolucionDesinfectante = ppmSolucionDesinfectante;
    }

    public LocalDateTime getFechaSeguimiento() {
        return fechaSeguimiento;
    }

    public void setFechaSeguimiento(LocalDateTime fechaSeguimiento) {
        this.fechaSeguimiento = fechaSeguimiento;
    }

    public LocalDateTime getFechaCreacion() {
        return fechaCreacion;
    }

    public void setFechaCreacion(LocalDateTime fechaCreacion) {
        this.fechaCreacion = fechaCreacion;
    }
}