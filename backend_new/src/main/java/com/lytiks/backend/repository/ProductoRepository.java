package com.lytiks.backend.repository;

import com.lytiks.backend.entity.ProductoContencion;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ProductoRepository extends JpaRepository<ProductoContencion, Long> {
}
