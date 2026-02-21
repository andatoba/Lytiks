# 📊 RESUMEN COMPLETO: SISTEMA DE CÁLCULO SIGATOKA

## ============================================
## 1. FÓRMULAS Y CÁLCULOS
## ============================================

### **SECCIÓN 1: Conteo de Literales (a-j)**
```
📌 OBJETIVO: Contar cuántas veces aparece cada estadio de la enfermedad

ENTRADA:
- hoja_3era: '1a', '2b', '3c', etc.
- hoja_4ta: '1d', '2e', '3f', etc.
- hoja_5ta: '2g', '3h', '1i', etc.

PROCESO:
- Extraer última letra: '2a' → 'a', '3b' → 'b'
- Contar por tipo de hoja

SALIDA:
3era Hoja: a=4, b=4, c=2, d=0, e=0, f=0, g=0, h=0, i=0, j=0
4ta Hoja:  a=3, b=5, c=2, d=0, e=0, f=0, g=0, h=0, i=0, j=0
5ta Hoja:  a=2, b=4, c=3, d=1, e=0, f=0, g=0, h=0, i=0, j=0
```

**Código:**
```dart
// Extrae literal de '2a' → 'a'
final literal = valorHoja[valorHoja.length - 1].toLowerCase();
conteo[literal]++;
```

---

### **SECCIÓN 2: Tabla de Muestras**
```
📌 OBJETIVO: Listar todas las muestras capturadas

DATOS POR MUESTRA:
- Número de muestra
- Lote
- Grados de infección (3era, 4ta, 5ta hoja)
- Total hojas funcionales
- Plantas con lesiones
- Total lesiones
- Plantas en 3er estadio
- Total letras (severidad)
- Variables Stover (opcional)

NOTA: Esta es la tabla raw, no necesita cálculos
```

---

### **SECCIÓN 3: Promedios Básicos (a-e)**

#### **a) Promedio Total Plantas Muestreadas**
```
FÓRMULA: a = SUMA(plantas_muestreadas) / total_muestras

EJEMPLO:
Muestra 1: 10 plantas
Muestra 2: 10 plantas
Muestra 3: 10 plantas
Total muestras: 3

a = (10 + 10 + 10) / 3 = 10.00
```

#### **b) Promedio Plantas con Lesiones**
```
FÓRMULA: b = SUMA(plantas_con_lesiones) / total_muestras

EJEMPLO:
Muestra 1: 10 plantas con lesiones
Muestra 2: 12 plantas
Muestra 3: 8 plantas
Total: 3 muestras

b = (10 + 12 + 8) / 3 = 10.00
```

#### **c) Promedio Total Lesiones**
```
FÓRMULA: c = SUMA(total_lesiones) / total_muestras

EJEMPLO:
Muestra 1: 25 lesiones
Muestra 2: 30 lesiones
Muestra 3: 20 lesiones

c = (25 + 30 + 20) / 3 = 25.00
```

#### **d) Promedio Plantas con 3er Estadio**
```
FÓRMULA: d = SUMA(plantas_3er_estadio) / total_muestras

EJEMPLO:
Muestra 1: 5 plantas
Muestra 2: 6 plantas
Muestra 3: 4 plantas

d = (5 + 6 + 4) / 3 = 5.00
```

#### **e) Promedio Total Letras**
```
FÓRMULA: e = SUMA(total_letras) / total_muestras

EJEMPLO:
Muestra 1: 15 letras
Muestra 2: 18 letras
Muestra 3: 12 letras

e = (15 + 18 + 12) / 3 = 15.00
```

---

### **SECCIÓN 4: Indicadores Calculados (f-k)**

#### **f) Promedio de Lesiones por Planta**
```
FÓRMULA: f = c / a

EJEMPLO:
c = 25.00 (promedio total lesiones)
a = 10.00 (promedio plantas muestreadas)

f = 25.00 / 10.00 = 2.50 lesiones/planta
```

#### **g) % Plantas con 3eros Estadios**
```
FÓRMULA: g = (d / b) × 100

EJEMPLO:
d = 5.00 (plantas con 3er estadio)
b = 10.00 (plantas con lesiones)

g = (5.00 / 10.00) × 100 = 50.00%
```

#### **h) % Plantas con Lesiones**
```
FÓRMULA: h = (b / a) × 100

EJEMPLO:
b = 10.00 (plantas con lesiones)
a = 10.00 (plantas muestreadas)

h = (10.00 / 10.00) × 100 = 100.00%
```

