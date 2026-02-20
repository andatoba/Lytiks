package com.lytiks.backend.repository;

import com.lytiks.backend.entity.ProductoSegMoko;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ProductoSegMokoRepository extends JpaRepository<ProductoSegMoko, Long> {
    
    List<ProductoSegMoko> findByActivoTrueOrderByNombreAsc();
}
