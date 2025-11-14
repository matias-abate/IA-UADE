# 🔧 Sistema Experto de Diagnóstico de Electrodomésticos

Sistema experto para diagnosticar problemas en electrodomésticos mediante un proceso de preguntas y respuestas, generando hipótesis y recomendaciones.

## 🚀 Inicio Rápido

### Opción 1: Script Automático (Recomendado)

```bash
./iniciar.sh
```

### Opción 2: Comandos Maven

```bash
# Compilar
mvn clean compile

# Ejecutar
mvn spring-boot:run
```

## 📋 Requisitos Previos

- ☕ Java 17+
- 📦 Maven 3.6+
- 🌐 Puerto 8080 disponible

## 🎯 Funcionalidades

- ✅ Diagnóstico interactivo por preguntas
- ✅ Sistema de hipótesis probabilísticas
- ✅ Recomendaciones personalizadas
- ✅ Estimación de costos y tiempos
- ✅ Base de datos persistente
- ✅ API REST completa

## 🔌 Tipos de Electrodomésticos Soportados

- 🧊 **Heladeras**
- 🧺 **Lavarropas**
- 🍕 **Microondas**

## 📡 Endpoints API

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| GET | `/api/casos` | Listar casos |
| POST | `/api/casos` | Crear caso |
| GET | `/api/casos/{id}` | Ver caso |
| GET | `/api/casos/{id}/siguiente-pregunta` | Obtener pregunta |
| POST | `/api/casos/{id}/responder` | Responder |
| POST | `/api/casos/{id}/finalizar` | Finalizar diagnóstico |

## 💾 Base de Datos

### Configuración
- **Tipo**: H2 (embebida)
- **Modo**: Persistente en archivo
- **Ubicación**: `./data/sistemaexperto.mv.db`
- **Consola**: http://localhost:8080/h2-console

### Credenciales H2 Console
- **JDBC URL**: `jdbc:h2:file:./data/sistemaexperto`
- **Usuario**: `sa`
- **Contraseña**: (vacío)

## 📝 Ejemplo de Uso

### 1. Crear un Caso

```bash
curl -X POST http://localhost:8080/api/casos \
  -H "Content-Type: application/json" \
  -d '{
    "descripcion": "Heladera no enfría",
    "tipoElectrodomestico": "HELADERA",
    "modelo": "Samsung RT35",
    "antiguedad": 3
  }'
```

### 2. Obtener Siguiente Pregunta

```bash
curl http://localhost:8080/api/casos/1/siguiente-pregunta
```

### 3. Responder Pregunta

```bash
curl -X POST http://localhost:8080/api/casos/1/responder \
  -H "Content-Type: application/json" \
  -d '{
    "preguntaId": 1,
    "valor": "si"
  }'
```

### 4. Finalizar Diagnóstico

```bash
curl -X POST http://localhost:8080/api/casos/1/finalizar
```

## 🧪 Pruebas

### Ejecutar tests automáticos:

```bash
./test-api.sh
```

Este script ejecuta un flujo completo de diagnóstico.

## 📚 Documentación

- 📖 [DATABASE.md](DATABASE.md) - Guía completa de base de datos
- 🎯 [INSTRUCCIONES.md](INSTRUCCIONES.md) - Instrucciones paso a paso
- 📊 [RESUMEN_FINAL.md](RESUMEN_FINAL.md) - Resumen de cambios

## 🗂️ Estructura del Proyecto

```
Back/
├── src/main/java/com/sistemaexperto/
│   ├── config/          # Configuraciones
│   │   ├── CorsConfig.java
│   │   └── DataInitializer.java
│   ├── controller/      # Controladores REST
│   │   ├── CasoController.java
│   │   └── MetricasController.java
│   ├── dto/            # Data Transfer Objects
│   │   ├── CasoCreateDTO.java
│   │   ├── CasoDTO.java
│   │   ├── MetricasDTO.java
│   │   └── RespuestaDTO.java
│   ├── model/          # Entidades JPA
│   │   ├── Caso.java
│   │   ├── Diagnostico.java
│   │   ├── Hipotesis.java
│   │   ├── Pregunta.java
│   │   ├── Respuesta.java
│   │   └── enums/
│   ├── repository/     # Repositorios
│   │   ├── CasoRepository.java
│   │   └── RespuestaRepository.java
│   └── service/        # Lógica de negocio
│       ├── CasoService.java
│       ├── DiagnosticoService.java
│       └── InferenceEngine.java
├── src/main/resources/
│   └── application.properties
├── data/               # Base de datos (generada)
├── iniciar.sh         # Script de inicio
├── test-api.sh        # Script de pruebas
└── pom.xml
```

## 🔧 Configuración

### application.properties

```properties
# Servidor
server.port=8080

# Base de Datos H2 (Persistente)
spring.datasource.url=jdbc:h2:file:./data/sistemaexperto
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true

# Consola H2
spring.h2.console.enabled=true
spring.h2.console.path=/h2-console
```

## 🛠️ Tecnologías

- **Spring Boot 3.2.0** - Framework
- **Spring Data JPA** - Persistencia
- **H2 Database** - Base de datos
- **Lombok** - Reducción de código boilerplate
- **Maven** - Gestión de dependencias

## 🐛 Solución de Problemas

### Puerto 8080 en uso

```bash
lsof -ti:8080 | xargs kill -9
```

### Resetear base de datos

```bash
rm -rf data/
./iniciar.sh
```

### Errores de compilación

```bash
mvn clean install -U
```

## 📊 Estado del Proyecto

```
✅ Backend completo
✅ API REST funcional
✅ Base de datos persistente
✅ Motor de inferencia implementado
✅ Sistema de preguntas dinámicas
✅ Generación de hipótesis
✅ Diagnóstico final con recomendaciones
✅ Tests automáticos
✅ Documentación completa
```

## 📈 Características del Motor de Inferencia

- 🧠 **Razonamiento basado en reglas**
- 📊 **Cálculo de probabilidades**
- 🎯 **Diagnóstico personalizado por tipo**
- 💡 **Recomendaciones de DIY vs Técnico**
- 💰 **Estimación de costos**
- ⏱️ **Tiempo estimado de reparación**

## 👥 Datos de Ejemplo

Al iniciar, se crean automáticamente 3 casos de ejemplo:

1. **Caso 1**: Heladera Samsung (3 años)
2. **Caso 2**: Lavarropas LG (5 años)
3. **Caso 3**: Microondas Whirlpool (2 años)

## 🔐 Seguridad

⚠️ **Nota**: Esta configuración es para desarrollo. Para producción:
- Usar base de datos externa (PostgreSQL/MySQL)
- Implementar autenticación y autorización
- Deshabilitar consola H2
- Usar HTTPS

## 📞 Contacto y Soporte

Para más información, consulta la documentación en:
- [DATABASE.md](DATABASE.md)
- [INSTRUCCIONES.md](INSTRUCCIONES.md)

---

## 🎉 ¡Listo para usar!

```bash
./iniciar.sh
```

Visita: http://localhost:8080/api/casos

