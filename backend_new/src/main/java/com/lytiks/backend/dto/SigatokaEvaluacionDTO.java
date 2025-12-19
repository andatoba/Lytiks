package com.lytiks.backend.dto;

import lombok.Data;
import lombok.Getter;
import lombok.Setter;
import java.time.LocalDate;

@Data
@Getter
@Setter
public class SigatokaEvaluacionDTO {
    private Long clienteId;
    private String hacienda;
    private LocalDate fecha;
    private Integer semanaEpidemiologica;
    private String periodo;
    private String evaluador;
}
