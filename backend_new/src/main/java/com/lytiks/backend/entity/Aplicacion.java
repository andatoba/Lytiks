package com.lytiks.backend.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

@Entity
@Table(name = "aplicaciones")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Aplicacion {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "cliente_id")
    private Long clienteId;

    @Column(name = "producto_id")
    private Long productoId;

    @Column(name = "producto_nombre")
    private String productoNombre;

    @Column(name = "plan")
    private String plan;

    @Column(name = "lote")
    private String lote;

    @Column(name = "area_hectareas")
    private Double areaHectareas;

    @Column(name = "dosis")
    private String dosis;

    @Column(name = "fecha_inicio")
    private LocalDateTime fechaInicio;

    @Column(name = "frecuencia_dias")
    private Integer frecuenciaDias;

    @Column(name = "repeticiones")
    private Integer repeticiones;

    @Column(name = "recordatorio_hora")
    private String recordatorioHora;

    @Column(name = "created_at")
    private LocalDateTime createdAt;
}
