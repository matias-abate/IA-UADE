# Sistema de Diagnóstico Automático - Implementación Completa

## 📋 Resumen de Implementación

Se ha implementado un **Motor de Inferencia basado en Reglas** para el diagnóstico automático de electrodomésticos.

---

## 🏗️ Arquitectura Implementada

### 1. Modelos de Datos

#### `Pregunta.java`
- Representa una pregunta del diagnóstico
- Tipos: SI_NO, OPCION_MULTIPLE, TEXTO
- Incluye ayuda contextual e imágenes de referencia

#### `Diagnostico.java` 
- Resultado final del diagnóstico
- Incluye:
  - Causa probable y probabilidad (0-100%)
  - Componente afectado
  - Tipo de solución (DIY, TÉCNICO_SIMPLE, TÉCNICO_COMPLEJO, REEMPLAZO)
  - Urgencia (BAJA, MEDIA, ALTA, CRÍTICA)
  - Costos estimados (min-max)
  - Tiempo estimado
  - Instrucciones DIY
  - Alertas de seguridad
  - Repuestos probables
  - Mensajes al cliente
  - Flags para orden de trabajo

#### `Hipotesis.java`
- Hipótesis de diagnóstico con probabilidad
- Se actualizan dinámicamente según respuestas

---

## 🧠 Motor de Inferencia

### `InferenceEngine.java`
Motor principal que:
1. **Selecciona la regla aplicable** según tipo y síntoma
2. **Gestiona el flujo de preguntas** secuencialmente
3. **Actualiza hipótesis** en tiempo real
4. **Evalúa diagnóstico final** usando árbol de decisión
5. **Mantiene caché** de estado por caso

#### Métodos Principales:
- `obtenerSiguientePregunta(Caso)` - Retorna próxima pregunta
- `procesarRespuesta(Caso, Respuesta)` - Procesa respuesta del operador
- `realizarDiagnostico(Caso)` - Genera diagnóstico final

---

## 📐 Reglas de Diagnóstico Implementadas

### ✅ CRÍTICO 1: Heladera No Enfría
**Archivo:** `HeladeraNoEnfriaRule.java`
**Prioridad:** 100 (Máxima)

**Árbol de Decisión:**
```
P1: ¿La luz funciona?
  ├─ NO → Problema eléctrico (DIY)
  └─ SÍ → P2: ¿Motor suena?
         ├─ NO → P3: ¿Motor caliente?
         │      ├─ SÍ → Compresor defectuoso (TÉCNICO COMPLEJO)
         │      └─ NO → Problema eléctrico compresor (TÉCNICO SIMPLE)
         └─ SÍ → P4: ¿Funciona constantemente o por ciclos?
                ├─ Constantemente → P5: ¿Hielo excesivo?
                │      ├─ NO → Termostato defectuoso
                │      └─ SÍ → Sistema desescarche defectuoso
                └─ Ciclos → P5: ¿Hielo excesivo?
                       ├─ SÍ → Obstrucción de flujo (DIY)
                       └─ NO → Posible fuga de gas (TÉCNICO COMPLEJO)
```

**Diagnósticos Posibles:**
- Sin alimentación eléctrica (DIY, 0-5000 ARS)
- Compresor defectuoso (TÉCNICO COMPLEJO, 80000-150000 ARS)
- Problema eléctrico compresor (TÉCNICO SIMPLE, 25000-50000 ARS)
- Termostato defectuoso (TÉCNICO SIMPLE, 20000-35000 ARS)
- Sistema desescarche (TÉCNICO SIMPLE, 25000-45000 ARS)
- Obstrucción flujo aire (DIY, 0-15000 ARS)
- Fuga gas refrigerante (TÉCNICO COMPLEJO, 50000-120000 ARS)

---

### ✅ CRÍTICO 2: Lavarropas No Carga Agua
**Archivo:** `LavarropasNoCargaAguaRule.java`
**Prioridad:** 95 (Alta)

**Árbol de Decisión:**
```
P1: ¿Canilla abierta?
  ├─ NO → Abrir canilla (DIY - 2 min)
  └─ SÍ → P2: ¿Hay presión en otras canillas?
         ├─ NO → Problema suministro general (DIY)
         └─ SÍ → P3: ¿Manguera doblada/aplastada?
                ├─ SÍ → Enderezar manguera (DIY)
                └─ NO → Filtro obstruido o electroválvula (TÉCNICO)
```

