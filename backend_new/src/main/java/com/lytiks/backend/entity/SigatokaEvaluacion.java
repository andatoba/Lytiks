package com.lytiks.backend.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "sigatoka_evaluacion")
public class SigatokaEvaluacion {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "cliente_id", nullable = false)
    private Long clienteId;
    
    @Column(nullable = false, length = 200)
    private String hacienda;
    
    @Column(nullable = false)
    private LocalDate fecha;
    
    @Column(name = "semana_epidemiologica")
    private Integer semanaEpidemiologica;
    
    @Column(length = 50)
    private String periodo;
    
    @Column(nullable = false, length = 100)
    private String evaluador;
    
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;
    
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
    
    // Relaciones
    @OneToMany(mappedBy = "evaluacion", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<SigatokaLote> lotes = new ArrayList<>();
    
    @JsonIgnore
    @OneToOne(mappedBy = "evaluacion", cascade = CascadeType.ALL, orphanRemoval = true)
    private SigatokaResumen resumen;
    
    @JsonIgnore
    @OneToOne(mappedBy = "evaluacion", cascade = CascadeType.ALL, orphanRemoval = true)
    private SigatokaIndicadores indicadores;
    
    @JsonIgnore
    @OneToOne(mappedBy = "evaluacion", cascade = CascadeType.ALL, orphanRemoval = true)
    private SigatokaEstadoEvolutivo estadoEvolutivo;
    
    @JsonIgnore
    @OneToOne(mappedBy = "evaluacion", cascade = CascadeType.ALL, orphanRemoval = true)
    private SigatokaStoverPromedio stoverPromedio;
    
    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }
    
    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}
