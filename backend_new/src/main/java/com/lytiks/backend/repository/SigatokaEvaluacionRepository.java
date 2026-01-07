package com.lytiks.backend.repository;

import com.lytiks.backend.entity.SigatokaEvaluacion;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface SigatokaEvaluacionRepository extends JpaRepository<SigatokaEvaluacion, Long> {
    List<SigatokaEvaluacion> findByClienteIdOrderByFechaDesc(Long clienteId);
}
