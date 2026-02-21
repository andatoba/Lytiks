# 📱 GUÍA PASO A PASO: Cómo Agregar Muestras en Sigatoka

## ✅ DIAGNÓSTICO CONFIRMADO

### Resultados de Base de Datos:
```
sigatoka_evaluacion:  8 registros  ← Evaluaciones creadas ✅
sigatoka_lote:        0 registros  ← NO hay lotes ❌
sigatoka_muestra:     0 registros  ← NO hay muestras ❌
```

**PROBLEMA:** Las 8 evaluaciones fueron creadas pero el proceso NO se completó.
**CAUSA:** No se agregaron muestras después de crear las evaluaciones.

---

## 🎯 FLUJO CORRECTO (3 PASOS)

```
┌─────────────────────┐
│ PASO 1              │
│ Crear Evaluación    │ ✅ YA FUNCIONA (8 evaluaciones creadas)
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ PASO 2              │
│ Agregar Muestras    │ ⚠️  ESTE PASO FALTA - AQUÍ ESTÁ EL PROBLEMA
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ PASO 3              │
│ Calcular Reporte    │ ❌ No hay datos para calcular
└─────────────────────┘
```

---

## 📱 CÓMO COMPLETAR EL FLUJO EN LA APP

### PASO A: Crear Nueva Evaluación (ya sabes hacer esto)

1. Abrir app Flutter
2. Ir a menú → **"Evaluación Sigatoka"**
3. Llenar formulario:
   - **Cliente:** Seleccionar de la lista
   - **Hacienda:** "Finca Prueba" (o cualquier nombre)
   - **Fecha:** Seleccionar fecha actual
   - **Evaluador:** "Operador" (o tu nombre)
4. Presionar botón **"Crear Evaluación"** 
5. ✅ Esperar mensaje: **"Evaluación creada exitosamente"**

---

### PASO B: Agregar Muestras (⚠️ CRÍTICO - ESTE PASO FALTA)

**Después de crear la evaluación, la pantalla debe cambiar** para mostrar el formulario de ingreso de muestras.

#### **Muestra #1:**

```
┌──────────────────────────────────────┐
│ 🧪 Formulario de Muestra #1          │
├──────────────────────────────────────┤
│ Lote: LOTE-001                       │ ← Código del lote
│                                      │
│ 📊 GRADOS DE INFECCIÓN (opcional)    │
│ Hoja 3era: [   ]                     │
│ Hoja 4ta:  [   ]                     │
│ Hoja 5ta:  [   ]                     │
│                                      │
│ 📈 VARIABLES PARA CÁLCULO (a-e)      │
│ a) Plantas con Lesiones: 10          │ ← REQUERIDO
│ b) Total de Lesiones: 25             │ ← REQUERIDO
│ c) Plantas en 3er Estadio: 5         │ ← REQUERIDO
│ d) Total de Letras: 15               │ ← REQUERIDO
│                                      │
│ 📊 VARIABLES STOVER (opcional)       │
│ H.V.L.E. 0w: [   ]                   │
│ H.V.L.Q. 0w: [   ]                   │
│ ...                                  │
│                                      │
│ [  Agregar Muestra  ]                │ ← PRESIONAR AQUÍ
└──────────────────────────────────────┘
```

**IMPORTANTE:** Después de presionar "Agregar Muestra", debes ver:
```
✅ "Muestra #1 agregada exitosamente"
```

#### **Muestra #2, #3, #4, #5:**

El formulario se limpia automáticamente y muestra:
```
🧪 Formulario de Muestra #2
```

Agregar datos (puedes variar los valores):
- Lote: LOTE-001 (mismo lote) o LOTE-002 (nuevo lote)
- Plantas con Lesiones: 8
- Total de Lesiones: 20
- Plantas en 3er Estadio: 4
- Total de Letras: 12

**Repetir hasta tener al menos 5 muestras.**

---

### PASO C: Calcular Resultados

Después de agregar las muestras:

1. Presionar botón **"Calcular y Ver Reporte"**
2. El sistema calculará automáticamente:
   - Resumen (promedios a-e)
   - Indicadores (f-k)
   - Estado Evolutivo (EE)
   - Stover
3. Verás la pantalla con los resultados

