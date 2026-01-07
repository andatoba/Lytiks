package com.lytiks.backend.repository;

import com.lytiks.backend.entity.ProductoContencion;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ProductoContencionRepository extends JpaRepository<ProductoContencion, Long> {

    // Métodos personalizados pueden ir aquí, por ejemplo búsquedas por campos de Producto

    // Contar total de productos
    @Query("SELECT COUNT(p) FROM ProductoContencion p")
    Long countTotalProductos();
}