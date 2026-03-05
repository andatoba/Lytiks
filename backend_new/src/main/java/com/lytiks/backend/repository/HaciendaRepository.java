package com.lytiks.backend.repository;

import com.lytiks.backend.entity.Hacienda;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface HaciendaRepository extends JpaRepository<Hacienda, Long> {
    
    List<Hacienda> findByClienteIdAndEstado(Long clienteId, String estado);
    
    List<Hacienda> findByClienteId(Long clienteId);
    
    List<Hacienda> findByEstado(String estado);
    
    List<Hacienda> findByNombreContainingIgnoreCaseAndEstado(String nombre, String estado);
}
