package com.lytiks.backend.repository;

import com.lytiks.backend.entity.IsUsuario;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface IsUsuarioRepository extends JpaRepository<IsUsuario, Long> {
    
    Optional<IsUsuario> findByUsuario(String usuario);
    
    boolean existsByUsuario(String usuario);
    
    @Query("SELECT u FROM IsUsuario u WHERE u.usuario = :usuario AND u.estado = 'A'")
    Optional<IsUsuario> findActiveUserByUsuario(@Param("usuario") String usuario);
}