package com.lytiks.backend.repository;

import com.lytiks.backend.entity.IsRol;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface IsRolRepository extends JpaRepository<IsRol, Long> {
    
    Optional<IsRol> findByNombre(String nombre);
}