#### **i) Total Hojas Funcionales**
```
FÓRMULA: i = PROMEDIO(hojas_3era + hojas_4ta + hojas_5ta)

EJEMPLO:
Muestra 1: 8 + 7 + 6 = 21 hojas
Muestra 2: 9 + 8 + 7 = 24 hojas
Muestra 3: 7 + 6 + 5 = 18 hojas

i = (21 + 24 + 18) / 3 = 21.00 hojas
```

#### **j) Promedio Hojas Funcionales × Plantas**
```
FÓRMULA: j = i / a

EJEMPLO:
i = 21.00 (hojas funcionales)
a = 10.00 (plantas muestreadas)

j = 21.00 / 10.00 = 2.10 hojas/planta
```

#### **k) Promedio de las Letras**
```
FÓRMULA: k = e / a

EJEMPLO:
e = 15.00 (total letras)
a = 10.00 (plantas muestreadas)

k = 15.00 / 10.00 = 1.50 letras/planta
```

---

### **SECCIÓN 5: Estado Evolutivo (EE)**

#### **EE 3era Hoja**
```
FÓRMULA: EE_3era = f × 120 × k

EJEMPLO:
f = 2.50 (lesiones/planta)
k = 1.50 (letras/planta)

EE_3era = 2.50 × 120 × 1.50 = 450.00
```

#### **EE 4ta Hoja**
```
FÓRMULA: EE_4ta = f × 100 × k

EJEMPLO:
f = 2.50
k = 1.50

EE_4ta = 2.50 × 100 × 1.50 = 375.00
```

#### **EE 5ta Hoja**
```
FÓRMULA: EE_5ta = f × 80 × k

EJEMPLO:
f = 2.50
k = 1.50

EE_5ta = 2.50 × 80 × 1.50 = 300.00
```

#### **Nivel de Infección**
```
FÓRMULA: EE_promedio = (EE_3era + EE_4ta + EE_5ta) / 3

CLASIFICACIÓN:
EE < 500       → BAJO
EE < 1000      → MODERADO
EE < 2000      → ALTO
EE >= 2000     → CRÍTICO

EJEMPLO:
EE_promedio = (450 + 375 + 300) / 3 = 375.00
Nivel = BAJO ✅
```

---

### **SECCIÓN 6: Promedios Stover (Opcional)**
```
📌 OBJETIVO: Calcular promedios de variables avanzadas

VARIABLES SEMANA 0:
- H.V.L.E. 0w (Hojas Verdes Libres de Enfermedad)
- H.V.L.Q. 0w (Hojas Verdes con Lesiones Quemantes)
- H.V.L.Q5 0w (Hojas con menos de 5% de lesiones)
- T.H. 0w (Total Hojas)

VARIABLES SEMANA 10:
- H.V.L.E. 10w
- H.V.L.Q. 10w
- H.V.L.Q5 10w
- T.H. 10w

FÓRMULA: Promedio simple
promedio_hvle_0w = SUMA(hvle_0w) / total_muestras_con_datos
```

---

## ============================================
## 2. ESQUEMA DE BASE DE DATOS NECESARIO
## ============================================

### **TABLAS MÍNIMAS REQUERIDAS:**

