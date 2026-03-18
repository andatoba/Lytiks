package com.lytiks.backend.service;

import com.lytiks.backend.dto.PlagasResumenDTO;
import com.lytiks.backend.entity.Client;
import com.lytiks.backend.entity.PlagasResumenAuditoria;
import com.lytiks.backend.repository.ClientRepository;
import com.lytiks.backend.repository.PlagasResumenAuditoriaRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Service
public class PlagasResumenService {

    @Autowired
    private ClientRepository clientRepository;

    @Autowired
    private PlagasResumenAuditoriaRepository plagasResumenAuditoriaRepository;

    public Map<String, Object> guardarResumen(PlagasResumenDTO dto) {
        Map<String, Object> response = new LinkedHashMap<>();

        Client client = resolveClient(dto);
        if (client == null) {
            response.put("success", false);
            response.put("message", "Cliente no encontrado. Envíe clientId o cedulaCliente válido.");
            return response;
        }

        if (dto.getFecha() == null || dto.getFecha().trim().isEmpty()) {
            response.put("success", false);
            response.put("message", "La fecha es obligatoria.");
            return response;
        }
        if (dto.getLote() == null || dto.getLote().trim().isEmpty()) {
            response.put("success", false);
            response.put("message", "El lote es obligatorio.");
            return response;
        }
        if (dto.getPlaga() == null || dto.getPlaga().trim().isEmpty()) {
            response.put("success", false);
            response.put("message", "La plaga es obligatoria.");
            return response;
        }

        PlagasResumenAuditoria entity = new PlagasResumenAuditoria();
        entity.setClient(client);
        entity.setTecnicoId(dto.getTecnicoId());
        entity.setFecha(LocalDate.parse(dto.getFecha()));
        entity.setLote(dto.getLote().trim());
        entity.setPlaga(dto.getPlaga().trim());

        entity.setTotalHuevo(dto.getTotalHuevo());
        entity.setTotalPequena(dto.getTotalPequena());
        entity.setTotalMediana(dto.getTotalMediana());
        entity.setTotalGrande(dto.getTotalGrande());
        entity.setTotalIndividuos(dto.getTotalIndividuos());
        entity.setPorcentajeDanio(dto.getPorcentajeDanio());

        entity.setPromedioHuevo(dto.getPromedioHuevo());
        entity.setPromedioPequena(dto.getPromedioPequena());
        entity.setPromedioMediana(dto.getPromedioMediana());
        entity.setPromedioGrande(dto.getPromedioGrande());
        entity.setPromedioTotal(dto.getPromedioTotal());
        entity.setPromedioDanio(dto.getPromedioDanio());

        entity.setPorcentajeHuevo(dto.getPorcentajeHuevo());
        entity.setPorcentajePequena(dto.getPorcentajePequena());
        entity.setPorcentajeMediana(dto.getPorcentajeMediana());
        entity.setPorcentajeGrande(dto.getPorcentajeGrande());
        entity.setNumeroMuestras(dto.getNumeroMuestras());

        PlagasResumenAuditoria saved = plagasResumenAuditoriaRepository.save(entity);

        response.put("success", true);
        response.put("message", "Resumen de plagas guardado correctamente.");
        response.put("id", saved.getId());
        response.put("fecha", saved.getFecha());
        response.put("lote", saved.getLote());
        response.put("plaga", saved.getPlaga());
        response.put("clienteId", client.getId());
        response.put("clienteNombre", client.getNombreCompleto());
        return response;
    }

    public List<PlagasResumenAuditoria> obtenerPorCliente(Long clientId) {
        return plagasResumenAuditoriaRepository.findByClientIdOrderByFechaDescCreatedAtDesc(clientId);
    }

    public List<PlagasResumenAuditoria> obtenerPorTecnico(Long tecnicoId) {
        return plagasResumenAuditoriaRepository.findByTecnicoIdOrderByFechaDescCreatedAtDesc(tecnicoId);
    }

    public List<PlagasResumenAuditoria> obtenerTodos() {
        return plagasResumenAuditoriaRepository.findAll();
    }

    private Client resolveClient(PlagasResumenDTO dto) {
        if (dto.getClientId() != null) {
            Optional<Client> byId = clientRepository.findById(dto.getClientId());
            if (byId.isPresent()) {
                return byId.get();
            }
        }
        if (dto.getCedulaCliente() != null && !dto.getCedulaCliente().trim().isEmpty()) {
            return clientRepository.findByCedula(dto.getCedulaCliente().trim()).orElse(null);
        }
        return null;
    }
}
