package com.lytiks.backend.dto;

import java.time.LocalDate;

public class SigatokaEvaluacionDTO {
    private Long clienteId;
    private String hacienda;
    private LocalDate fecha;
    private Integer semanaEpidemiologica;
    private String periodo;
    private String evaluador;

    public SigatokaEvaluacionDTO() {}

    public Long getClienteId() { return clienteId; }
    public void setClienteId(Long clienteId) { this.clienteId = clienteId; }

    public String getHacienda() { return hacienda; }
    public void setHacienda(String hacienda) { this.hacienda = hacienda; }

    public LocalDate getFecha() { return fecha; }
    public void setFecha(LocalDate fecha) { this.fecha = fecha; }

    public Integer getSemanaEpidemiologica() { return semanaEpidemiologica; }
    public void setSemanaEpidemiologica(Integer semanaEpidemiologica) { this.semanaEpidemiologica = semanaEpidemiologica; }

    public String getPeriodo() { return periodo; }
    public void setPeriodo(String periodo) { this.periodo = periodo; }

    public String getEvaluador() { return evaluador; }
    public void setEvaluador(String evaluador) { this.evaluador = evaluador; }
}
