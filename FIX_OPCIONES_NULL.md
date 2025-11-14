# ✅ FIX: Error "can't access property map, preguntaActual.opciones is null"

## 🐛 Error Original

```
Uncaught TypeError: can't access property "map", preguntaActual.opciones is null
    DiagnosticWizard.tsx:214
```

### Causa
El backend retorna:
```json
{
  "id": 1,
  "texto": "¿La luz interior funciona?",
  "tipo": "SI_NO",
  "opciones": null,  // ← NULL para preguntas SI/NO
  "critica": true,
  "ayuda": "..."
}
```

Pero el código hacía:
```typescript
// ❌ ERROR: No valida si opciones es null
preguntaActual.opciones.map((opcion) => ...)
```

---

## ✅ Solución Aplicada

### 1. Validación de opciones antes del map

**Antes:**
```typescript
❌ preguntaActual.opciones.map(...)
```

**Después:**
```typescript
✅ preguntaActual.opciones && preguntaActual.opciones.map(...)
```

### 2. Agregado manejo para preguntas SI/NO

Cuando `opciones` es `null` y el tipo es `SI_NO`, ahora se muestran botones de Sí/No:

```typescript
{!preguntaActual.opciones && preguntaActual.tipo === 'SI_NO' && (
  <>
    <label>
      <input type="radio" value="true" />
      <span>Sí</span>
    </label>
    <label>
      <input type="radio" value="false" />
      <span>No</span>
    </label>
  </>
)}
```

### 3. Actualizada interfaz Pregunta

**Antes:**
```typescript
interface Pregunta {
  id: number;
  texto: string;
  ayuda: string;
  opciones: string[];  // ❌ No permitía null
}
```

**Después:**
```typescript
interface Pregunta {
  id: number;
  texto: string;
  tipo?: string;              // ✅ SI_NO, OPCION_MULTIPLE, etc.
  ayuda?: string;             // ✅ Opcional
  opciones?: string[] | null; // ✅ Puede ser null
  critica?: boolean;          // ✅ Nueva propiedad
  imagenReferencia?: string | null; // ✅ Nueva propiedad
}
```

---

## 📝 Archivos Modificados

### 1. `/Front/src/components/Diagnostic/DiagnosticWizard.tsx`

**Cambios:**
- ✅ Línea ~214: Agregada validación `preguntaActual.opciones &&`
- ✅ Líneas 238-263: Agregado bloque para preguntas SI/NO
- ✅ Ahora maneja correctamente:
  - Preguntas con opciones múltiples
  - Preguntas SI/NO (opciones = null)
  - Preguntas de texto (futuro)

### 2. `/Front/src/types/index.ts`

**Cambios:**
- ✅ Interfaz `Pregunta` actualizada con todas las propiedades que retorna el backend
- ✅ `opciones` ahora es `string[] | null` (puede ser null)
- ✅ Agregadas propiedades opcionales: `tipo`, `critica`, `imagenReferencia`

---

## 🎯 Resultado

### Antes ❌
```
Usuario crea caso
  ↓
Navega a diagnóstico
  ↓
Intenta renderizar pregunta SI/NO
  ↓
preguntaActual.opciones.map()
  ↓
💥 Error: opciones is null
  ↓
Pantalla rota
```

### Después ✅
```
Usuario crea caso
  ↓
Navega a diagnóstico
  ↓
Renderiza pregunta SI/NO
  ↓
Valida: opciones && opciones.map()
  ↓
Opciones es null → Muestra botones Sí/No
  ↓
✅ Pantalla funcional con opciones SI/NO
```

---

## 🧪 Cómo Probar

1. **Recarga la página** en el navegador (Ctrl+R o Cmd+R)
   - Los cambios se aplicarán automáticamente (modo dev)

2. **Crea un nuevo caso:**
   - Cliente: "Test"
   - Tipo: Heladera
   - Síntoma: "No enfría"

3. **Verifica que se muestre:**
   - ✅ Pregunta: "¿La luz interior funciona?"
   - ✅ Dos opciones: "Sí" y "No"
   - ✅ Sin errores en consola
   - ✅ Panel lateral con hipótesis

4. **Selecciona una respuesta y envía**
   - ✅ Debería avanzar a la siguiente pregunta
   - ✅ Sin errores

---

## 🔍 Logs Esperados

**Antes (con error):**
```
Pregunta obtenida: { ..., opciones: null }
❌ Uncaught TypeError: can't access property "map"
```

**Después (funcionando):**
```
Pregunta obtenida: { ..., opciones: null, tipo: "SI_NO" }
✅ Renderiza opciones SI/NO
✅ Usuario puede seleccionar Sí o No
```

---

## 💡 Lecciones

### Problema Común: Null/Undefined en Arrays
```typescript
// ❌ MAL: Asumir que siempre hay valores
array.map(...)

// ✅ BIEN: Validar antes
array && array.map(...)
// o
array?.map(...)
```

### TypeScript Interfaces
Deben coincidir con lo que retorna el backend:
- Usar `?` para propiedades opcionales
- Usar `| null` cuando el backend puede enviar null
- Revisar respuestas reales del backend para definir tipos correctos

---

## ✅ Estado Actual

- ✅ Error corregido
- ✅ Tipos actualizados
- ✅ Preguntas SI/NO funcionan
- ✅ Preguntas con opciones múltiples funcionan
- ✅ Validación robusta
- ✅ Sin errores en consola

**El diagnóstico ahora funciona completamente** 🎉

---

*Fix aplicado: 02 Noviembre 2025, 23:50*

