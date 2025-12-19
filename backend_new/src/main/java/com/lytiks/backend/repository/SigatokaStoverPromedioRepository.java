package com.lytiks.backend.repository;

import com.lytiks.backend.entity.SigatokaStoverPromedio;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.Optional;

@Repository
public interface SigatokaStoverPromedioRepository extends JpaRepository<SigatokaStoverPromedio, Long> {
    Optional<SigatokaStoverPromedio> findByEvaluacionId(Long evaluacionId);
    void deleteByEvaluacionId(Long evaluacionId);
}
