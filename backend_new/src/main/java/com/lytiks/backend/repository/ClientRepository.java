package com.lytiks.backend.repository;

import com.lytiks.backend.entity.Client;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ClientRepository extends JpaRepository<Client, Long> {
    
    // Buscar cliente por cédula (método principal para autocompletado)
    Optional<Client> findByCedula(String cedula);
    
    // Verificar si existe un cliente con esa cédula
    boolean existsByCedula(String cedula);
    
    // Buscar clientes por nombre (búsqueda parcial)
    List<Client> findByNombreContainingIgnoreCase(String nombre);
    
    // Buscar clientes por apellidos
    List<Client> findByApellidosContainingIgnoreCase(String apellidos);
    
    // Buscar clientes por nombre completo
    @Query("SELECT c FROM Client c WHERE LOWER(CONCAT(c.nombre, ' ', COALESCE(c.apellidos, ''))) LIKE LOWER(CONCAT('%', :nombreCompleto, '%'))")
    List<Client> findByNombreCompletoContaining(@Param("nombreCompleto") String nombreCompleto);
    
    // Buscar clientes por técnico asignado
    List<Client> findByTecnicoAsignadoId(Long tecnicoId);
    
    // Buscar clientes activos
    List<Client> findByEstado(String estado);
    
    // Buscar clientes por municipio
    List<Client> findByMunicipioContainingIgnoreCase(String municipio);
    
    // Buscar clientes por departamento
    List<Client> findByDepartamentoContainingIgnoreCase(String departamento);
    
    // Buscar clientes por tipo de productor
    List<Client> findByTipoProductor(String tipoProductor);
    
    // Buscar clientes por cultivos principales
    List<Client> findByCultivosPrincipalesContainingIgnoreCase(String cultivo);
    
    // Buscar clientes por nombre de finca
    List<Client> findByFincaNombreContainingIgnoreCase(String fincaNombre);
    
    // Contar clientes por técnico
    long countByTecnicoAsignadoId(Long tecnicoId);
    
    // Contar clientes activos
    long countByEstado(String estado);
    
    // Obtener clientes recientes (últimos registrados)
    @Query("SELECT c FROM Client c ORDER BY c.fechaRegistro DESC")
    List<Client> findRecentClients();
    
    // Buscar clientes en un rango de hectáreas
    List<Client> findByFincaHectareasBetween(Double minHectareas, Double maxHectareas);
    
    // Buscar clientes por teléfono
    Optional<Client> findByTelefono(String telefono);
    
    // Buscar clientes por email
    Optional<Client> findByEmail(String email);
}