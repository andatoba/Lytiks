package com.lytiks.backend.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "moko_audit_photos")
public class MokoAuditPhoto {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "moko_audit_id", nullable = false)
    private MokoAudit mokoAudit;
    
    @Column(name = "file_name", nullable = false)
    private String fileName;
    
    @Column(name = "file_path", nullable = false)
    private String filePath;
    
    @Column(name = "file_size")
    private Long fileSize;
    
    @Column(name = "mime_type")
    private String mimeType;
    
    @Column(name = "description", columnDefinition = "TEXT")
    private String description;
    
    @Column(name = "categoria")
    private String categoria;
    
    @Column(name = "etapa_proceso")
    private String etapaProceso; // Antes/Durante/Después
    
    @Column(name = "area_verificacion")
    private String areaVerificacion;
    
    // Constructors
    public MokoAuditPhoto() {}
    
    public MokoAuditPhoto(MokoAudit mokoAudit, String fileName, String filePath) {
        this.mokoAudit = mokoAudit;
        this.fileName = fileName;
        this.filePath = filePath;
    }
    
    // Getters and Setters
    public Long getId() {
        return id;
    }
    
    public void setId(Long id) {
        this.id = id;
    }
    
    public MokoAudit getMokoAudit() {
        return mokoAudit;
    }
    
    public void setMokoAudit(MokoAudit mokoAudit) {
        this.mokoAudit = mokoAudit;
    }
    
    public String getFileName() {
        return fileName;
    }
    
    public void setFileName(String fileName) {
        this.fileName = fileName;
    }
    
    public String getFilePath() {
        return filePath;
    }
    
    public void setFilePath(String filePath) {
        this.filePath = filePath;
    }
    
    public Long getFileSize() {
        return fileSize;
    }
    
    public void setFileSize(Long fileSize) {
        this.fileSize = fileSize;
    }
    
    public String getMimeType() {
        return mimeType;
    }
    
    public void setMimeType(String mimeType) {
        this.mimeType = mimeType;
    }
    
    public String getDescription() {
        return description;
    }
    
    public void setDescription(String description) {
        this.description = description;
    }
    
    public String getCategoria() {
        return categoria;
    }
    
    public void setCategoria(String categoria) {
        this.categoria = categoria;
    }
    
    public String getEtapaProceso() {
        return etapaProceso;
    }
    
    public void setEtapaProceso(String etapaProceso) {
        this.etapaProceso = etapaProceso;
    }
    
    public String getAreaVerificacion() {
        return areaVerificacion;
    }
    
    public void setAreaVerificacion(String areaVerificacion) {
        this.areaVerificacion = areaVerificacion;
    }
}