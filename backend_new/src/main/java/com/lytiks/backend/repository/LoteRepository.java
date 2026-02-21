package com.lytiks.backend.repository;

import com.lytiks.backend.entity.Lote;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface LoteRepository extends JpaRepository<Lote, Long> {
    
    List<Lote> findByHaciendaIdAndEstado(Long haciendaId, String estado);
    
    List<Lote> findByHaciendaId(Long haciendaId);
    
    List<Lote> findByEstado(String estado);
    
    List<Lote> findByNombreContainingIgnoreCaseAndEstado(String nombre, String estado);
    
    List<Lote> findByCodigoContainingIgnoreCase(String codigo);
}
