package com.lytiks.backend.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import java.util.ArrayList;
import java.util.List;

/**
 * Representa un lote dentro de una evaluación de Sigatoka
 * Un lote puede tener múltiples muestras
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "sigatoka_lote")
public class SigatokaLote {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @JsonIgnore
    @ManyToOne
    @JoinColumn(name = "evaluacion_id", nullable = false)
    private SigatokaEvaluacion evaluacion;
    
    @Column(name = "lote_codigo", nullable = false, length = 100)
    private String loteCodigo;
    
    @OneToMany(mappedBy = "lote", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<SigatokaMuestraCompleta> muestras = new ArrayList<>();
}
