package com.lytiks.backend.repository;

import com.lytiks.backend.entity.MokoContencionAuditoria;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface MokoContencionAuditoriaRepository extends JpaRepository<MokoContencionAuditoria, Long> {
    Optional<MokoContencionAuditoria> findTopByFocoIdOrderByCreatedAtDesc(Long focoId);
}
