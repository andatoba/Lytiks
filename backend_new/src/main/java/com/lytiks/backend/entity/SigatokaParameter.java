package com.lytiks.backend.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "sigatoka_parameters")
public class SigatokaParameter {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "sigatoka_audit_id", nullable = false)
    private SigatokaAudit sigatokaAudit;
    
    @Column(name = "parameter_name", nullable = false)
    private String parameterName; // HSI, YLS, ILP, ISED, SLS, NeLS
    
    @Column(name = "week_number", nullable = false)
    private Integer weekNumber; // 0-10
    
    @Column(name = "value")
    private Double value;
    
    // Constructors
    public SigatokaParameter() {}
    
    public SigatokaParameter(SigatokaAudit sigatokaAudit, String parameterName, Integer weekNumber, Double value) {
        this.sigatokaAudit = sigatokaAudit;
        this.parameterName = parameterName;
        this.weekNumber = weekNumber;
        this.value = value;
    }
    
    // Getters and Setters
    public Long getId() {
        return id;
    }
    
    public void setId(Long id) {
        this.id = id;
    }
    
    public SigatokaAudit getSigatokaAudit() {
        return sigatokaAudit;
    }
    
    public void setSigatokaAudit(SigatokaAudit sigatokaAudit) {
        this.sigatokaAudit = sigatokaAudit;
    }
    
    public String getParameterName() {
        return parameterName;
    }
    
    public void setParameterName(String parameterName) {
        this.parameterName = parameterName;
    }
    
    public Integer getWeekNumber() {
        return weekNumber;
    }
    
    public void setWeekNumber(Integer weekNumber) {
        this.weekNumber = weekNumber;
    }
    
    public Double getValue() {
        return value;
    }
    
    public void setValue(Double value) {
        this.value = value;
    }
}