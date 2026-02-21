# 🔍 ARQUITECTURA ACTUAL DE SIGATOKA

## ============================================
## 1. FLUJO ACTUAL (CÓMO FUNCIONA AHORA)
## ============================================

```
┌─────────────────────────────────────────────────────────────┐
│  USUARIO EN LA APP (Flutter)                                │
└─────────────────────────────────────────────────────────────┘
                          │
                          │ 1. Agrega muestras una por una
                          ▼
┌─────────────────────────────────────────────────────────────┐
│  sigatoka_evaluacion_form_screen.dart                       │
│  - Captura: hoja3era='2a', hoja4ta='3b', etc.              │
│  - Por cada muestra: POST /lotes/{id}/muestras             │
│  - Guarda INMEDIATAMENTE en BD                              │
└─────────────────────────────────────────────────────────────┘
                          │
                          │ HTTP POST (una petición por muestra)
                          ▼
┌─────────────────────────────────────────────────────────────┐
│  BACKEND (Spring Boot)                                       │
│  SigatokaEvaluacionController.java                          │
│  - Recibe muestra                                            │
│  - Guarda en tabla: sigatoka_muestra_completa               │
│  - NO calcula nada todavía                                   │
└─────────────────────────────────────────────────────────────┘
                          │
                          │ INSERT INTO
                          ▼
┌─────────────────────────────────────────────────────────────┐
│  BASE DE DATOS MySQL (lytiks_db)                            │
│                                                               │
│  ✅ sigatoka_evaluacion (encabezado)                        │
│  ✅ sigatoka_lote (agrupación)                              │
│  ✅ sigatoka_muestra_completa (datos RAW)                   │
│     - hoja_3era = '2a'                                       │
│     - plantas_con_lesiones = 10                              │
│     - total_lesiones = 25                                    │
│     - etc.                                                   │
│                                                               │
│  ❌ sigatoka_resumen (VACÍA - no se llena automática)      │
│  ❌ sigatoka_indicadores (VACÍA)                           │
│  ❌ sigatoka_estado_evolutivo (VACÍA)                      │
│  ❌ sigatoka_stover_promedio (VACÍA)                       │
│  ❌ sigatoka_conteo_literales (NO EXISTE EN BD)            │
└─────────────────────────────────────────────────────────────┘
                          │
                          │ 2. Usuario termina de agregar muestras
                          │ 3. Click en "Ver Resumen"
                          ▼
┌─────────────────────────────────────────────────────────────┐
│  resumen_sigatoka_screen.dart                                │
│  - Recibe: muestrasSesion (List<Map> - en memoria)         │
│  - NO consulta BD                                            │
│  - Calcula TODO en memoria (a-k, EE, Stover)                │
│  - Muestra tablas                                            │
│  - ❌ NO cuenta literales (a-j)                             │
└─────────────────────────────────────────────────────────────┘
                          │
                          │ 4. Usuario click en "Guardar Resumen" (icono save)
                          ▼
┌─────────────────────────────────────────────────────────────┐
│  _guardarResumen() en resumen_sigatoka_screen.dart          │
│  - Llama: guardarResumenCompleto(evaluacionId, ...)        │
│  - Envía 3 payloads separados:                              │
│    1) resumenData (totales por hoja)                        │
│    2) indicadoresData (solo ee3era, ee4ta, ee5ta)          │
│    3) stoverData (8 promedios)                              │
└─────────────────────────────────────────────────────────────┘
                          │
                          │ HTTP: POST /api/sigatoka/{id}/calcular-todo
                          ▼
┌─────────────────────────────────────────────────────────────┐
│  BACKEND: POST /{evaluacionId}/calcular-todo               │
│  - Lee muestras de BD (sigatoka_muestra_completa)          │
│  - Recalcula TODO desde cero (ignora datos del frontend)   │
│  - Guarda en 4 tablas:                                      │
│    ✅ sigatoka_resumen                                      │
│    ✅ sigatoka_indicadores                                  │
│    ✅ sigatoka_estado_evolutivo                            │
│    ✅ sigatoka_stover_promedio                             │
│  - ❌ NO guarda conteo de literales                         │
└─────────────────────────────────────────────────────────────┘
```

