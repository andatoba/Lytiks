package com.lytiks.backend.service;

import com.lytiks.backend.entity.MokoMuestra;
import com.lytiks.backend.repository.MokoMuestraRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class MokoMuestraService {

    @Autowired
    private MokoMuestraRepository repository;

    public MokoMuestra save(MokoMuestra muestra) {
        return repository.save(muestra);
    }

    public Optional<MokoMuestra> findById(Long id) {
        return repository.findById(id);
    }

    public List<MokoMuestra> buscarPorCliente(
            Long clienteId,
            String lote,
            String tipo,
            String query
    ) {
        return repository.buscarPorCliente(clienteId, lote, tipo, query);
    }
}
