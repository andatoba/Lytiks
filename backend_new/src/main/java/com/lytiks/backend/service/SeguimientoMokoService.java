package com.lytiks.backend.service;

import com.lytiks.backend.entity.SeguimientoMoko;
import com.lytiks.backend.repository.SeguimientoMokoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
public class SeguimientoMokoService {

    @Autowired
    private SeguimientoMokoRepository seguimientoMokoRepository;

    // Guardar nuevo seguimiento
    public SeguimientoMoko save(SeguimientoMoko seguimiento) {
        seguimiento.setFechaCreacion(LocalDateTime.now());
        seguimiento.setFechaSeguimiento(LocalDateTime.now());
        return seguimientoMokoRepository.save(seguimiento);
    }

    // Obtener todos los seguimientos
    public List<SeguimientoMoko> getAllSeguimientos() {
        return seguimientoMokoRepository.findAll();
    }

    // Obtener seguimiento por ID
    public Optional<SeguimientoMoko> getSeguimientoById(Long id) {
        return seguimientoMokoRepository.findById(id);
    }

    // Obtener seguimientos por foco ID
    public List<SeguimientoMoko> getSeguimientosByFocoId(Long focoId) {
        return seguimientoMokoRepository.findByFocoIdOrderByFechaSeguimientoDesc(focoId);
    }

    // Obtener seguimientos por número de foco
    public List<SeguimientoMoko> getSeguimientosByNumeroFoco(Integer numeroFoco) {
        return seguimientoMokoRepository.findByNumeroFocoOrderByFechaSeguimientoDesc(numeroFoco);
    }

    // Obtener último seguimiento de un foco
    public Optional<SeguimientoMoko> getLastSeguimientoByFocoId(Long focoId) {
        List<SeguimientoMoko> seguimientos = seguimientoMokoRepository.findLastSeguimientoByFocoId(focoId);
        return seguimientos.isEmpty() ? Optional.empty() : Optional.of(seguimientos.get(0));
    }

    // Contar seguimientos por foco
    public Long countSeguimientosByFocoId(Long focoId) {
        return seguimientoMokoRepository.countSeguimientosByFocoId(focoId);
    }

    // Actualizar seguimiento existente
    public SeguimientoMoko updateSeguimiento(Long id, SeguimientoMoko seguimientoActualizado) {
        Optional<SeguimientoMoko> seguimientoExistente = seguimientoMokoRepository.findById(id);
        
        if (seguimientoExistente.isPresent()) {
            SeguimientoMoko seguimiento = seguimientoExistente.get();
            
            // Actualizar campos
            seguimiento.setPlantasAfectadas(seguimientoActualizado.getPlantasAfectadas());
            seguimiento.setPlantasInyectadas(seguimientoActualizado.getPlantasInyectadas());
            seguimiento.setControlVectores(seguimientoActualizado.getControlVectores());
            seguimiento.setCuarentenaActiva(seguimientoActualizado.getCuarentenaActiva());
            seguimiento.setUnicaEntradaHabilitada(seguimientoActualizado.getUnicaEntradaHabilitada());
            seguimiento.setEliminacionMalezaHospedera(seguimientoActualizado.getEliminacionMalezaHospedera());
            seguimiento.setControlPicudoAplicado(seguimientoActualizado.getControlPicudoAplicado());
            seguimiento.setInspeccionPlantasVecinas(seguimientoActualizado.getInspeccionPlantasVecinas());
            seguimiento.setCorteRiego(seguimientoActualizado.getCorteRiego());
            seguimiento.setPediluvioActivo(seguimientoActualizado.getPediluvioActivo());
            seguimiento.setPpmSolucionDesinfectante(seguimientoActualizado.getPpmSolucionDesinfectante());
            seguimiento.setFechaSeguimiento(LocalDateTime.now());
            
            return seguimientoMokoRepository.save(seguimiento);
        } else {
            throw new RuntimeException("Seguimiento no encontrado con ID: " + id);
        }
    }

    // Eliminar seguimiento
    public boolean deleteSeguimiento(Long id) {
        if (seguimientoMokoRepository.existsById(id)) {
            seguimientoMokoRepository.deleteById(id);
            return true;
        }
        return false;
    }

    // Obtener seguimientos por semana
    public List<SeguimientoMoko> getSeguimientosBySemana(Integer semanaInicio) {
        return seguimientoMokoRepository.findBySemanaInicio(semanaInicio);
    }

    // Obtener seguimientos con pediluvio activo
    public List<SeguimientoMoko> getSeguimientosConPediluvioActivo() {
        return seguimientoMokoRepository.findSeguimientosConPediluvioActivo();
    }

    // Obtener seguimientos con cuarentena activa
    public List<SeguimientoMoko> getSeguimientosConCuarentenaActiva() {
        return seguimientoMokoRepository.findSeguimientosConCuarentenaActiva();
    }
}