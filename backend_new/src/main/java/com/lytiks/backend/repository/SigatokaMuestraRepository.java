package com.lytiks.backend.repository;

import com.lytiks.backend.entity.SigatokaMuestra;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface SigatokaMuestraRepository extends JpaRepository<SigatokaMuestra, Long> {
    List<SigatokaMuestra> findByEvaluacionIdOrderByNumeroMuestraAsc(Long evaluacionId);
    void deleteByEvaluacionId(Long evaluacionId);
}
