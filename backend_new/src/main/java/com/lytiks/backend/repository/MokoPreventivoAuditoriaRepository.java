package com.lytiks.backend.repository;

import com.lytiks.backend.entity.MokoPreventivoAuditoria;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface MokoPreventivoAuditoriaRepository extends JpaRepository<MokoPreventivoAuditoria, Long> {
    Optional<MokoPreventivoAuditoria> findTopByFocoIdOrderByCreatedAtDesc(Long focoId);
}
