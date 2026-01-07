package com.lytiks.backend.repository;

import com.lytiks.backend.entity.SigatokaLote;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface SigatokaLoteRepository extends JpaRepository<SigatokaLote, Long> {
    
    List<SigatokaLote> findByEvaluacionIdOrderById(Long evaluacionId);
}
