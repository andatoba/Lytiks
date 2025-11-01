package com.lytiks.backend.repository;

import com.lytiks.backend.entity.SigatokaPhoto;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface SigatokaPhotoRepository extends JpaRepository<SigatokaPhoto, Long> {
    List<SigatokaPhoto> findBySigatokaAuditId(Long sigatokaAuditId);
}