---

## 🔍 VERIFICAR QUE FUNCIONÓ

### En la App:
- ✅ Debes ver el mensaje "Muestra #X agregada exitosamente" después de cada muestra
- ✅ El número de muestra debe incrementarse (#1, #2, #3...)
- ✅ Al final, verás el reporte con datos calculados

### En la Base de Datos:

```sql
-- Ver la nueva evaluación (será ID 9)
SELECT * FROM sigatoka_evaluacion ORDER BY id DESC LIMIT 1;

-- Ver lotes creados
SELECT * FROM sigatoka_lote WHERE evaluacion_id = 9;
-- Debe mostrar: 1 o 2 lotes (dependiendo si usaste LOTE-001 y LOTE-002)

-- Ver muestras guardadas
SELECT 
    m.id,
    m.muestra_num,
    l.lote_codigo,
    m.plantas_con_lesiones,
    m.total_lesiones
FROM sigatoka_muestra m
INNER JOIN sigatoka_lote l ON m.lote_id = l.id
WHERE l.evaluacion_id = 9;
-- Debe mostrar: 5 muestras con tus datos

-- Ver resumen calculado
SELECT * FROM sigatoka_resumen WHERE evaluacion_id = 9;
-- Debe tener valores calculados en promedio_hojas_emitidas, etc.
```

---

## 🐛 SI NO APARECE EL FORMULARIO DE MUESTRAS

**Posible causa:** La pantalla no cambió después de crear la evaluación.

**Solución:**
1. Verificar que apareció el mensaje "Evaluación creada exitosamente"
2. La pantalla debe mostrar automáticamente "Paso 2: Agregar Muestras"
3. Si no aparece, revisar logs de la app en consola durante desarrollo

---

## 📊 RESULTADO ESPERADO

Después de completar correctamente:

```sql
SELECT 'sigatoka_evaluacion' AS tabla, COUNT(*) AS total FROM sigatoka_evaluacion
UNION ALL
SELECT 'sigatoka_lote' AS tabla, COUNT(*) AS total FROM sigatoka_lote
UNION ALL
SELECT 'sigatoka_muestra' AS tabla, COUNT(*) AS total FROM sigatoka_muestra
UNION ALL
SELECT 'sigatoka_resumen' AS tabla, COUNT(*) AS total FROM sigatoka_resumen;
```

**ANTES:**
```
sigatoka_evaluacion:  8
sigatoka_lote:        0  ← vacío
sigatoka_muestra:     0  ← vacío
sigatoka_resumen:     1
```

**DESPUÉS:**
```
sigatoka_evaluacion:  9  ← +1 nueva
sigatoka_lote:        1  ← +1 o +2 lotes
sigatoka_muestra:     5  ← +5 muestras
sigatoka_resumen:     2  ← +1 nuevo resumen
```

---

## 🎯 RESUMEN

1. **El código funciona correctamente** ✅
2. **Los endpoints responden bien** ✅
3. **El problema es que el proceso no se completó** ⚠️

**Siguiente paso:**
- Crear UNA nueva evaluación
- AGREGAR al menos 5 muestras (este es el paso crítico)
- Calcular y verificar que ahora SÍ aparecen datos en las tablas

---

## 💡 RECOMENDACIÓN

Si después de seguir estos pasos las muestras aún no se guardan:

1. Compartir **logs de la app Flutter** mientras presionas "Agregar Muestra"
2. Compartir **logs del backend** con: `docker logs lytiks-new-backend --tail 50`
3. Probar llamar manualmente al endpoint desde el servidor:

```bash
# Crear lote
curl -X POST http://localhost:8080/api/sigatoka/9/lotes \
  -H "Content-Type: application/json" \
  -d '{"loteCodigo": "LOTE-TEST", "latitud": 0.0, "longitud": 0.0}'

# Agregar muestra
curl -X POST http://localhost:8080/api/sigatoka/lotes/1/muestras \
  -H "Content-Type: application/json" \
  -d '{"muestraNum": 1, "plantasConLesiones": 10, "totalLesiones": 25, "plantas3erEstadio": 5, "totalLetras": 15}'
```

Esto confirmará si el problema está en el frontend (Flutter) o en el backend (Spring Boot).