**Diagnósticos Posibles:**
- Canilla cerrada (DIY, 0 ARS, 2 min)
- Problema suministro agua (DIY, 0 ARS)
- Manguera obstruida (DIY, 0-5000 ARS)
- Filtro/electroválvula (TÉCNICO SIMPLE, 15000-35000 ARS)

---

### ✅ CRÍTICO 3: Microondas Hace Chispas
**Archivo:** `MicroondasHaceChispasRule.java`
**Prioridad:** 200 (MÁXIMA - SEGURIDAD)

**Árbol de Decisión:**
```
P1: 🚨 ¿Había metal dentro?
  ├─ SÍ → Uso incorrecto - ADVERTENCIA (DIY con precauciones)
  └─ NO → P2: ¿Plato giratorio bien colocado?
         ├─ NO → Recolocar plato (DIY)
         └─ SÍ → 🚨 Mica perforada o magnetrón (CRÍTICO - NO USAR)
```

**Diagnósticos Posibles:**
- Objeto metálico (DIY con advertencias severas, 0 ARS)
- Plato mal colocado (DIY, 0-8000 ARS)
- Mica perforada/magnetrón (CRÍTICO, 25000-80000 ARS, NO USAR HASTA REVISIÓN)

**Alertas de Seguridad:**
- 🚨 NO usar si hay chispas sin metal visible
- 🚨 Desenchufar inmediatamente
- 🚨 Riesgo de incendio y radiación

---

## 🔄 Flujo de Funcionamiento

### 1. Creación de Caso
```java
Caso caso = casoService.crearCaso(dto);
// Motor selecciona regla automáticamente
```

### 2. Inicio de Diagnóstico
```java
Pregunta primera = inferenceEngine.obtenerSiguientePregunta(caso);
// Retorna: "¿La luz interior funciona?"
```

### 3. Proceso Iterativo
```java
// Operador responde
respuesta.setValor("true"); // o "false"
inferenceEngine.procesarRespuesta(caso, respuesta);

// Sistema obtiene siguiente pregunta
Pregunta siguiente = inferenceEngine.obtenerSiguientePregunta(caso);

// Hipótesis se actualizan en tiempo real
List<Hipotesis> hipotesis = inferenceEngine.obtenerHipotesisActuales(caso);
```

### 4. Finalización
```java
// Cuando no hay más preguntas
if (siguiente == null) {
    inferenceEngine.realizarDiagnostico(caso);
    // Genera diagnóstico final con instrucciones
}
```

---

## 📊 Características del Sistema

### ✅ Implementado

1. **Árbol de Decisión Dinámico**
   - Preguntas adaptativas según respuestas previas
   - Rutas condicionales inteligentes

2. **Hipótesis en Tiempo Real**
   - Se crean al inicio basadas en el síntoma
   - Se actualizan con cada respuesta
   - Probabilidades normalizadas (suman 100%)

3. **Diagnósticos Detallados**
   - Causa probable con % de certeza
   - Componente específico afectado
   - Tipo de solución requerida
   - Urgencia clasificada
   - Costos estimados precisos
   - Tiempo estimado de reparación

4. **Instrucciones DIY**
   - Paso a paso claros
   - Alertas de seguridad cuando aplica
   - Cuándo llamar al técnico

5. **Gestión de Órdenes de Trabajo**
   - Flag automático si requiere técnico
   - Prioridad asignada (baja/media/alta/crítica)
   - Lista de repuestos probables

6. **Sistema de Seguridad**
   - Detección de problemas críticos
   - Advertencias destacadas
   - Instrucciones de apagado inmediato

---

## 🎯 Casos de Uso Especiales

### Caso 1: Cliente Experimentado DIY
```java
// El sistema detecta historial_diy_exitosos > 3
// Ofrece más soluciones DIY cuando es seguro
```

### Caso 2: Electrodoméstico Antiguo (>10 años)
```java
// Si costo reparación > 50% valor nuevo
// Sugiere: "Evaluar reemplazo"
```

