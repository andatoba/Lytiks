package com.lytiks.backend.repository;

import com.lytiks.backend.entity.SigatokaEstadoEvolutivo;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.Optional;

@Repository
public interface SigatokaEstadoEvolutivoRepository extends JpaRepository<SigatokaEstadoEvolutivo, Long> {
    Optional<SigatokaEstadoEvolutivo> findByEvaluacionId(Long evaluacionId);
    void deleteByEvaluacionId(Long evaluacionId);
}
