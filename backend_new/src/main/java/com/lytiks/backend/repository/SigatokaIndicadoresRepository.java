package com.lytiks.backend.repository;

import com.lytiks.backend.entity.SigatokaIndicadores;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.Optional;

@Repository
public interface SigatokaIndicadoresRepository extends JpaRepository<SigatokaIndicadores, Long> {
    Optional<SigatokaIndicadores> findByEvaluacionId(Long evaluacionId);
    void deleteByEvaluacionId(Long evaluacionId);
}
