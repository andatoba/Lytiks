# GUÍA DE VERIFICACIÓN DE CÁLCULOS - SIGATOKA
## Sistema Lytiks - Control de Sigatoka Negra

---

## 📊 ESTRUCTURA DE CÁLCULOS

### PASO 1: Datos de Entrada (Por Muestra)

Cada muestra ingresada contiene:
- **Grados de infección**: Formato "Na" (ej: 2a, 3c)
  - N = Número de lesiones
  - a = Letra que indica el estadio
- **Total de hojas** por nivel (3era, 4ta, 5ta hoja)
- **Variables Stover** (0 y 10 semanas)

### PASO 2: Cálculo de Promedios Básicos (a-e)

**Archivo**: `backend_new/src/main/java/com/lytiks/backend/service/SigatokaCalculationService.java`

**Método**: `calcularPromediosBasicos()`

**Fórmulas**:
```java
a = Σ(hojas_emitidas) / total_muestras
b = Σ(hojas_erectas) / total_muestras
c = Σ(hojas_con_sintomas) / total_muestras
d = Σ(hoja_mas_joven_enferma) / total_muestras
e = Σ(hoja_mas_joven_necrosada) / total_muestras
```

### PASO 3: Cálculo de Indicadores (f-k)

**Método**: `calcularIndicadores()`

**Fórmulas**:
```java
f = c / a              // Incidencia promedio
g = (d / b) × 100      // Severidad promedio
h = (b / a) × 100      // Índice de hojas erectas
i = ritmo_emision      // Ritmo de emisión (configurable)
j = i / a              // Velocidad de evolución
k = e / a              // Velocidad de necrosis
```

### PASO 4: Estado Evolutivo (EE)

**Método**: `calcularEstadoEvolutivo()`

**Fórmulas**:
```java
EE_3era_hoja = f × 120 × k
EE_4ta_hoja  = f × 100 × k
EE_5ta_hoja  = f × 80  × k
```

**Interpretación de Niveles**:
| Valor EE | Nivel | Acción |
|----------|-------|--------|
| < 300 | BAJO | Mantener prácticas preventivas |
| 300-500 | MODERADO | Monitoreo cercano |
| > 500 | ALTO | Intervención inmediata |

---

## 🔍 CÓMO VERIFICAR LOS CÁLCULOS

### 1. Preparar Datos de Prueba

Use los mismos datos del Excel compartido:
- Ingrese exactamente las mismas muestras
- Verifique que los grados de infección sean idénticos
- Confirme que los valores de hojas coincidan

### 2. Ejecutar Cálculos

```bash
# En el backend
POST /api/sigatoka/calcular/{evaluacionId}
```

### 3. Comparar Resultados

**Obtener reporte**:
```bash
GET /api/sigatoka/{evaluacionId}/reporte
```

Compare los valores obtenidos con el Excel en:
- Promedios básicos (a-e)
- Indicadores (f-k)
- Estado evolutivo (EE)

---

## 🛠️ CÓMO CORREGIR CÁLCULOS INCORRECTOS

### Ubicación del Servicio
**Archivo**: `backend_new/src/main/java/com/lytiks/backend/service/SigatokaCalculationService.java`

### Caso 1: Promedios incorrectos (a-e)

**Líneas 88-125** - Método `calcularPromediosBasicos()`

**Ejemplo de corrección**:
```java
// Si el promedio de hojas emitidas está mal
// ANTES:
BigDecimal a = BigDecimal.valueOf(sumaHojasEmitidas)
    .divide(BigDecimal.valueOf(totalMuestras), SCALE, ROUNDING);

// DESPUÉS (si necesita incluir solo muestras válidas):
int muestrasValidas = (int) muestras.stream()
    .filter(m -> m.getHojasEmitidas() != null && m.getHojasEmitidas() > 0)
    .count();
BigDecimal a = BigDecimal.valueOf(sumaHojasEmitidas)
    .divide(BigDecimal.valueOf(muestrasValidas), SCALE, ROUNDING);
```

### Caso 2: Indicadores incorrectos (f-k)

**Líneas 127-190** - Método `calcularIndicadores()`

**Ejemplo de corrección**:
```java
// Si la severidad promedio está mal
// ANTES:
BigDecimal g = b.compareTo(BigDecimal.ZERO) > 0 
    ? d.divide(b, SCALE, ROUNDING).multiply(BigDecimal.valueOf(100)) 
    : BigDecimal.ZERO;

// DESPUÉS (si la fórmula correcta es diferente):
BigDecimal g = a.compareTo(BigDecimal.ZERO) > 0 
    ? d.divide(a, SCALE, ROUNDING).multiply(BigDecimal.valueOf(100)) 
    : BigDecimal.ZERO;
```

### Caso 3: Estado evolutivo incorrecto (EE)

**Líneas 192-235** - Método `calcularEstadoEvolutivo()`

**Ejemplo de corrección**:
```java
// Si el factor multiplicador está mal
// ANTES:
BigDecimal ee3era = f.multiply(BigDecimal.valueOf(120)).multiply(k);

// DESPUÉS (si el factor correcto es 150):
BigDecimal ee3era = f.multiply(BigDecimal.valueOf(150)).multiply(k);
```