### Caso 3: Problema de Seguridad
```java
// Urgencia = CRÍTICA
// Instrucción: "NO USAR hasta revisión técnica"
// Prioridad OT = "urgente" o "critica"
```

---

## 📈 Métricas y Logging

El sistema registra:
- Cada pregunta formulada
- Cada respuesta recibida
- Cambios en probabilidades de hipótesis
- Regla seleccionada y por qué
- Diagnóstico final generado
- Tiempo de resolución

---

## 🚀 Extensibilidad

### Para Agregar Nueva Regla:

1. Crear clase en `service/rules/{tipo}/`
2. Implementar interfaz `DiagnosticRule`
3. Anotar con `@Component`
4. Definir:
   - Pattern del síntoma
   - Preguntas secuenciales
   - Árbol de decisión en `evaluarDiagnostico()`
   - Prioridad

```java
@Component
public class MiNuevaRegla implements DiagnosticRule {
    private static final Pattern SINTOMA_PATTERN = 
        Pattern.compile(".*mi_sintoma.*", Pattern.CASE_INSENSITIVE);
    
    @Override
    public Diagnostico evaluarDiagnostico(Map<String, Object> respuestas, Caso caso) {
        // Lógica de árbol de decisión
        if (respuestas.get("p1") == true) {
            return Diagnostico.builder()
                .causaProbable("...")
                .probabilidad(85)
                // ... resto de campos
                .build();
        }
        // ...
    }
}
```

El sistema lo detectará automáticamente (Spring auto-wiring).

---

## 📝 Estado de Implementación

### ✅ Completado (3/3 Críticos)

1. ✅ **Heladera no enfría** - 5 preguntas, 7+ diagnósticos
2. ✅ **Lavarropas no carga agua** - 3 preguntas, 4+ diagnósticos  
3. ✅ **Microondas hace chispas** - 2 preguntas, 3+ diagnósticos (SEGURIDAD)

### 🔄 Próximas Prioridades

4. ⚠️ Lavarropas no desagota
5. ⚠️ Lavarropas vibra excesivamente
6. ⚠️ Lavarropas no centrifuga
7. 📋 Heladera pierde agua
8. 📋 Heladera hace ruido
9. 📋 Microondas no calienta
10. 📋 Microondas plato no gira

---

## 🧪 Testing

### Probar Diagnóstico:

```bash
# 1. Crear caso
POST /api/casos
{
  "clienteNombre": "Juan Pérez",
  "tipo": "HELADERA",
  "sintomaReportado": "No enfría"
}

# 2. Obtener primera pregunta
GET /api/casos/{id}/siguiente-pregunta

# 3. Responder
POST /api/casos/{id}/responder
{
  "preguntaId": 1,
  "valor": "true"
}

# 4. Repetir 2-3 hasta que siguiente-pregunta retorne 204 (No Content)

# 5. Finalizar
POST /api/casos/{id}/finalizar

# 6. Ver diagnóstico
GET /api/casos/{id}
```

---

## 💾 Base de Datos

### Tablas Creadas Automáticamente:

- `casos` - Casos de diagnóstico
- `respuestas` - Respuestas del operador
- `hipotesis` - Hipótesis con probabilidades
- `diagnosticos` - Diagnósticos finales
- `diagnostico_instrucciones_diy` - Instrucciones DIY
- `diagnostico_alertas_seguridad` - Alertas de seguridad
- `diagnostico_repuestos` - Repuestos probables
- `diagnostico_mensajes_cliente` - Mensajes al cliente

---

## 🎓 Conceptos de IA Implementados

1. **Sistema Basado en Reglas** (Rule-Based System)
2. **Motor de Inferencia** (Inference Engine)
3. **Árbol de Decisión** (Decision Tree)
4. **Razonamiento hacia adelante** (Forward Chaining)
5. **Actualización de probabilidades** (Bayesian-like updates)
6. **Sistema Experto** (Expert System)

---

## 📞 Soporte

Sistema listo para:
- ✅ Diagnóstico automático
- ✅ Generación de órdenes de trabajo
- ✅ Estimación de costos
- ✅ Instrucciones al cliente
- ✅ Priorización de casos
- ✅ Detección de problemas críticos

**El sistema está completamente funcional y listo para producción.**

