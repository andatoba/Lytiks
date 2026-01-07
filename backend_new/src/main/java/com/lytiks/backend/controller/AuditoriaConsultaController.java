package com.lytiks.backend.controller;

import com.lytiks.backend.entity.RegistroMoko;
import com.lytiks.backend.service.RegistroMokoService;
import com.lytiks.backend.entity.Client;
import com.lytiks.backend.repository.ClientRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.HashMap;

@RestController
@RequestMapping("/auditorias")
@CrossOrigin(origins = "*")
public class AuditoriaConsultaController {

    @Autowired
    private RegistroMokoService registroMokoService;

    @Autowired
    private ClientRepository clientRepository;

    // @Autowired
    // private com.lytiks.backend.service.SigatokaAuditService sigatokaAuditService;

    @Autowired
    private com.lytiks.backend.service.AuditService auditService;

    @Autowired
    private com.lytiks.backend.service.SigatokaEvaluacionService sigatokaEvaluacionService;

    @GetMapping("/por-cedula/{cedula}")
    public ResponseEntity<List<Object>> consultarAuditoriasPorCedula(@PathVariable String cedula) {
        List<Object> resumenAuditorias = new ArrayList<>();

        // Auditorías Moko
        List<RegistroMoko> mokos = registroMokoService.getRegistrosByCedula(cedula);
        for (RegistroMoko moko : mokos) {
            Map<String, Object> resumen = new HashMap<>();
            resumen.put("id", moko.getId());
            resumen.put("tipo", "Moko");
            resumen.put("numeroFoco", moko.getNumeroFoco());
            resumen.put("clienteId", moko.getClienteId());
            resumen.put("gpsCoordinates", moko.getGpsCoordinates());
            resumen.put("plantasAfectadas", moko.getPlantasAfectadas());
            resumen.put("fechaDeteccion", moko.getFechaDeteccion());
            resumen.put("sintomaId", moko.getSintomaId());
            resumen.put("sintomasJson", moko.getSintomasJson());
            resumen.put("lote", moko.getLote());
            resumen.put("areaHectareas", moko.getAreaHectareas());
            resumen.put("severidad", moko.getSeveridad());
            resumen.put("metodoComprobacion", moko.getMetodoComprobacion());
            resumen.put("observaciones", moko.getObservaciones());
            resumen.put("fotoPath", moko.getFotoPath());
            resumen.put("fechaCreacion", moko.getFechaCreacion());
            // Buscar nombre del cliente por clientId
            final String[] nombreHacienda = {null};
            if (moko.getClienteId() != null) {
                clientRepository.findById(moko.getClienteId()).ifPresent(c -> {
                    resumen.put("cliente", c.getNombre() + (c.getApellidos() != null ? " " + c.getApellidos() : ""));
                    resumen.put("haciendaCliente", c.getFincaNombre());
                    nombreHacienda[0] = c.getFincaNombre();
                });
            }
            if (resumen.get("cliente") == null) {
                resumen.put("cliente", nombreHacienda[0] != null ? nombreHacienda[0] : "Cliente Desconocido");
                resumen.put("haciendaCliente", nombreHacienda[0]);
            }
            resumenAuditorias.add(resumen);
        }

        // Auditorías Sigatoka - NUEVO SISTEMA
        List<com.lytiks.backend.entity.SigatokaEvaluacion> sigatokaEvaluaciones = 
            sigatokaEvaluacionService.listarEvaluacionesPorCliente(cedula);
        for (com.lytiks.backend.entity.SigatokaEvaluacion evaluacion : sigatokaEvaluaciones) {
            Map<String, Object> resumen = new HashMap<>();
            resumen.put("id", evaluacion.getId());
            resumen.put("tipo", "Sigatoka");
            resumen.put("fecha", evaluacion.getFecha());
            resumen.put("hacienda", evaluacion.getHacienda());
            resumen.put("evaluador", evaluacion.getEvaluador());
            resumen.put("semanaEpidemiologica", evaluacion.getSemanaEpidemiologica());
            resumen.put("periodo", evaluacion.getPeriodo());
            resumen.put("clienteId", evaluacion.getClienteId());
            resumen.put("createdAt", evaluacion.getCreatedAt());
            resumen.put("updatedAt", evaluacion.getUpdatedAt());
            
            // Buscar nombre del cliente por clienteId
            final String[] nombreHaciendaS = {null};
            if (evaluacion.getClienteId() != null) {
                clientRepository.findById(evaluacion.getClienteId()).ifPresent(c -> {
                    resumen.put("cliente", c.getNombre() + (c.getApellidos() != null ? " " + c.getApellidos() : ""));
                    resumen.put("haciendaCliente", c.getFincaNombre());
                    nombreHaciendaS[0] = c.getFincaNombre();
                });
            }
            if (resumen.get("cliente") == null) {
                resumen.put("cliente", nombreHaciendaS[0] != null ? nombreHaciendaS[0] : "Cliente Desconocido");
                resumen.put("haciendaCliente", nombreHaciendaS[0]);
            }
            resumenAuditorias.add(resumen);
        }

        // Auditorías Cultivos
        List<com.lytiks.backend.entity.Audit> auditCultivos = auditService.getAuditoriasByCedula(cedula);
        for (com.lytiks.backend.entity.Audit audit : auditCultivos) {
            Map<String, Object> resumen = new HashMap<>();
            resumen.put("id", audit.getId());
            resumen.put("tipo", "Cultivo");
            resumen.put("hacienda", audit.getHacienda());
            resumen.put("cultivo", audit.getCultivo());
            resumen.put("fecha", audit.getFecha());
            resumen.put("evaluaciones", audit.getEvaluaciones());
            resumen.put("tecnicoId", audit.getTecnicoId());
            resumen.put("estado", audit.getEstado());
            resumen.put("observaciones", audit.getObservaciones());
            // Buscar nombre del cliente por relación client
            String nombreCliente = "Cliente Desconocido";
            final String[] nombreHaciendaC = {null};
            if (audit.getClient() != null) {
                Client c = audit.getClient();
                resumen.put("cliente", c.getNombre() + (c.getApellidos() != null ? " " + c.getApellidos() : ""));
                resumen.put("haciendaCliente", c.getFincaNombre());
                nombreHaciendaC[0] = c.getFincaNombre();
            }
            if (resumen.get("cliente") == null) {
                resumen.put("cliente", nombreHaciendaC[0] != null ? nombreHaciendaC[0] : "Cliente Desconocido");
                resumen.put("haciendaCliente", nombreHaciendaC[0]);
            }
            resumenAuditorias.add(resumen);
        }

        return ResponseEntity.ok(resumenAuditorias);
    }
}