```sql
-- ============================================
-- TABLA 1: sigatoka_evaluacion (Encabezado)
-- ============================================
CREATE TABLE sigatoka_evaluacion (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    cliente_id BIGINT NOT NULL,
    hacienda VARCHAR(255) NOT NULL,
    fecha DATE NOT NULL,
    semana_epidemiologica INT NOT NULL,
    periodo VARCHAR(100) NOT NULL,
    evaluador VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (cliente_id) REFERENCES clientes(id)
);

-- ============================================
-- TABLA 2: sigatoka_lote
-- ============================================
CREATE TABLE sigatoka_lote (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    evaluacion_id BIGINT NOT NULL,
    lote_codigo VARCHAR(100) NOT NULL,
    latitud DECIMAL(10,6),
    longitud DECIMAL(10,6),
    FOREIGN KEY (evaluacion_id) REFERENCES sigatoka_evaluacion(id)
);

-- ============================================
-- TABLA 3: sigatoka_muestra (Datos RAW)
-- ============================================
CREATE TABLE sigatoka_muestra (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    lote_id BIGINT NOT NULL,
    muestra_num INT NOT NULL,
    
    -- Grados de infección (contienen literales a-j)
    hoja_3era VARCHAR(10),  -- '1a', '2b', '3c'
    hoja_4ta VARCHAR(10),
    hoja_5ta VARCHAR(10),
    
    -- Total hojas
    total_hojas_3era INT,
    total_hojas_4ta INT,
    total_hojas_5ta INT,
    
    -- Variables básicas (b-e)
    plantas_con_lesiones INT NOT NULL,
    total_lesiones INT NOT NULL,
    plantas_3er_estadio INT NOT NULL,
    total_letras INT NOT NULL,
    
    -- Variables Stover (opcional)
    h_v_l_e_0w DECIMAL(5,2),
    h_v_l_q_0w DECIMAL(5,2),
    h_v_l_q5_0w DECIMAL(5,2),
    t_h_0w DECIMAL(5,2),
    h_v_l_e_10w DECIMAL(5,2),
    h_v_l_q_10w DECIMAL(5,2),
    h_v_l_q5_10w DECIMAL(5,2),
    t_h_10w DECIMAL(5,2),
    
    FOREIGN KEY (lote_id) REFERENCES sigatoka_lote(id)
);

-- ============================================
-- TABLA 4: sigatoka_resumen (Promedios a-e)
-- ============================================
CREATE TABLE sigatoka_resumen (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    evaluacion_id BIGINT NOT NULL UNIQUE,
    promedio_plantas_muestreadas DECIMAL(10,2), -- a
    promedio_plantas_lesiones DECIMAL(10,2),    -- b
    promedio_total_lesiones DECIMAL(10,2),      -- c
    promedio_plantas_3er DECIMAL(10,2),         -- d
    promedio_total_letras DECIMAL(10,2),        -- e
    FOREIGN KEY (evaluacion_id) REFERENCES sigatoka_evaluacion(id)
);

-- ============================================
-- TABLA 5: sigatoka_indicadores (Cálculos f-k)
-- ============================================
CREATE TABLE sigatoka_indicadores (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    evaluacion_id BIGINT NOT NULL UNIQUE,
    promedio_lesiones_planta DECIMAL(10,2),    -- f
    porcentaje_plantas_3er DECIMAL(10,2),      -- g
    porcentaje_plantas_lesiones DECIMAL(10,2), -- h
    total_hojas_funcionales DECIMAL(10,2),     -- i
    promedio_hojas_funcionales DECIMAL(10,2),  -- j
    promedio_letras DECIMAL(10,2),             -- k
    FOREIGN KEY (evaluacion_id) REFERENCES sigatoka_evaluacion(id)
);

-- ============================================
-- TABLA 6: sigatoka_estado_evolutivo (EE)
-- ============================================
CREATE TABLE sigatoka_estado_evolutivo (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    evaluacion_id BIGINT NOT NULL UNIQUE,
    ee_3era_hoja DECIMAL(10,2),
    ee_4ta_hoja DECIMAL(10,2),
    ee_5ta_hoja DECIMAL(10,2),
    nivel_infeccion VARCHAR(20),  -- BAJO, MODERADO, ALTO, CRÍTICO
    FOREIGN KEY (evaluacion_id) REFERENCES sigatoka_evaluacion(id)
);

-- ============================================
-- TABLA 7: sigatoka_conteo_literales (a-j)
-- ============================================
CREATE TABLE sigatoka_conteo_literales (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    evaluacion_id BIGINT NOT NULL UNIQUE,
    
    -- Conteos 3era Hoja
    literal_a_3era INT DEFAULT 0,
    literal_b_3era INT DEFAULT 0,
    literal_c_3era INT DEFAULT 0,
    literal_d_3era INT DEFAULT 0,
    literal_e_3era INT DEFAULT 0,
    literal_f_3era INT DEFAULT 0,
    literal_g_3era INT DEFAULT 0,
    literal_h_3era INT DEFAULT 0,
    literal_i_3era INT DEFAULT 0,
    literal_j_3era INT DEFAULT 0,
    
    -- Conteos 4ta Hoja (igual estructura)
    literal_a_4ta INT DEFAULT 0,
    -- ... etc
    
    -- Conteos 5ta Hoja (igual estructura)
    literal_a_5ta INT DEFAULT 0,
    -- ... etc
    
    FOREIGN KEY (evaluacion_id) REFERENCES sigatoka_evaluacion(id)
);
```

---

## ============================================
## 3. FLUJO DE IMPLEMENTACIÓN (OPCIÓN 1)
## ============================================

