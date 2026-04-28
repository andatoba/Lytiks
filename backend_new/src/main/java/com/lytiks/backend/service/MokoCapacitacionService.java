package com.lytiks.backend.service;

import com.lytiks.backend.entity.MokoCapacitacion;
import com.lytiks.backend.repository.MokoCapacitacionRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class MokoCapacitacionService {

    @Autowired
    private MokoCapacitacionRepository repository;

    public MokoCapacitacion save(MokoCapacitacion capacitacion) {
        return repository.save(capacitacion);
    }

    public List<MokoCapacitacion> findByClienteAndLote(Long clienteId, String hacienda, String lote) {
        return repository.findByClienteAndLote(clienteId, hacienda, lote);
    }

    public Long countByClienteAndLote(Long clienteId, String hacienda, String lote) {
        return repository.countByClienteAndLote(clienteId, hacienda, lote);
    }
}
