# Análisis de Estructura Sigatoka

## ❌ PROBLEMA DETECTADO

Las entidades Java actuales NO coinciden con:
1. La estructura SQL en `sigatoka_tables.sql`
2. El formato Excel requerido

## 📋 Estructura SQL Original (CORRECTA)
```sql
sigatoka_evaluacion: id, cliente_id, hacienda, fecha, semana_epidemiologica, periodo, evaluador
sigatoka_lote: id, evaluacion_id, lote_codigo
sigatoka_muestra: id, lote_id, muestra_num, 
  - hoja_3era, hoja_4ta, hoja_5ta (grados ej: 2a, 3c)
  - total_hojas_3era, total_hojas_4ta, total_hojas_5ta
  - plantas_muestreadas, plantas_con_lesiones, total_lesiones
  - plantas_3er_estadio, total_letras
  - h_v_l_e_0w, h_v_l_q_0w, h_v_l_q5_0w, t_h_0w
  - h_v_l_e_10w, h_v_l_q_10w, h_v_l_q5_10w, t_h_10w
```

## ❌ Estructura Java Actual (INCORRECTA)
```java
SigatokaEvaluacion: ✅ OK
SigatokaMuestra: ❌ FALTAN CAMPOS
  - numeroMuestra, lote, variedad, edad
  - hojasEmitidas, hojasErectas, hojasConSintomas
  - hojaMasJovenEnferma, hojaMasJovenNecrosada
  
  ❌ NO TIENE:
  - grados (hoja_3era, hoja_4ta, hoja_5ta)
  - totales por hoja
  - valores Stover (0w y 10w)
  - plantas con lesiones, estadios, etc.
```

## 🔧 SOLUCIÓN REQUERIDA

Necesitamos REDISEÑAR las entidades para cumplir con el formato Excel:

1. Mantener `SigatokaEvaluacion` (encabezado)
2. Crear `SigatokaLote` (intermedio)
3. Rediseñar `SigatokaMuestra` con TODOS los campos del Excel
4. Los cálculos (a-e, f-k, EE) se hacen en servicio sobre estos datos

## 📊 Campos que DEBE tener SigatokaMuestra según Excel:

Manual (entrada):
- Muestra #, Lote
- Grado 3era, 4ta, 5ta hoja (ej: "2a", "3c")
- Total hojas (por cada nivel)
- H.V.L.E., H.V.L.Q., H.V.L.Q.5%, T.H. (0 semanas)
- H.V.L.E., H.V.L.Q., H.V.L.Q.5%, T.H. (10 semanas)

Calculado (por muestra o agregado):
- Plantas muestreadas (a)
- Plantas con lesiones (b)
- Total lesiones (c)
- Plantas con 3er estadio (d)
- Total letras (e)
