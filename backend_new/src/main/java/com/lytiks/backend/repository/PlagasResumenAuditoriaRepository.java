package com.lytiks.backend.repository;

import com.lytiks.backend.entity.PlagasResumenAuditoria;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface PlagasResumenAuditoriaRepository extends JpaRepository<PlagasResumenAuditoria, Long> {
    List<PlagasResumenAuditoria> findByClientIdOrderByFechaDescCreatedAtDesc(Long clientId);

    List<PlagasResumenAuditoria> findByTecnicoIdOrderByFechaDescCreatedAtDesc(Long tecnicoId);
}
