package com.lytiks.backend.repository;

import com.lytiks.backend.entity.SigatokaParameter;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface SigatokaParameterRepository extends JpaRepository<SigatokaParameter, Long> {
    
    List<SigatokaParameter> findBySigatokaAuditId(Long sigatokaAuditId);
    
    List<SigatokaParameter> findBySigatokaAuditIdAndParameterName(Long sigatokaAuditId, String parameterName);
    
    List<SigatokaParameter> findBySigatokaAuditIdAndWeekNumber(Long sigatokaAuditId, Integer weekNumber);
}