---

## ============================================
## 2. PROBLEMA IDENTIFICADO
## ============================================

### ⚠️ **CONFUSIÓN DE RESPONSABILIDADES:**

```
FRONTEND calcula:                BACKEND calcula:
- Variables a-k                  - Variables a-k (otra vez)
- Estado Evolutivo               - Estado Evolutivo (otra vez)
- Stover promedios              - Stover promedios (otra vez)
- ❌ NO literales                - ❌ NO literales (nunca)

RESULTADO: 
✅ Los datos RAW se guardan bien (muestras)
❌ Los cálculos se hacen 2 veces (frontend Y backend)
❌ Los cálculos del frontend se IGNORAN
❌ El backend recalcula todo desde las muestras
❌ Los literales (a-j) NO se cuentan NUNCA
```

### 📊 **TABLAS EN BASE DE DATOS:**

```sql
-- ✅ ESTAS TABLAS EXISTEN Y FUNCIONAN:
sigatoka_evaluacion            -- Encabezado (hacienda, fecha, evaluador)
sigatoka_lote                  -- Agrupación de muestras
sigatoka_muestra_completa      -- Datos RAW (cada muestra individual)
sigatoka_resumen               -- Se llena cuando backend calcula
sigatoka_indicadores           -- Se llena cuando backend calcula
sigatoka_estado_evolutivo      -- Se llena cuando backend calcula
sigatoka_stover_promedio       -- Se llena cuando backend calcula

-- ❌ ESTA TABLA NO EXISTE (script creado pero no ejecutado):
sigatoka_conteo_literales      -- Conteo de literales a-j
```

---

## ============================================
## 3. LO QUE DEBERÍA PASAR (ARQUITECTURA CORRECTA)
## ============================================

### **OPCIÓN A: Frontend calcula TODO, Backend solo guarda**

```
┌────────────────────────────────────────────────┐
│  FRONTEND (Flutter)                            │
│  1. Usuario agrega muestras (una por una)     │
│     - Se guardan en BD inmediatamente          │
│     - Se guardan en memoria (muestrasSesion)  │
│                                                 │
│  2. Usuario ve "Resumen"                       │
│     - Calcular desde muestrasSesion:          │
│       › Literales a-j (contar)                │
│       › Variables a-k                          │
│       › Estado Evolutivo                       │
│       › Stover                                 │
│     - Mostrar todo en UI                       │
│                                                 │
│  3. Usuario click "Guardar Resumen"            │
│     - Enviar TODO calculado al backend:       │
│       POST /guardar-resumen-completo          │
│       {                                        │
│         "literales": {                        │
│           "3era": {"a": 4, "b": 2, ...},     │
│           "4ta": {...},                       │
│           "5ta": {...}                        │
│         },                                     │
│         "resumen": {...},                     │
│         "indicadores": {...},                 │
│         "estadoEvolutivo": {...},             │
│         "stover": {...}                       │
│       }                                        │
└────────────────────────────────────────────────┘
                    │
                    │ POST una sola vez
                    ▼
┌────────────────────────────────────────────────┐
│  BACKEND (Spring Boot)                         │
│  - Recibe payload completo                     │
│  - NO recalcula nada                           │
│  - Solo guarda en 5 tablas:                    │
│    1) sigatoka_conteo_literales               │
│    2) sigatoka_resumen                        │
│    3) sigatoka_indicadores                    │
│    4) sigatoka_estado_evolutivo               │
│    5) sigatoka_stover_promedio                │
└────────────────────────────────────────────────┘
```

**VENTAJAS:**
- ✅ Una sola fuente de verdad (Frontend calcula)
- ✅ Backend no recalcula (más eficiente)
- ✅ Usuario ve exactamente lo que se guarda
- ✅ Literales incluidos en el guardado

---

