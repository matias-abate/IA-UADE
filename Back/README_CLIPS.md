# Integración CLIPS - Sistema Experto

## 📋 Resumen de Implementación

Se ha implementado la integración completa de CLIPS como motor de inferencia para el sistema experto de diagnóstico de electrodomésticos.

## ✅ Componentes Implementados

### 1. Estructura de Archivos CLIPS

```
Back/src/main/resources/clips/
├── templates.clp          # Plantillas de datos (deftemplate)
├── heladera.clp          # Reglas de diagnóstico para heladeras
├── lavarropas.clp        # Reglas de diagnóstico para lavarropas
├── microondas.clp        # Reglas de diagnóstico para microondas
├── seguridad.clp         # Reglas de seguridad y prevención
└── casos-prueba.clp      # Casos de prueba para validación
```

### 2. Servicios Java

- **ClipsService**: Wrapper para comunicación con CLIPS (proceso externo)
- **ClipsIntegrationService**: Servicio de integración que coordina Java ↔ CLIPS
- **ClipsMapper**: Mapeo bidireccional entre objetos Java y hechos CLIPS
- **InferenceEngine**: Modificado para usar CLIPS con fallback a reglas Java

### 3. Modelos de Datos

- **Recomendacion**: Recomendaciones de mantenimiento y económicas
- **AlertaSeguridad**: Alertas de seguridad (riesgo eléctrico, gas, incendio)
- **ConsejoMantenimiento**: Consejos de mantenimiento periódico

### 4. Reglas CLIPS Implementadas

#### Heladera (5 reglas):
- ✅ No enfría - Verificación eléctrica básica
- ✅ No enfría - Compresor no arranca
- ✅ No enfría - Termostato defectuoso
- ✅ Pierde agua - Desagüe tapado (DIY)
- ✅ Hace ruido - Vibración/nivelación

#### Lavarropas (5 reglas):
- ✅ No carga agua - Sin suministro
- ✅ No carga agua - Filtro/Electroválvula
- ✅ No desagota - Filtro de bomba
- ✅ No centrifuga - Programador/Correa/Motor
- ✅ Vibra - Tornillos transporte / Desbalanceo

#### Microondas (4 reglas):
- ✅ No calienta - Magnetrón defectuoso
- ✅ Hace chispas - CRÍTICO (riesgo incendio)
- ✅ Plato no gira - Acople roto (DIY)
- ✅ No enciende - Fusible/Interruptor

#### Seguridad (6 reglas):
- ✅ Equipo muy antiguo (>15 años)
- ✅ Alerta riesgo eléctrico
- ✅ Evaluar reemplazo (costo vs reparación)
- ✅ Mantenimiento heladera
- ✅ Mantenimiento lavarropas
- ✅ Mantenimiento microondas

## 🔧 Configuración

### application.properties

```properties
# Configuración CLIPS
clips.enabled=true
clips.command=clips
clips.timeout.seconds=30
```

### Requisitos del Sistema

1. **CLIPS instalado** en el sistema
   - Opción 1: CLIPS nativo (C/C++)
   - Opción 2: CLIPSPy (Python wrapper) - Recomendado
   - Opción 3: JNI wrapper

2. **Verificar instalación:**
   ```bash
   clips --version
   # O
   python -c "import clips; print(clips.__version__)"
   ```

## 🚀 Uso

### Modo Automático (Recomendado)

El sistema intenta usar CLIPS automáticamente. Si CLIPS no está disponible o falla, hace fallback a las reglas Java existentes.

```java
// El InferenceEngine ya está configurado para usar CLIPS automáticamente
diagnosticoService.realizarDiagnostico(casoId);
```

### Modo Manual

```java
@Autowired
private ClipsIntegrationService clipsIntegration;

// Procesar caso con CLIPS
Diagnostico diagnostico = clipsIntegration.procesarCasoConClips(caso, respuestas);
```

## 📝 Notas de Implementación

### Comunicación Java ↔ CLIPS

El sistema usa **CLIPS como proceso externo** vía CLI:
- Crea scripts temporales CLIPS (.clp)
- Ejecuta CLIPS con ProcessBuilder
- Parsea resultados desde archivos de salida
- Limpia archivos temporales automáticamente

### Fallback Automático

Si CLIPS no está disponible:
1. El sistema detecta automáticamente la ausencia
2. Hace fallback a reglas Java existentes
3. Registra warning en logs
4. El sistema continúa funcionando normalmente

### Mapeo de Datos

El `ClipsMapper` convierte:
- **Java → CLIPS**: Caso, Electrodoméstico, Síntoma, Respuestas → Hechos CLIPS
- **CLIPS → Java**: Hechos CLIPS → Diagnostico, Decision, Solucion, OrdenTrabajo

## 🧪 Testing

### Casos de Prueba

Los casos de prueba están en `casos-prueba.clp`:
- Caso 1: Heladera no enfría - Compresor
- Caso 2: Lavarropas no desagota - Filtro
- Caso 3: Microondas hace chispas - CRÍTICO
- Caso 4: Heladera pierde agua - Desagüe (DIY)

### Ejecutar Pruebas

```bash
# Cargar casos de prueba en CLIPS
clips -f casos-prueba.clp

# Ejecutar inferencia
(run)

# Ver hechos generados
(facts)
```

## 🔄 Próximos Pasos

1. **Instalar CLIPS** en el entorno de producción
2. **Validar reglas** con casos reales
3. **Optimizar performance** (caché de reglas, pool de procesos)
4. **Agregar más reglas** según necesidades
5. **Implementar tests** de integración CLIPS

## 📚 Referencias

- Manual CLIPS: http://www.clipsrules.net/
- CLIPSPy: https://github.com/noxdafox/clips
- Documentación del proyecto: `PLAN_DESARROLLO_BACKEND.md`