### **FASE 1: Usuario Captura Datos (Flutter)**
```dart
// Estado local en memoria
List<Muestra> muestrasLocales = [];

void agregarMuestra() {
  // Agregar a lista local (NO guardar en BD todavía)
  muestrasLocales.add(Muestra(
    lote: _loteController.text,
    numeroMuestra: muestrasLocales.length + 1,
    hoja3era: '2a',  // ← Aquí están los literales
    hoja4ta: '3b',
    hoja5ta: '1c',
    totalHojas3era: 8,
    totalHojas4ta: 7,
    totalHojas5ta: 6,
    plantasConLesiones: 10,
    totalLesiones: 25,
    plantas3erEstadio: 5,
    totalLetras: 15,
  ));
  
  setState(() {}); // Actualizar UI
  
  // Mostrar preview en tiempo real
  _mostrarPreview();
}
```

### **FASE 2: Calcular en Tiempo Real (Preview)**
```dart
void _mostrarPreview() {
  // Calcular SIN guardar
  final resultado = SigatokaCalculoLocal.calcularTodo(muestrasLocales);
  
  // Mostrar en UI
  print('Literales 3era: ${resultado.conteo3eraHoja}');
  print('Promedio lesiones: ${resultado.promedioTotalLesiones}');
  print('Estado Evolutivo: ${resultado.nivelInfeccion}');
}
```

### **FASE 3: Guardar Todo al Presionar "Guardar Resumen"**
```dart
Future<void> guardarEvaluacionCompleta() async {
  // 1. Calcular resultado final
  final resultado = SigatokaCalculoLocal.calcularTodo(muestrasLocales);
  
  // 2. Crear el payload para el backend
  final payload = {
    'evaluacion': {
      'clienteId': _clienteId,
      'hacienda': _haciendaController.text,
      'fecha': _fechaController.text,
      'evaluador': _evaluadorController.text,
    },
    'muestras': muestrasLocales.map((m) => {
      'lote': m.lote,
      'numeroMuestra': m.numeroMuestra,
      'hoja3era': m.hoja3era,
      'hoja4ta': m.hoja4ta,
      'hoja5ta': m.hoja5ta,
      'plantasConLesiones': m.plantasConLesiones,
      'totalLesiones': m.totalLesiones,
      'plantas3erEstadio': m.plantas3erEstadio,
      'totalLetras': m.totalLetras,
    }).toList(),
    'resumen': {
      'promedioPlantasMuestreadas': resultado.promedioPlantasMuestreadas,
      'promedioPlantasLesiones': resultado.promedioPlantasConLesiones,
      'promedioTotalLesiones': resultado.promedioTotalLesiones,
      'promedioPlantas3er': resultado.promedioPlantas3erEstadio,
      'promedioTotalLetras': resultado.promedioTotalLetras,
    },
    'indicadores': {
      'promedioLesionesPlanta': resultado.promedioLesionesPorPlanta,
      'porcentajePlantas3er': resultado.porcentajePlantas3erEstadio,
      'porcentajePlantasLesiones': resultado.porcentajePlantasConLesiones,
      'totalHojasFuncionales': resultado.totalHojasFuncionales,
      'promedioHojasFuncionales': resultado.promedioHojasFuncionalesPorPlanta,
      'promedioLetras': resultado.promedioLetras,
    },
    'estadoEvolutivo': {
      'ee3eraHoja': resultado.estadoEvolutivo3era,
      'ee4taHoja': resultado.estadoEvolutivo4ta,
      'ee5taHoja': resultado.estadoEvolutivo5ta,
      'nivelInfeccion': resultado.nivelInfeccion,
    },
    'conteoLiterales': {
      '3eraHoja': resultado.conteo3eraHoja,
      '4taHoja': resultado.conteo4taHoja,
      '5taHoja': resultado.conteo5taHoja,
    },
  };
  
  // 3. Enviar TODO al backend (una sola petición)
  final response = await http.post(
    Uri.parse('$baseUrl/sigatoka/guardar-completo'),
    body: jsonEncode(payload),
  );
  
  if (response.statusCode == 200) {
    print('✅ Evaluación guardada exitosamente');
    // Limpiar memoria local
    muestrasLocales.clear();
  }
}
```

