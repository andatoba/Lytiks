# Sistema de Evaluación de Sigatoka - Documentación de Fórmulas

## 📋 Estructura del Sistema

El sistema implementa el formato completo de evaluación de Sigatoka con cálculos automáticos en el backend.

### 1. CAMPOS DE ENTRADA (Ingresados por el Usuario)

#### Encabezado
- **Hacienda**: Nombre de la finca
- **Fecha de muestreo**: Día/mes/año
- **Semana epidemiológica**: Número de semana
- **Período**: Ciclo de evaluación
- **Evaluador**: Nombre del técnico

#### Por cada Muestra
- **Muestra #**: Identificador (1, 2, 3, 4...)
- **Lote #**: Código del lote
- **Grado 3era hoja**: Formato "Na" donde N=número de lesiones, a=letra (ej: "2a", "3c")
- **Grado 4ta hoja**: Igual formato
- **Grado 5ta hoja**: Igual formato
- **Total hojas**: Número total de hojas observadas

#### Variables Stover (por muestra)
**Semana 0:**
- H.V.L.E. (Hoja Verde más Lesionada Erupción)
- H.V.L.Q. (Hoja Verde más Lesionada Quemadura)
- H.V.L.Q.5% (Hoja Verde más Lesionada con 5% Quemadura)
- T.H. (Total de Hojas)

**Semana 10:** (Mismas variables)

---

## 🧮 CÁLCULOS AUTOMÁTICOS

### PASO 1: Procesamiento por Muestra

Para cada muestra y cada hoja (3era, 4ta, 5ta):

```
a) Plantas muestreadas = 1 si total_hojas > 0, sino 0
b) Plantas con lesiones = 1 si el grado tiene número > 0
c) Total lesiones = número extraído del grado (ej: "3c" → 3)
d) Plantas con 3er estadio = 1 si la letra es 'c' o superior
e) Total letras = valor numérico de la letra (a=1, b=2, c=3, ...)
```

### PASO 2: Resumen General (Totales)

Por cada hoja (3era, 4ta, 5ta), se suman todos los valores de las muestras:

```
Total plantas = Σ(a)
Total plantas con lesiones = Σ(b)
Total lesiones = Σ(c)
Total plantas 3er estadio = Σ(d)
Total de letras = Σ(e)
Total hojas funcionales = Σ(total_hojas_general)
```

### PASO 3: Indicadores Calculados (f-k)

Por cada hoja:

```
f) Promedio lesiones por planta = c / a
g) % plantas con 3er estadio = (d / b) × 100
h) % plantas con lesiones = (b / a) × 100
i) Total hojas funcionales = total_hojas_funcionales
j) Promedio hojas útiles por planta = i / a
k) Promedio de letras = e / a
```

### PASO 4: Estado Evolutivo (EE)

Fórmulas específicas por hoja:

```
3era Hoja: EE = f × 120 × k
4ta Hoja:  EE = f × 100 × k
5ta Hoja:  EE = f × 80 × k
```

#### Interpretación de Niveles:

| Valor EE | Nivel | Color | Acción |
|----------|-------|-------|--------|
| < 300 | BAJO | 🟢 Verde | Mantener prácticas preventivas |
| 300-500 | MODERADO | 🟠 Naranja | Monitoreo cercano y tratamiento preventivo |
| > 500 | ALTO | 🔴 Rojo | Intervención inmediata con fungicidas |

### PASO 5: Promedios Stover Reales

Se calculan los promedios de todas las muestras:

```
Semana 0:
  Promedio H.V.L.E. = Σ(hvle_semana_0) / cantidad_muestras
  Promedio H.V.L.Q. = Σ(hvlq_semana_0) / cantidad_muestras
  Promedio H.V.L.Q.5% = Σ(hvlq5_semana_0) / cantidad_muestras
  Promedio T.H. = Σ(th_semana_0) / cantidad_muestras

Semana 10: (Mismas fórmulas con datos de semana 10)
```

#### Niveles Stover Recomendados (Referencia)

| Planta | H.V.L.E. | H.V.L.Q. | H.V.L.Q.5% | T.H. |
|--------|----------|----------|------------|------|
| "0" Semana | 6.0 | 11.0 | 12.5 | 13.5 |
| "10" Semana | 0.0 | 5.0 | 8.5 | 9.0 |

---

## 🔄 FLUJO DE TRABAJO

1. **Usuario ingresa encabezado** → Se crea evaluación en BD
2. **Usuario agrega muestras** → Por cada muestra:
   - Se guardan los datos de entrada
   - Se procesan cálculos individuales (a-e)
   - Se actualizan totales (resumen)
   - Se recalculan indicadores (f-k)
   - Se recalcula estado evolutivo (EE)
   - Se actualizan promedios Stover
