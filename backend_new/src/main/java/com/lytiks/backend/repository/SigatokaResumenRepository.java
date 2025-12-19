package com.lytiks.backend.repository;

import com.lytiks.backend.entity.SigatokaResumen;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.Optional;

@Repository
public interface SigatokaResumenRepository extends JpaRepository<SigatokaResumen, Long> {
    Optional<SigatokaResumen> findByEvaluacionId(Long evaluacionId);
    void deleteByEvaluacionId(Long evaluacionId);
}
