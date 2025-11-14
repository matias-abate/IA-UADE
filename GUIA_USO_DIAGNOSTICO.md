# 🚀 Guía de Uso - Sistema de Diagnóstico Automático

## 📚 Índice
1. [Inicio Rápido](#inicio-rápido)
2. [Flujo Completo](#flujo-completo)
3. [Ejemplos por Síntoma](#ejemplos-por-síntoma)
4. [API Reference](#api-reference)
5. [Interpretación de Resultados](#interpretación-de-resultados)

---

## Inicio Rápido

### 1. Iniciar el Backend
```bash
cd /Users/matiasabate/Documents/IA/Back
java -jar target/sistema-experto-1.0.0.jar
```

El sistema estará disponible en: `http://localhost:8080`

### 2. Iniciar el Frontend
```bash
cd /Users/matiasabate/Documents/IA/Front
npm run dev
```

El frontend estará en: `http://localhost:5173`

### 3. Probar Diagnóstico
```bash
cd /Users/matiasabate/Documents/IA/Back
./test-diagnostico.sh
```

---

## Flujo Completo

### Paso 1: Crear Caso
El operador recibe una llamada y crea un caso:

**Frontend:** Click en "Nuevo Caso"
**Backend API:**
```bash
POST /api/casos
Content-Type: application/json

{
  "clienteNombre": "María González",
  "clienteTelefono": "+54 11 4567-8900",
  "tipo": "HELADERA",
  "marca": "Whirlpool",
  "modelo": "WRX35",
  "antiguedad": 5,
  "sintomaReportado": "No enfría"
}
```

**Respuesta:**
```json
{
  "id": 1,
  "clienteNombre": "María González",
  "tipo": "HELADERA",
  "estado": "EN_DIAGNOSTICO",
  "fechaCreacion": "2025-11-02T23:10:00"
}
```

### Paso 2: Obtener Primera Pregunta
El sistema automáticamente:
1. Analiza el síntoma reportado
2. Selecciona la regla más apropiada
3. Crea hipótesis iniciales
4. Retorna la primera pregunta

**API:**
```bash
GET /api/casos/1/siguiente-pregunta
```

**Respuesta:**
```json
{
  "id": 1,
  "texto": "¿La luz interior de la heladera funciona cuando abre la puerta?",
  "tipo": "SI_NO",
  "critica": true,
  "ayuda": "Esta pregunta verifica si hay alimentación eléctrica correcta"
}
```

### Paso 3: Responder Pregunta
El operador pregunta al cliente y registra la respuesta:

**API:**
```bash
POST /api/casos/1/responder
Content-Type: application/json

{
  "preguntaId": 1,
  "valor": "true"
}
```

**Respuesta:** `200 OK`

### Paso 4: Ver Hipótesis Actualizadas
```bash
GET /api/casos/1/hipotesis
```

**Respuesta:**
```json
[
  {
    "id": 1,
    "descripcion": "Problema eléctrico",
    "probabilidad": 10,
    "activa": false
  },
  {
    "id": 2,
    "descripcion": "Falla del compresor",
    "probabilidad": 40,
    "activa": true
  },
  {
    "id": 3,
    "descripcion": "Termostato defectuoso",
    "probabilidad": 30,
    "activa": true
  }
]
```

### Paso 5: Repetir Preguntas
Repetir pasos 2-4 hasta que no haya más preguntas:

```bash
GET /api/casos/1/siguiente-pregunta
# Retorna 204 No Content cuando terminó
```

### Paso 6: Finalizar Diagnóstico
```bash
POST /api/casos/1/finalizar
```

**Respuesta:**
```json
{
  "id": 1,
  "estado": "DIAGNOSTICADO",
  "diagnostico": {
    "causaProbable": "Compresor defectuoso o relé de arranque dañado",
    "probabilidad": 75,
    "componenteAfectado": "Compresor / Relé de arranque",
    "requiereTecnico": true,
    "tipoSolucion": "TECNICO_COMPLEJO",
    "urgencia": "ALTA",
    "costoEstimadoMin": 80000,
    "costoEstimadoMax": 150000,
    "tiempoEstimado": 180,
    "repuestosProbables": [
      "Compresor",
      "Relé de arranque",
      "Capacitor"
    ],
    "mensajesCliente": [
      "Trasladar alimentos perecederos a otro lugar",
      "Mantener la puerta cerrada mientras tanto",
      "Se programará visita técnica en 24hs"
    ],
    "alertasSeguridad": [
      "Desconectar la heladera si el motor está muy caliente"
    ],
    "generarOrdenTrabajo": true,
    "prioridadOT": "urgente"
  }
}
```

---

## Ejemplos por Síntoma

### 🧊 Heladera No Enfría

#### Escenario 1: Problema Simple (DIY)
```
P1: ¿La luz funciona? → NO
→ Diagnóstico: Sin alimentación eléctrica
→ Solución: DIY - Verificar enchufe/fusibles
→ Costo: $0-5000
→ Tiempo: 10 min
```

#### Escenario 2: Compresor Defectuoso
```
P1: ¿La luz funciona? → SÍ
P2: ¿Motor suena? → NO
P3: ¿Motor caliente? → SÍ
→ Diagnóstico: Compresor defectuoso
→ Solución: TÉCNICO COMPLEJO
→ Costo: $80,000-150,000
→ Tiempo: 180 min
→ OT: URGENTE
```

#### Escenario 3: Termostato
```
P1: ¿La luz funciona? → SÍ
P2: ¿Motor suena? → SÍ
P4: ¿Ciclos? → Constantemente sin parar
P5: ¿Hielo excesivo? → NO
→ Diagnóstico: Termostato defectuoso
→ Solución: TÉCNICO SIMPLE
→ Costo: $20,000-35,000
→ Tiempo: 45 min
```

### 💧 Lavarropas No Carga Agua

#### Escenario 1: Solución Inmediata
```
P1: ¿Canilla abierta? → NO
→ Diagnóstico: Canilla cerrada
→ Solución: DIY - Abrir canilla
→ Costo: $0
→ Tiempo: 2 min
```

#### Escenario 2: Electroválvula
```
P1: ¿Canilla abierta? → SÍ
P2: ¿Hay presión? → SÍ
P3: ¿Manguera doblada? → NO
→ Diagnóstico: Filtro obstruido o electroválvula
→ Solución: TÉCNICO SIMPLE
→ Costo: $15,000-35,000
→ Tiempo: 45 min
```

### ⚡ Microondas Hace Chispas (CRÍTICO)

#### Escenario 1: Usuario Error
```
P1: ¿Había metal? → SÍ
→ Diagnóstico: Objeto metálico dentro
→ Solución: DIY con ADVERTENCIAS
→ Costo: $0
→ ⚠️ Alertas: NUNCA usar metal
```

#### Escenario 2: PELIGRO
```
P1: ¿Había metal? → NO
P2: ¿Plato OK? → SÍ
→ Diagnóstico: Mica perforada o magnetrón
→ Solución: CRÍTICO
→ 🚨 NO USAR HASTA REVISIÓN
→ Costo: $25,000-80,000
→ OT: CRÍTICA - 24hs
```

---

## API Reference

### Casos

#### Crear Caso
```
POST /api/casos
Body: CasoCreateDTO
Response: Caso
```

#### Listar Casos
```
GET /api/casos
Response: List<Caso>
```

#### Obtener Caso
```
GET /api/casos/{id}
Response: Caso (con diagnóstico si está finalizado)
```

### Diagnóstico

#### Siguiente Pregunta
```
GET /api/casos/{id}/siguiente-pregunta
Response: Pregunta | 204 No Content
```

#### Responder
```
POST /api/casos/{id}/responder
Body: { preguntaId: number, valor: string }
Response: 200 OK
```

#### Hipótesis Actuales
```
GET /api/casos/{id}/hipotesis
Response: List<Hipotesis>
```

#### Finalizar Diagnóstico
```
POST /api/casos/{id}/finalizar
Response: Caso (con diagnóstico completo)
```

### Métricas

#### Obtener Métricas
```
GET /api/metricas
Response: Metricas
```

---

## Interpretación de Resultados

### Tipos de Solución

| Tipo | Descripción | Cliente puede hacer |
|------|-------------|---------------------|
| `DIY` | Do It Yourself | ✅ Sí, instrucciones incluidas |
| `TECNICO_SIMPLE` | Técnico - Rápido | ❌ No, requiere técnico |
| `TECNICO_COMPLEJO` | Técnico - Complejo | ❌ No, técnico especializado |
| `REEMPLAZO` | Evaluar reemplazo | ❌ No, técnico evalúa |

### Niveles de Urgencia

| Urgencia | Tiempo Respuesta | Acción |
|----------|-----------------|---------|
| `BAJA` | 3-5 días | Agendar normalmente |
| `MEDIA` | 24-48 horas | Agendar pronto |
| `ALTA` | Mismo día | Priorizar |
| `CRITICA` | Inmediato | 🚨 URGENTE - No usar equipo |

### Probabilidad de Diagnóstico

- **85-100%**: Muy confiable - Proceder con seguridad
- **70-84%**: Confiable - Alta probabilidad
- **50-69%**: Probable - Verificar con técnico
- **< 50%**: Incierto - Requiere inspección presencial

### Generar Orden de Trabajo

Si `generarOrdenTrabajo = true`:
1. Crear OT en sistema
2. Asignar técnico según `prioridadOT`
3. Incluir:
   - Lista de repuestos probables
   - Tiempo estimado
   - Costo estimado
   - Instrucciones especiales

---

## 🎯 Consejos de Uso

### Para Operadores

1. **Leer las preguntas exactamente como están**
   - Están diseñadas para ser claras
   - La ayuda contextual es para el cliente

2. **Registrar respuestas con precisión**
   - SI/NO debe ser claro
   - Si el cliente duda, usar la ayuda

3. **Explicar instrucciones DIY claramente**
   - Paso a paso
   - Enfatizar alertas de seguridad
   - Cuándo llamar técnico

4. **Casos críticos (🚨)**
   - Enfatizar NO USAR el equipo
   - Desenchufar inmediatamente
   - Técnico en 24hs

### Para Técnicos

1. **Revisar diagnóstico antes de salir**
   - Lista de repuestos probables
   - Herramientas necesarias
   - Tiempo estimado

2. **Validar hipótesis**
   - El diagnóstico es probabilístico
   - Siempre verificar en sitio

3. **Actualizar sistema**
   - Si el diagnóstico fue correcto
   - Si se necesitó otra cosa
   - Ayuda a mejorar el sistema

---

## 🐛 Troubleshooting

### "No se encontró regla aplicable"
- Verificar que el síntoma esté bien escrito
- El sistema busca palabras clave
- Ejemplo: "no enfria" vs "no enfría" ✓

### "Error al procesar respuesta"
- Verificar que el valor coincida con el tipo
- SI_NO: "true" o "false"
- OPCION_MULTIPLE: exactamente una de las opciones

### "Diagnóstico genérico"
- Respuestas insuficientes
- Completar todas las preguntas posibles

---

## 📊 Monitoreo

Ver logs en tiempo real:
```bash
tail -f /var/log/sistema-experto.log
```

Métricas importantes:
- Casos totales
- % DIY exitosos
- Tiempo promedio de diagnóstico
- Precisión de diagnósticos

---

**Sistema listo para producción ✅**
**Versión: 1.0.0**
**Fecha: 2025-11-02**

