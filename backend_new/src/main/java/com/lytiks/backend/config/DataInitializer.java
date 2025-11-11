package com.lytiks.backend.config;

import com.lytiks.backend.entity.User;
import com.lytiks.backend.entity.Client;
import com.lytiks.backend.entity.Audit;
import com.lytiks.backend.entity.AuditScore;
import com.lytiks.backend.entity.Sintoma;
import com.lytiks.backend.entity.ProductoContencion;
import com.lytiks.backend.repository.UserRepository;
import com.lytiks.backend.repository.ClientRepository;
import com.lytiks.backend.repository.AuditRepository;
import com.lytiks.backend.repository.AuditScoreRepository;
import com.lytiks.backend.repository.SintomaRepository;
import com.lytiks.backend.repository.ProductoRepository;
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
    private SintomaRepository sintomaRepository;

    @Autowired
    private ProductoRepository productoRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Override
    public void run(String... args) throws Exception {
        initializeUsers();
        initializeClients();
        initializeAudits();
        initializeSintomas();
        initializeProductos();
    }

    private void initializeProductos() {
        if (productoRepository.count() == 0) {
            System.out.println("🌿 Inicializando productos de contención...");

            ProductoContencion p1 = new ProductoContencion(null,
                    "Cobre Hidróxido 50% WP",
                    "Polvo mojable - 250 g",
                    "2 g / L",
                    "https://example.com/productos/cobre_hidroxido_250g.pdf");
            productoRepository.save(p1);

            ProductoContencion p2 = new ProductoContencion(null,
                    "Ciprodinazol 20% SC",
                    "Concentrado soluble - 1 L",
                    "10 ml / 10 L",
                    "https://example.com/productos/ciprodinazol_1l.pdf");
            productoRepository.save(p2);

            ProductoContencion p3 = new ProductoContencion(null,
                    "Cloranfenicol 10% WG",
                    "Gránulos - 500 g",
                    "5 g / L",
                    "https://example.com/productos/cloranfenicol_500g.pdf");
            productoRepository.save(p3);

            ProductoContencion p4 = new ProductoContencion(null,
                    "Biofungicida Bacillus subtilis",
                    "Suspensión - 500 ml",
                    "50 ml / 10 L",
                    "https://example.com/productos/bacillus_subtilis_500ml.pdf");
            productoRepository.save(p4);

            System.out.println("✅ 4 productos de contención creados exitosamente");
        } else {
            System.out.println("ℹ️ Los productos de contención ya existen");
        }
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

    private void initializeSintomas() {
        if (sintomaRepository.count() == 0) {
            System.out.println("🌱 Inicializando síntomas de Moko...");

            // Síntomas Externos
            Sintoma sintoma1 = new Sintoma(null, "Externo", "Amarillamiento de hojas bajas", 
                "Primeras hojas muestran amarillamiento desde el borde hacia el centro.", "Bajo");
            sintomaRepository.save(sintoma1);

            Sintoma sintoma2 = new Sintoma(null, "Externo", "Marchitez o colapso de hojas", 
                "Las hojas se doblan en forma de \"paraguas\"; planta pierde turgencia rápidamente.", "Medio");
            sintomaRepository.save(sintoma2);

            Sintoma sintoma3 = new Sintoma(null, "Externo", "Muerte apical / pseudotallo blando", 
                "La parte superior del pseudotallo se ablanda, colapsa o presenta exudado.", "Alto");
            sintomaRepository.save(sintoma3);

            Sintoma sintoma4 = new Sintoma(null, "Externo", "Hojas jóvenes torcidas o con bordes secos", 
                "Indica bloqueo vascular incipiente; hojas no se abren completamente.", "Medio");
            sintomaRepository.save(sintoma4);

            // Síntomas en Fruto
            Sintoma sintoma5 = new Sintoma(null, "Fruto", "Frutos pequeños o deformados", 
                "Racimos con dedos torcidos, desarrollo irregular o abortados.", "Medio");
            sintomaRepository.save(sintoma5);

            Sintoma sintoma6 = new Sintoma(null, "Fruto", "Pulpa con manchas marrón-rojizas", 
                "Al cortar el fruto se observan vetas o anillos marrones, típicos del Moko.", "Alto");
            sintomaRepository.save(sintoma6);

            Sintoma sintoma7 = new Sintoma(null, "Fruto", "Exudado bacteriano (\"ooze\") en pedúnculo", 
                "Gotas blancas o amarillentas viscosas en el corte del racimo.", "Alto");
            sintomaRepository.save(sintoma7);

            Sintoma sintoma8 = new Sintoma(null, "Flor masculina", "Necrosis o ennegrecimiento en el nudo floral", 
                "Zona de flor masculina muerta o seca, punto frecuente de infección.", "Medio");
            sintomaRepository.save(sintoma8);

            // Síntomas en Pseudotallo
            Sintoma sintoma9 = new Sintoma(null, "Pseudotallo", "Amarillamiento de hojas bajas", 
                "Al cortar el pseudotallo transversalmente se ven anillos concéntricos cafés oscuros.", "Alto");
            sintomaRepository.save(sintoma9);

            Sintoma sintoma10 = new Sintoma(null, "Pseudotallo", "Puntos café en haces vasculares longitudinales", 
                "Al cortar verticalmente el pseudotallo se aprecian líneas o puntos oscuros en los haces.", "Alto");
            sintomaRepository.save(sintoma10);

            Sintoma sintoma11 = new Sintoma(null, "Pseudotallo", "Exudado viscoso al presionar corte", 
                "Sale líquido blanquecino-amarillo de textura mucilaginosa.", "Alto");
            sintomaRepository.save(sintoma11);

            // Síntomas en Hoja
            Sintoma sintoma12 = new Sintoma(null, "Hoja", "Decoloración en pecíolos o base de hojas", 
                "Cuando se corta la base del pecíolo se observan líneas marrones.", "Medio");
            sintomaRepository.save(sintoma12);

            // Síntomas en Rizoma
            Sintoma sintoma13 = new Sintoma(null, "Rizoma", "Oscurecimiento en el corazón del rizoma", 
                "Corte del cormo muestra anillos o puntos marrones, a veces con olor agrio.", "Alto");
            sintomaRepository.save(sintoma13);

            System.out.println("✅ 13 síntomas de Moko creados exitosamente");
        } else {
            System.out.println("ℹ️ Los síntomas de Moko ya existen");
        }
    }
}