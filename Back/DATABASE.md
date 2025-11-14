# Sistema Experto - Guía de Base de Datos

## Configuración de Base de Datos

El proyecto usa **H2 Database** (base de datos embebida en Java) con persistencia en archivo.

### Características:
- ✅ **Persistente**: Los datos se guardan en `./data/sistemaexperto.mv.db`
- ✅ **Datos de ejemplo**: Se crean automáticamente 3 casos al iniciar
- ✅ **Consola H2**: Accesible para inspeccionar datos

---

## Cómo Compilar y Ejecutar

### Opción 1: Desde Terminal (Recomendado)

```bash
# 1. Limpiar y compilar
mvn clean compile

# 2. Ejecutar la aplicación
mvn spring-boot:run
```

### Opción 2: Desde IntelliJ IDEA

1. Abrir el proyecto en IntelliJ
2. Click derecho en `SistemaExpertoApplication.java`
3. Seleccionar "Run 'SistemaExpertoApplication'"

---

## Acceder a la Base de Datos

### Consola H2 (Interfaz Web)

Una vez que la aplicación esté corriendo:

1. Abrir navegador en: http://localhost:8080/h2-console

2. Configurar conexión:
   - **JDBC URL**: `jdbc:h2:file:./data/sistemaexperto`
   - **User Name**: `sa`
   - **Password**: (dejar vacío)

3. Click en "Connect"

### Consultas SQL de Ejemplo

```sql
-- Ver todos los casos
SELECT * FROM CASOS;

-- Ver casos con respuestas
SELECT c.*, r.* FROM CASOS c 
LEFT JOIN RESPUESTAS r ON c.ID = r.CASO_ID;

-- Contar casos por estado
SELECT ESTADO, COUNT(*) FROM CASOS GROUP BY ESTADO;
```

---

## Verificar que los Casos se Guardan

### 1. Iniciar la aplicación:
```bash
mvn spring-boot:run
```

Deberías ver en los logs:
```
=== Inicializando Base de Datos ===
Casos existentes en BD: 0
Creando casos de ejemplo...
Caso 1 creado: 1
Caso 2 creado: 2
Caso 3 creado: 3
=== 3 casos de ejemplo creados exitosamente ===
```

### 2. Probar el API:

```bash
# Listar todos los casos
curl http://localhost:8080/api/casos

# Crear un nuevo caso
curl -X POST http://localhost:8080/api/casos \
  -H "Content-Type: application/json" \
  -d '{
    "descripcion": "Heladera hace ruido",
    "tipoElectrodomestico": "HELADERA",
    "modelo": "ABC123",
    "antiguedad": 2
  }'

# Obtener caso por ID
curl http://localhost:8080/api/casos/1
```

### 3. Detener y reiniciar:

```bash
# Detener: Ctrl + C
# Reiniciar: mvn spring-boot:run
```

Los datos deberían **persistir** entre reinicios.

---

## Ubicación de Archivos de BD

```
/Users/matiasabate/Documents/IA/Back/
├── data/
│   ├── sistemaexperto.mv.db      # Base de datos principal
│   └── sistemaexperto.trace.db   # Logs de H2
```

---

## Resetear la Base de Datos

Si quieres empezar desde cero:

```bash
# Detener la aplicación primero
rm -rf data/

# Reiniciar - se recreará automáticamente
mvn spring-boot:run
```

---

## Endpoints API Disponibles

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| GET | `/api/casos` | Listar todos los casos |
| GET | `/api/casos/{id}` | Obtener caso por ID |
| POST | `/api/casos` | Crear nuevo caso |
| GET | `/api/casos/{id}/siguiente-pregunta` | Siguiente pregunta |
| POST | `/api/casos/{id}/responder` | Enviar respuesta |
| GET | `/api/casos/{id}/hipotesis` | Ver hipótesis actuales |
| POST | `/api/casos/{id}/finalizar` | Finalizar diagnóstico |

---

## Solución de Problemas

### "Los casos no se guardan"
✅ **Solucionado**: Cambiado de `jdbc:h2:mem` a `jdbc:h2:file` con `ddl-auto=update`

### "Base de datos bloqueada"
```bash
# Asegúrate de que solo una instancia esté corriendo
pkill -f spring-boot
mvn spring-boot:run
```

### "No encuentro el archivo de BD"
El archivo se crea automáticamente en `./data/` la primera vez que ejecutas la app.

---

## Configuración (application.properties)

```properties
# Persistencia en archivo (NO en memoria)
spring.datasource.url=jdbc:h2:file:./data/sistemaexperto

# Actualizar esquema sin borrar datos
spring.jpa.hibernate.ddl-auto=update

# Ver consultas SQL en consola
spring.jpa.show-sql=true
spring.jpa.properties.hibernate.format_sql=true

# Habilitar consola H2
spring.h2.console.enabled=true
spring.h2.console.path=/h2-console
```