---

## 📋 CHECKLIST DE VERIFICACIÓN

### Para cada fila de cálculo:

- [ ] **Fila 1 (Promedios básicos)**:
  - [ ] Verificar que `a` (hojas emitidas) sea correcto
  - [ ] Verificar que `b` (hojas erectas) sea correcto
  - [ ] Verificar que `c` (hojas con síntomas) sea correcto
  - [ ] Verificar que `d` (hoja más joven enferma) sea correcto
  - [ ] Verificar que `e` (hoja más joven necrosada) sea correcto

- [ ] **Fila 2 (Indicadores f-h)**:
  - [ ] Verificar que `f = c/a` (incidencia)
  - [ ] Verificar que `g = (d/b)×100` (severidad)
  - [ ] Verificar que `h = (b/a)×100` (índice hojas erectas)

- [ ] **Fila 3 (Indicadores i-k)**:
  - [ ] Verificar que `i` sea el ritmo de emisión correcto
  - [ ] Verificar que `j = i/a` (velocidad evolución)
  - [ ] Verificar que `k = e/a` (velocidad necrosis)

- [ ] **Fila 4 (Estado Evolutivo)**:
  - [ ] Verificar que `EE_3era = f×120×k`
  - [ ] Verificar que `EE_4ta = f×100×k`
  - [ ] Verificar que `EE_5ta = f×80×k`

---

## 🧪 EJEMPLO PRÁCTICO DE CORRECCIÓN

### Problema Reportado
"Los cálculos de control de sigatoka están mal, la segunda, tercera y cuarta fila salen incorrectas"

### Paso 1: Identificar qué filas están mal

- **Segunda fila**: Indicadores f-h
- **Tercera fila**: Indicadores i-k
- **Cuarta fila**: Estado Evolutivo

### Paso 2: Revisar fórmulas en el código

**Para la segunda fila** (líneas 158-175):
```java
// Verificar estas líneas en SigatokaCalculationService.java
BigDecimal f = a.compareTo(BigDecimal.ZERO) > 0 
    ? c.divide(a, SCALE, ROUNDING) 
    : BigDecimal.ZERO;

BigDecimal g = b.compareTo(BigDecimal.ZERO) > 0 
    ? d.divide(b, SCALE, ROUNDING).multiply(BigDecimal.valueOf(100)) 
    : BigDecimal.ZERO;

BigDecimal h = a.compareTo(BigDecimal.ZERO) > 0 
    ? b.divide(a, SCALE, ROUNDING).multiply(BigDecimal.valueOf(100)) 
    : BigDecimal.ZERO;
```

### Paso 3: Comparar con Excel

1. Abrir el Excel de referencia
2. Ver las fórmulas exactas usadas
3. Ajustar el código Java para que coincida

### Paso 4: Ajustar y probar

```java
// Ejemplo de ajuste si la fórmula es diferente
// Si en Excel es: g = (c/a)×100 en lugar de (d/b)×100
BigDecimal g = a.compareTo(BigDecimal.ZERO) > 0 
    ? c.divide(a, SCALE, ROUNDING).multiply(BigDecimal.valueOf(100)) 
    : BigDecimal.ZERO;
```

### Paso 5: Recompilar y probar

```bash
cd backend_new
mvn clean install
mvn spring-boot:run
```

---

## 🔧 HERRAMIENTAS DE DEBUGGING

### Logs en el Servicio

El servicio ya incluye logs detallados:

```java
log.debug("Promedios básicos: a={}, b={}, c={}, d={}, e={}", a, b, c, d, e);
log.debug("Indicadores: f={}, g={}, h={}, i={}, j={}, k={}", f, g, h, i, j, k);
log.debug("Estado evolutivo: EE3era={}, EE4ta={}, EE5ta={}", ee3era, ee4ta, ee5ta);
```

Para ver estos logs, configurar el nivel de logging en `application.properties`:

```properties
logging.level.com.lytiks.backend.service.SigatokaCalculationService=DEBUG
```

### Endpoint de Prueba

Crear un endpoint temporal para debugging:

```java
@GetMapping("/debug/{evaluacionId}")
public ResponseEntity<Map<String, Object>> debugCalculos(@PathVariable Long evaluacionId) {
    // Retornar valores intermedios para comparar
    return ResponseEntity.ok(valoresIntermedios);
}
```

---

## 📞 PRÓXIMOS PASOS

1. **Ejecutar el sistema con los datos de prueba**
2. **Comparar resultados** con el Excel compartido
3. **Identificar específicamente** qué valores están incorrectos
4. **Ajustar las fórmulas** en `SigatokaCalculationService.java`
5. **Recompilar y probar** hasta que coincidan

---

## 💡 CONSEJOS

1. **Usar el mismo orden de operaciones** que el Excel
2. **Verificar el redondeo** - El código usa 2 decimales con HALF_UP
3. **Comprobar divisiones por cero** - El código ya las maneja
4. **Validar datos de entrada** - Asegurar que las muestras tengan todos los campos necesarios

---

**Nota**: Si después de revisar las fórmulas aún hay discrepancias, puede ser necesario compartir el Excel de referencia para hacer una comparación línea por línea de las fórmulas exactas.
