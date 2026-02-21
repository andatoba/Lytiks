package com.lytiks.backend.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.info.License;
import io.swagger.v3.oas.models.security.SecurityScheme;
import io.swagger.v3.oas.models.security.SecurityRequirement;
import io.swagger.v3.oas.models.Components;
import io.swagger.v3.oas.models.servers.Server;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class SwaggerConfig {

    @Value("${swagger.server.url:http://localhost:8081}")
    private String serverUrl;

    @Value("${swagger.server.description:Servidor Local}")
    private String serverDescription;

    @Bean
    public OpenAPI lytiksOpenAPI() {
        return new OpenAPI()
                .addServersItem(new Server()
                        .url(serverUrl)
                        .description(serverDescription))
                .info(new Info()
                        .title("Lytiks API")
                        .description("API REST para el sistema Lytiks - Gestión agrícola y análisis de enfermedades en cultivos")
                        .version("v1.0.0")
                        .contact(new Contact()
                                .name("Lytiks Team")
                                .email("support@lytiks.com"))
                        .license(new License()
                                .name("Apache 2.0")
                                .url("https://www.apache.org/licenses/LICENSE-2.0.html")))
                .addSecurityItem(new SecurityRequirement()
                        .addList("Bearer Authentication"))
                .components(new Components()
                        .addSecuritySchemes("Bearer Authentication",
                                new SecurityScheme()
                                        .type(SecurityScheme.Type.HTTP)
                                        .scheme("bearer")
                                        .bearerFormat("JWT")
                                        .description("Ingresa el token JWT obtenido del endpoint de autenticación")));
    }
}
