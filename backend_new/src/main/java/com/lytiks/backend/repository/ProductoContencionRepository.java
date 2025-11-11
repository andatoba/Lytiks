package com.lytiks.backend.repository;

import com.lytiks.backend.entity.ProductoContencion;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ProductoContencionRepository extends JpaRepository<ProductoContencion, Long> {

    // Buscar por nombre
    Optional<ProductoContencion> findByNombre(String nombre);

    // Buscar por nombre que contenga texto (case insensitive)
    @Query("SELECT p FROM ProductoContencion p WHERE LOWER(p.nombre) LIKE LOWER(CONCAT('%', :nombre, '%'))")
    List<ProductoContencion> findByNombreContainingIgnoreCase(String nombre);

    // Obtener productos ordenados por nombre
    List<ProductoContencion> findAllByOrderByNombreAsc();

    // Contar total de productos
    @Query("SELECT COUNT(p) FROM ProductoContencion p")
    Long countTotalProductos();
}