### **OPCIÓN B: Backend calcula TODO (Frontend solo muestra)**

```
┌────────────────────────────────────────────────┐
│  FRONTEND (Flutter)                            │
│  1. Usuario agrega muestras (una por una)     │
│     - Se guardan en BD inmediatamente          │
│                                                 │
│  2. Usuario click "Ver Resumen"                │
│     - Llamar: GET /calcular-todo              │
│     - Backend calcula TODO                     │
│     - Frontend solo muestra resultados         │
│                                                 │
│  3. Usuario click "Guardar"                    │
│     - Ya está calculado (no hace nada)        │
│     - O vuelve a llamar calcular-todo         │
└────────────────────────────────────────────────┘
                    │
                    │ GET
                    ▼
┌────────────────────────────────────────────────┐
│  BACKEND (Spring Boot)                         │
│  - Lee muestras de BD                          │
│  - Calcula:                                    │
│    › Literales a-j                            │
│    › Variables a-k                             │
│    › Estado Evolutivo                          │
│    › Stover                                    │
│  - Guarda en 5 tablas                          │
│  - Devuelve JSON completo                      │
└────────────────────────────────────────────────┘
```

**VENTAJAS:**
- ✅ Backend es la autoridad (cálculos confiables)
- ✅ Frontend simple (no calcula nada)
- ✅ Fácil recalcular desde cualquier cliente

**DESVENTAJAS:**
- ❌ Usuario no ve preview hasta guardar
- ❌ Más peticiones HTTP

---

## ============================================
## 4. RECOMENDACIÓN
## ============================================

### **🎯 OPCIÓN A - Frontend Calcula, Backend Guarda**

**RAZÓN:**
1. ✅ Ya tienes el código de cálculo en `resumen_sigatoka_screen.dart`
2. ✅ Usuario necesita ver preview ANTES de guardar
3. ✅ Evaluaciones pueden durar 2-3 horas en campo (necesita feedback inmediato)
4. ✅ Más fácil implementar: solo agregar conteo de literales

**QUÉ CAMBIAR:**

### **PASO 1: Agregar conteo de literales en Frontend**
```dart
// En resumen_sigatoka_screen.dart

// Agregar variables al comienzo:
late Map<String, int> literales3era;
late Map<String, int> literales4ta;
late Map<String, int> literales5ta;

// En _calcularResumen():
void _calcularResumen() {
  // ... código existente ...
  
  // NUEVO: Contar literales
  literales3era = _contarLiterales(todasLasMuestras, 'hoja3era');
  literales4ta = _contarLiterales(todasLasMuestras, 'hoja4ta');
  literales5ta = _contarLiterales(todasLasMuestras, 'hoja5ta');
}

// NUEVO método:
Map<String, int> _contarLiterales(List<Map<String, dynamic>> muestras, String campo) {
  final conteo = {
    'a': 0, 'b': 0, 'c': 0, 'd': 0, 'e': 0,
    'f': 0, 'g': 0, 'h': 0, 'i': 0, 'j': 0,
  };
  
  for (var muestra in muestras) {
    if (muestra[campo] != null) {
      String valor = muestra[campo].toString();
      if (valor.isNotEmpty) {
        // Extraer última letra: '2a' → 'a', '3b' → 'b'
        String letra = valor[valor.length - 1].toLowerCase();
        if (conteo.containsKey(letra)) {
          conteo[letra] = conteo[letra]! + 1;
        }
      }
    }
  }
  
  return conteo;
}
```