### **FASE 4: Backend Recibe y Guarda (Java)**
```java
@PostMapping("/guardar-completo")
public ResponseEntity<?> guardarEvaluacionCompleta(@RequestBody PayloadCompleto payload) {
    // 1. Guardar evaluación
    SigatokaEvaluacion evaluacion = new SigatokaEvaluacion();
    evaluacion.setClienteId(payload.getEvaluacion().getClienteId());
    // ... configurar campos
    evaluacion = evaluacionRepository.save(evaluacion);
    
    // 2. Guardar lotes y muestras
    for (MuestraDTO muestraDTO : payload.getMuestras()) {
        // Crear/buscar lote
        SigatokaLote lote = loteRepository.findByEvaluacionIdAndCodigo(...)
            .orElseGet(() -> {
                SigatokaLote nuevo = new SigatokaLote();
                nuevo.setLoteCodigo(muestraDTO.getLote());
                return loteRepository.save(nuevo);
            });
        
        // Guardar muestra
        SigatokaMuestraCompleta muestra = new SigatokaMuestraCompleta();
        muestra.setLote(lote);
        muestra.setHoja3era(muestraDTO.getHoja3era());  // ← aquí los literales
        muestra.setPlantasConLesiones(muestraDTO.getPlantasConLesiones());
        // ... etc
        muestraRepository.save(muestra);
    }
    
    // 3. Guardar resumen (ya calculado por Flutter)
    SigatokaResumen resumen = new SigatokaResumen();
    resumen.setEvaluacion(evaluacion);
    resumen.setPromedioPlantasMuestreadas(payload.getResumen().getPromedioPlantasMuestreadas());
    // ... etc
    resumenRepository.save(resumen);
    
    // 4. Guardar indicadores
    SigatokaIndicadores indicadores = new SigatokaIndicadores();
    // ... etc
    indicadoresRepository.save(indicadores);
    
    // 5. Guardar estado evolutivo
    SigatokaEstadoEvolutivo estado = new SigatokaEstadoEvolutivo();
    // ... etc
    estadoEvolutivoRepository.save(estado);
    
    // 6. Guardar conteos de literales
    SigatokaConteoLiterales conteo = new SigatokaConteoLiterales();
    conteo.setEvaluacion(evaluacion);
    conteo.setLiteralA3era(payload.getConteoLiterales().get("3eraHoja").get("a"));
    conteo.setLiteralB3era(payload.getConteoLiterales().get("3eraHoja").get("b"));
    // ... etc
    conteoLiteralesRepository.save(conteo);
    
    return ResponseEntity.ok(evaluacion);
}
```

---

## ============================================
## 4. VENTAJAS DE ESTA ARQUITECTURA
## ============================================

✅ **Feedback inmediato** - Usuario ve resultados en tiempo real
✅ **Menos peticiones** - Una sola petición POST al final
✅ **Validación temprana** - Frontend puede validar antes de enviar
✅ **Experiencia offline** - Puede trabajar sin conexión (guardar al final)
✅ **Backup automático** - Backend recibe TODO de una vez (transaccional)

---

## ============================================
## 5. DATOS DE PRUEBA
## ============================================

```dart
// Ejemplo de muestras para probar
final muestrasPrueba = [
  Muestra(
    lote: 'LOTE-001',
    numeroMuestra: 1,
    hoja3era: '1a', // ← literal 'a'
    hoja4ta: '2b',  // ← literal 'b'
    hoja5ta: '3a',  // ← literal 'a'
    totalHojas3era: 8,
    totalHojas4ta: 7,
    totalHojas5ta: 6,
    plantasConLesiones: 10,
    totalLesiones: 25,
    plantas3erEstadio: 5,
    totalLetras: 15,
  ),
  // ... agregar 4 muestras más
];

// Calcular
final resultado = SigatokaCalculoLocal.calcularTodo(muestrasPrueba);

// Resultado esperado:
// conteo3eraHoja: {a: 4, b: 1, c: 0, ...}
// promedioTotalLesiones: 25.00
// nivelInfeccion: "BAJO"
```

---

## ============================================
## RESUMEN FINAL
## ============================================

**OPCIÓN 1 = Frontend calcula TODO**
- Usuario agrega muestras → memoria local
- Frontend calcula en tiempo real
- Usuario ve preview inmediato
- Al presionar "Guardar" → envía TODO al backend
- Backend solo guarda (no calcula)

**TABLAS NECESARIAS:**
1. sigatoka_evaluacion (encabezado)
2. sigatoka_lote (identificación de lotes)
3. sigatoka_muestra (datos RAW con literales)
4. sigatoka_resumen (promedios a-e calculados)
5. sigatoka_indicadores (indicadores f-k calculados)
6. sigatoka_estado_evolutivo (EE calculado)
7. sigatoka_conteo_literales (conteo a-j calculado)

**ARCHIVOS MODIFICADOS:**
- ✅ `lib/screens/resumen_sigatoka_screen.dart` - Cálculos implementados
- ✅ `lib/services/sigatoka_evaluacion_service.dart` - Guardado sin recalcular
