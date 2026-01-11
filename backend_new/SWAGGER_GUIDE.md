# Swagger UI - Lytiks API

## 📋 Descripción

Se ha implementado Swagger UI (OpenAPI 3) para la documentación interactiva de la API de Lytiks. Esto permite visualizar, probar y comprender todos los endpoints disponibles de manera sencilla.

## 🚀 Acceso a Swagger UI

Una vez que la aplicación esté ejecutándose, puedes acceder a Swagger UI a través de las siguientes URLs:

### Local
- **Swagger UI**: http://localhost:8080/api/swagger-ui.html
- **API Docs JSON**: http://localhost:8080/api/api-docs

### Producción (ajustar según tu dominio)
- **Swagger UI**: https://tu-dominio.com/api/swagger-ui.html
- **API Docs JSON**: https://tu-dominio.com/api/api-docs

## 🔧 Configuración Implementada

### 1. Dependencias Maven
Se agregó la dependencia de SpringDoc OpenAPI en `pom.xml`:
```xml
<dependency>
    <groupId>org.springdoc</groupId>
    <artifactId>springdoc-openapi-starter-webmvc-ui</artifactId>
    <version>2.2.0</version>
</dependency>
```

### 2. Configuración de Swagger
Archivo: `src/main/java/com/lytiks/backend/config/SwaggerConfig.java`
- Información general de la API
- Configuración de autenticación JWT Bearer
- Metadatos de contacto y licencia

### 3. Seguridad
Actualización en `SecurityConfig.java` para permitir acceso público a:
- `/v3/api-docs/**`
- `/swagger-ui/**`
- `/swagger-ui.html`

### 4. Propiedades
Configuración en `application.properties`:
```properties
springdoc.api-docs.path=/api-docs
springdoc.swagger-ui.path=/swagger-ui.html
springdoc.swagger-ui.operations-sorter=method
springdoc.swagger-ui.tags-sorter=alpha
```

## 📝 Uso de Swagger UI

### Probar Endpoints sin Autenticación
1. Accede a http://localhost:8080/api/swagger-ui.html
2. Selecciona el endpoint que deseas probar
3. Haz clic en "Try it out"
4. Ingresa los parámetros necesarios
5. Haz clic en "Execute"
6. Revisa la respuesta

### Probar Endpoints con Autenticación JWT
1. Primero, obtén un token haciendo login en `/auth/login`
2. Haz clic en el botón "Authorize" (candado) en la parte superior derecha
3. Ingresa el token en el formato: `Bearer your_token_here`
4. Haz clic en "Authorize" y luego "Close"
5. Ahora puedes probar endpoints protegidos

## 📚 Anotaciones de Swagger

El controlador `AuthController` ya tiene ejemplos de anotaciones:

### A Nivel de Clase
```java
@Tag(name = "Autenticación", description = "Endpoints para autenticación y gestión de usuarios")
```

### A Nivel de Método
```java
@Operation(
    summary = "Iniciar sesión",
    description = "Autentica un usuario con sus credenciales"
)
@ApiResponses(value = {
    @ApiResponse(responseCode = "200", description = "Login exitoso"),
    @ApiResponse(responseCode = "401", description = "Credenciales inválidas")
})
```

### Para Parámetros
```java
@Parameter(description = "Nombre de usuario", required = true)
```

## 🎨 Características de Swagger UI

- ✅ Documentación interactiva de todos los endpoints
- ✅ Prueba de endpoints directamente desde el navegador
- ✅ Visualización de modelos de datos
- ✅ Ejemplos de request/response
- ✅ Soporte para autenticación JWT
- ✅ Exportación de especificación OpenAPI
- ✅ Organización por tags/categorías

## 🔄 Siguiente Paso: Documentar Otros Controladores

Para documentar los demás controladores, agrega las anotaciones de Swagger:

```java
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import io.swagger.v3.oas.annotations.responses.ApiResponse;

@RestController
@RequestMapping("/productos")
@Tag(name = "Productos", description = "Gestión de productos")
public class ProductoController {
    
    @Operation(summary = "Obtener todos los productos")
    @ApiResponse(responseCode = "200", description = "Lista de productos obtenida")
    @GetMapping
    public ResponseEntity<?> getAllProducts() {
        // ...
    }
}
```

## 🛠️ Compilar y Ejecutar

```bash
# Compilar el proyecto
mvn clean install

# Ejecutar la aplicación
mvn spring-boot:run

# O ejecutar el JAR generado
java -jar target/lytiks-backend-0.0.1-SNAPSHOT.jar
```

## 📖 Recursos Adicionales

- [SpringDoc OpenAPI Documentation](https://springdoc.org/)
- [OpenAPI Specification](https://swagger.io/specification/)
- [Swagger UI](https://swagger.io/tools/swagger-ui/)

## 🎯 Ventajas de Usar Swagger

1. **Documentación Automática**: Se genera automáticamente a partir del código
2. **Siempre Actualizada**: La documentación se actualiza con los cambios en el código
3. **Testing Integrado**: Prueba endpoints sin necesidad de herramientas externas
4. **Colaboración**: Facilita la comunicación entre frontend y backend
5. **Estándares**: Utiliza OpenAPI, un estándar de la industria

---

**Autor**: Lytiks Team  
**Última Actualización**: 10 de enero de 2026
