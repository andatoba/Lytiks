package com.lytiks.backend.config;

import com.lytiks.backend.entity.User;
import com.lytiks.backend.entity.Client;
import com.lytiks.backend.entity.Audit;
import com.lytiks.backend.entity.AuditScore;
import com.lytiks.backend.repository.UserRepository;
import com.lytiks.backend.repository.ClientRepository;
import com.lytiks.backend.repository.AuditRepository;
import com.lytiks.backend.repository.AuditScoreRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import java.time.LocalDateTime;

@Component
public class DataInitializer implements CommandLineRunner {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private ClientRepository clientRepository;

    @Autowired
    private AuditRepository auditRepository;

    @Autowired
    private AuditScoreRepository auditScoreRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Override
    public void run(String... args) throws Exception {
        initializeUsers();
        initializeClients();
        initializeAudits();
    }

    private void initializeUsers() {
        // Crear usuario técnico si no existe
        if (!userRepository.existsByUsername("tecnico")) {
            User tecnico = new User();
            tecnico.setUsername("tecnico");
            tecnico.setPassword(passwordEncoder.encode("tecnico123"));
            tecnico.setFirstName("Técnico");
            tecnico.setLastName("Principal");
            tecnico.setEmail("tecnico@lytiks.com");
            tecnico.setRole(User.Role.TECHNICIAN);
            tecnico.setActive(true);
            
            userRepository.save(tecnico);
            System.out.println("✅ Usuario técnico creado exitosamente");
        } else {
            System.out.println("ℹ️ Usuario técnico ya existe");
        }

        System.out.println("🔐 Credenciales por defecto:");
        System.out.println("   Técnico: tecnico / tecnico123");
    }

    private void initializeClients() {
        if (clientRepository.count() == 0) {
            // Cliente 1 - Banano
            Client cliente1 = new Client();
            cliente1.setCedula("12345678");
            cliente1.setNombre("Juan Carlos");
            cliente1.setApellidos("Rodríguez López");
            cliente1.setTelefono("+57 300 1234567");
            cliente1.setEmail("juan.rodriguez@email.com");
            cliente1.setDireccion("Vereda La Esperanza, Km 15 vía Medellín");
            cliente1.setParroquia("La Esperanza");
            cliente1.setFincaNombre("Finca Los Plátanos");
            cliente1.setFincaHectareas(25.5);
            cliente1.setCultivosPrincipales("BANANO");
            cliente1.setFechaRegistro(LocalDateTime.now().minusDays(30));
            cliente1.setEstado("ACTIVO");
            cliente1.setGeolocalizacionLat(6.25184);
            cliente1.setGeolocalizacionLng(-75.56359);
            cliente1.setObservaciones("Cliente de prueba para banano");
            cliente1.setTecnicoAsignadoId(1L);
            clientRepository.save(cliente1);

            // Cliente 2 - Palma
            Client cliente2 = new Client();
            cliente2.setCedula("87654321");
            cliente2.setNombre("María Elena");
            cliente2.setApellidos("Gómez Herrera");
            cliente2.setTelefono("+57 301 9876543");
            cliente2.setEmail("maria.gomez@email.com");
            cliente2.setDireccion("Corregimiento San José, Finca La Palma");
            cliente2.setParroquia("San José");
            cliente2.setFincaNombre("Palmas del Pacífico");
            cliente2.setFincaHectareas(45.0);
            cliente2.setCultivosPrincipales("PALMA");
            cliente2.setFechaRegistro(LocalDateTime.now().minusDays(15));
            cliente2.setEstado("ACTIVO");
            cliente2.setGeolocalizacionLat(3.45164);
            cliente2.setGeolocalizacionLng(-76.53201);
            cliente2.setObservaciones("Cliente de prueba para palma");
            cliente2.setTecnicoAsignadoId(1L);
            clientRepository.save(cliente2);

            // Cliente 3 - Banano y Plátano
            Client cliente3 = new Client();
            cliente3.setCedula("45678912");
            cliente3.setNombre("Carlos Alberto");
            cliente3.setApellidos("Martínez Sánchez");
            cliente3.setTelefono("+57 315 5556789");
            cliente3.setEmail("carlos.martinez@email.com");
            cliente3.setDireccion("Zona Rural, Sector El Dorado");
            cliente3.setParroquia("El Dorado");
            cliente3.setFincaNombre("El Dorado Verde");
            cliente3.setFincaHectareas(18.3);
            cliente3.setCultivosPrincipales("BANANO, PLÁTANO");
            cliente3.setFechaRegistro(LocalDateTime.now().minusDays(7));
            cliente3.setEstado("ACTIVO");
            cliente3.setGeolocalizacionLat(7.11392);
            cliente3.setGeolocalizacionLng(-73.1198);
            cliente3.setObservaciones("Cliente de prueba para banano y plátano");
            cliente3.setTecnicoAsignadoId(1L);
            clientRepository.save(cliente3);

            System.out.println("✅ 3 clientes de prueba creados exitosamente");
        } else {
            System.out.println("ℹ️ Los clientes ya existen");
        }
    }

    private void initializeAudits() {
        if (auditRepository.count() == 0) {
            User tecnico = userRepository.findByUsername("tecnico").orElse(null);
            if (tecnico != null) {
                // Auditoría 1 - Banano completada
                Audit auditoria1 = new Audit();
                auditoria1.setHacienda("Finca Los Plátanos");
                auditoria1.setCultivo("BANANO");
                auditoria1.setFecha(LocalDateTime.now().minusDays(5));
                auditoria1.setTecnicoId(tecnico.getId());
                auditoria1.setEstado("COMPLETADA");
                auditoria1.setObservaciones("Auditoría completa de banano. Buenos resultados en enfunde y selección.");
                auditRepository.save(auditoria1);

                // Auditoría 2 - Palma en progreso
                Audit auditoria2 = new Audit();
                auditoria2.setHacienda("Palmas del Pacífico");
                auditoria2.setCultivo("PALMA");
                auditoria2.setFecha(LocalDateTime.now().minusDays(2));
                auditoria2.setTecnicoId(tecnico.getId());
                auditoria2.setEstado("EN_PROGRESO");
                auditoria2.setObservaciones("Auditoría en curso. Evaluando manejo fitosanitario.");
                auditRepository.save(auditoria2);

                // Auditoría 3 - Banano pendiente
                Audit auditoria3 = new Audit();
                auditoria3.setHacienda("El Dorado Verde");
                auditoria3.setCultivo("BANANO");
                auditoria3.setFecha(LocalDateTime.now().minusDays(1));
                auditoria3.setTecnicoId(tecnico.getId());
                auditoria3.setEstado("PENDIENTE");
                auditoria3.setObservaciones("Auditoría programada para mañana.");
                auditRepository.save(auditoria3);

                System.out.println("✅ 3 auditorías de prueba creadas exitosamente");
            }
        } else {
            System.out.println("ℹ️ Las auditorías ya existen");
        }
    }
}