### **PASO 2: Mostrar tabla de literales en UI**
```dart
// Agregar antes de _buildVariablesTable():
Widget _buildConteoLiterales() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Icon(Icons.format_list_numbered, color: Colors.purple[700], size: 24),
          const SizedBox(width: 8),
          Text(
            '🔢 CONTEO DE LITERALES (a-j)',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.purple[700],
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Table(
          border: TableBorder.symmetric(inside: BorderSide(color: Colors.grey[300]!)),
          children: [
            // Header
            TableRow(
              decoration: BoxDecoration(color: Colors.purple[700]),
              children: [
                _cellHeader('Literal'),
                _cellHeader('3era H'),
                _cellHeader('4ta H'),
                _cellHeader('5ta H'),
                _cellHeader('Total'),
              ],
            ),
            // Filas a-j
            for (var letra in ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j'])
              TableRow(
                decoration: BoxDecoration(
                  color: ['a', 'c', 'e', 'g', 'i'].contains(letra) 
                    ? Colors.grey[50] 
                    : Colors.white,
                ),
                children: [
                  _cell(letra.toUpperCase(), bold: true),
                  _cell(literales3era[letra].toString()),
                  _cell(literales4ta[letra].toString()),
                  _cell(literales5ta[letra].toString()),
                  _cell((literales3era[letra]! + literales4ta[letra]! + literales5ta[letra]!).toString(), 
                    bold: true, 
                    color: Colors.blue[700]!
                  ),
                ],
              ),
          ],
        ),
      ),
    ],
  );
}

Widget _cellHeader(String text) {
  return Padding(
    padding: const EdgeInsets.all(10.0),
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 13,
        color: Colors.white,
      ),
    ),
  );
}

Widget _cell(String text, {bool bold = false, Color? color}) {
  return Padding(
    padding: const EdgeInsets.all(10.0),
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 13,
        fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        color: color,
      ),
    ),
  );
}
```

### **PASO 3: Incluir literales en el guardado**
```dart
// Modificar _guardarResumen():
final resumenData = {
  // ... datos existentes ...
  
  // NUEVO: Agregar conteos de literales
  'conteoLiterales': {
    '3era': literales3era,
    '4ta': literales4ta,
    '5ta': literales5ta,
  },
};
```

### **PASO 4: Backend recibe y guarda literales**
```java
// NUEVO endpoint en SigatokaEvaluacionController.java
@PostMapping("/{evaluacionId}/guardar-resumen-frontend")
public ResponseEntity<?> guardarResumenDesdeApp(
    @PathVariable Long evaluacionId,
    @RequestBody Map<String, Object> payload
) {
    // Extraer conteo de literales
    Map<String, Map<String, Integer>> literales = 
        (Map<String, Map<String, Integer>>) payload.get("conteoLiterales");
    
    // Guardar en sigatoka_conteo_literales
    service.guardarConteoLiterales(evaluacionId, literales);
    
    // Guardar resto del resumen (código existente)
    // ...
    
    return ResponseEntity.ok("Guardado exitosamente");
}
```

### **PASO 5: Crear tabla en BD**
```powershell
# Ejecutar script:
Get-Content backend_new\database\sigatoka_tabla_conteo_literales.sql | docker exec -i lytiks-new-mysql mysql -ulytiks_user -plytiks_pass lytiks_db
```

---

## ============================================
## 5. RESUMEN EJECUTIVO
## ============================================

**PROBLEMA ACTUAL:**
- Frontend calcula pero backend recalcula (duplicación)
- Literales NO se cuentan ni guardan
- Usuario no ve lo mismo que se guarda

**SOLUCIÓN:**
- Frontend calcula TODO (incluyendo literales a-j)
- Backend solo guarda lo que frontend envía
- NO duplicar cálculos
- Tabla `sigatoka_conteo_literales` debe crearse

**ARCHIVOS A MODIFICAR:**
1. `lib/screens/resumen_sigatoka_screen.dart` - Agregar conteo y tabla de literales
2. `lib/services/sigatoka_evaluacion_service.dart` - Modificar payload
3. Backend: Nuevo endpoint o adaptar existente
4. BD: Ejecutar `sigatoka_tabla_conteo_literales.sql`

**CAMBIOS MÍNIMOS:**
- ✅ ~50 líneas en resumen_sigatoka_screen.dart
- ✅ ~10 líneas en sigatoka_evaluacion_service.dart
- ✅ 1 script SQL (ya existe)
- ✅ Backend opcional (puede seguir usando calcular-todo)
