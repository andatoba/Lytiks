package com.lytiks.backend.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.lytiks.backend.entity.SigatokaAudit;
import com.lytiks.backend.repository.SigatokaAuditRepository;

@Service
public class SigatokaAuditService {
    @Autowired
    private SigatokaAuditRepository sigatokaAuditRepository;

    public java.util.List<SigatokaAudit> getAuditoriasByCedula(String cedula) {
        return sigatokaAuditRepository.findByCedulaCliente(cedula);
    }
}
