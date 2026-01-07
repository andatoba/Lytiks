package com.lytiks.backend.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.lytiks.backend.entity.Audit;
import com.lytiks.backend.repository.AuditRepository;

@Service
public class AuditService {
    @Autowired
    private AuditRepository auditRepository;

    public java.util.List<Audit> getAuditoriasByCedula(String cedula) {
        return auditRepository.findByCedulaCliente(cedula);
    }
}
