package com.lytiks.backend.repository;

import com.lytiks.backend.entity.SigatokaMuestraCompleta;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface SigatokaMuestraCompletaRepository extends JpaRepository<SigatokaMuestraCompleta, Long> {
    
    List<SigatokaMuestraCompleta> findByLoteIdOrderByMuestraNumAsc(Long loteId);
    
    List<SigatokaMuestraCompleta> findByLote_EvaluacionIdOrderByMuestraNumAsc(Long evaluacionId);
}
