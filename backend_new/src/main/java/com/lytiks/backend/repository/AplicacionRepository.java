package com.lytiks.backend.repository;

import com.lytiks.backend.entity.Aplicacion;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface AplicacionRepository extends JpaRepository<Aplicacion, Long> {
}