3. **Sistema genera reporte completo** → Frontend muestra las 5 secciones

---

## 📊 EJEMPLO PRÁCTICO

### Entrada:
```
Muestra 1: Lote A, 3era hoja = "2a", 4ta hoja = "3c", 5ta hoja = "1b", Total hojas = 12
Muestra 2: Lote B, 3era hoja = "1a", 4ta hoja = "2b", 5ta hoja = "0", Total hojas = 14
```

### Procesamiento Muestra 1 - 3era Hoja:
```
a = 1 (hay hojas)
b = 1 (hay lesiones porque "2a" tiene número > 0)
c = 2 (número extraído de "2a")
d = 0 (letra 'a' no es 3er estadio)
e = 1 (letra 'a' = 1)
```

### Procesamiento Muestra 1 - 4ta Hoja:
```
a = 1
b = 1
c = 3 (número extraído de "3c")
d = 1 (letra 'c' ES 3er estadio)
e = 3 (letra 'c' = 3)
```

### Después de procesar ambas muestras - Resumen 3era Hoja:
```
Total plantas (a) = 2
Total plantas con lesiones (b) = 2
Total lesiones (c) = 3 (2+1)
Total plantas 3er estadio (d) = 0
Total letras (e) = 2 (1+1)
```

### Indicadores 3era Hoja:
```
f = 3/2 = 1.5
g = (0/2) × 100 = 0%
h = (2/2) × 100 = 100%
i = 26 (12+14)
j = 26/2 = 13
k = 2/2 = 1.0
```

### Estado Evolutivo 3era Hoja:
```
EE = 1.5 × 120 × 1.0 = 180
Nivel = BAJO (< 300) 🟢
```

---

## 🗄️ TABLAS DE BASE DE DATOS

1. **sigatoka_evaluacion**: Datos de encabezado
2. **sigatoka_muestra**: Datos de cada muestra individual
3. **sigatoka_resumen**: Totales calculados (a-e)
4. **sigatoka_indicadores**: Indicadores calculados (f-k)
5. **sigatoka_estado_evolutivo**: Estado evolutivo y niveles
6. **sigatoka_stover_promedio**: Promedios Stover reales

---

## 🔧 ENDPOINTS DEL API

### POST /api/sigatoka/crear-evaluacion
Crea una nueva evaluación con datos de encabezado.

**Request:**
```json
{
  "clienteId": 1,
  "hacienda": "Finca Las Palmas",
  "fecha": "2025-12-17",
  "semana": "50",
  "periodo": "04",
  "evaluador": "Juan Pérez"
}
```

**Response:**
```json
{
  "success": true,
  "evaluacionId": 123,
  "mensaje": "Evaluación creada exitosamente"
}
```

### POST /api/sigatoka/agregar-muestra/{evaluacionId}
Agrega una muestra y recalcula automáticamente todos los indicadores.

**Request:**
```json
{
  "numero": 1,
  "lote": "A-001",
  "grado3era": "2a",
  "grado4ta": "3c",
  "grado5ta": "1b",
  "totalHojas": 12,
  "totalHojas3era": 4,
  "totalHojas4ta": 4,
  "totalHojas5ta": 4,
  "hvleSemana0": 7.5,
  "hvlqSemana0": 12.0,
  "hvlq5Semana0": 13.0,
  "thSemana0": 14.0,
  "hvleSemana10": 1.0,
  "hvlqSemana10": 6.0,
  "hvlq5Semana10": 9.0,
  "thSemana10": 10.0
}
```

### GET /api/sigatoka/reporte?evaluacionId={id}
Obtiene el reporte completo con todas las secciones calculadas.

**Response:**
```json
{
  "evaluacion": { ... },
  "muestras": [ ... ],
  "resumen": {
    "totalPlantas": 10,
    "totalPlantasLesiones": 8,
    "totalLesiones": 25,
    "totalPlantas3erEstadio": 3,
    "totalLetras": 15
  },
  "indicadores": {
    "f": 2.5,
    "g": 37.5,
    "h": 80.0,
    "i": 120,
    "j": 12.0,
    "k": 1.5
  },
  "interpretacion": {
    "estadoEvolutivo": "...",
    "nivel": "MODERADO",
    "ee3era": 450.0,
    "ee4ta": 375.0,
    "ee5ta": 300.0
  },
  "stoverReal": {
    "hvleSemana0": 7.2,
    "hvlqSemana0": 11.8,
    ...
  }
}
```

---

## ✅ VALIDACIONES

El sistema valida automáticamente:
- División por cero en todas las fórmulas
- Formato correcto de grados (letra + número)
- Existencia de evaluación antes de agregar muestras
- Datos numéricos válidos

Todos los cálculos usan **BigDecimal** con 2 decimales para precisión.
