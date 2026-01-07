package com.lytiks.backend.repository;

import com.lytiks.backend.entity.Sintoma;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface SintomaRepository extends JpaRepository<Sintoma, Long> {
    
    List<Sintoma> findByCategoria(String categoria);
    
    List<Sintoma> findBySeveridad(String severidad);
    
    List<Sintoma> findBySintomaObservableContainingIgnoreCase(String sintomaObservable);
    
    @Query("SELECT DISTINCT s.categoria FROM Sintoma s")
    List<String> findDistinctCategorias();
}