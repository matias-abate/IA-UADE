#!/bin/bash

# Colores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Iniciando creación del Sistema Experto...${NC}\n"

# ============================================
# BACKEND - Estructura de carpetas
# ============================================
echo -e "${GREEN}📁 Creando estructura Backend...${NC}"

mkdir -p Back/src/main/java/com/sistemaexperto/model/enums
mkdir -p Back/src/main/java/com/sistemaexperto/service
mkdir -p Back/src/main/java/com/sistemaexperto/controller
mkdir -p Back/src/main/java/com/sistemaexperto/repository
mkdir -p Back/src/main/java/com/sistemaexperto/dto
mkdir -p Back/src/main/java/com/sistemaexperto/config
mkdir -p Back/src/main/resources
mkdir -p Back/src/test/java/com/sistemaexperto

# ============================================
# FRONTEND - Estructura de carpetas
# ============================================
echo -e "${GREEN}📁 Creando estructura Frontend...${NC}"

mkdir -p Front/src/components/Dashboard
mkdir -p Front/src/components/Diagnostic
mkdir -p Front/src/components/Result
mkdir -p Front/src/components/ui
mkdir -p Front/src/services
mkdir -p Front/src/types
mkdir -p Front/src/hooks
mkdir -p Front/public

# ============================================
# BACKEND - Archivos
# ============================================
echo -e "${BLUE}📝 Generando archivos Backend...${NC}"

# pom.xml
cat > Back/pom.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 
         https://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    
    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>3.2.0</version>
        <relativePath/>
    </parent>
    
    <groupId>com.sistemaexperto</groupId>
    <artifactId>sistema-experto</artifactId>
    <version>1.0.0</version>
    <name>Sistema Experto</name>
    
    <properties>
        <java.version>17</java.version>
    </properties>
    
    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-data-jpa</artifactId>
        </dependency>
        <dependency>
            <groupId>com.h2database</groupId>
            <artifactId>h2</artifactId>
            <scope>runtime</scope>
        </dependency>
        <dependency>
            <groupId>org.projectlombok</groupId>
            <artifactId>lombok</artifactId>
            <optional>true</optional>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>
    </dependencies>
    
    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
                <configuration>
                    <excludes>
                        <exclude>
                            <groupId>org.projectlombok</groupId>
                            <artifactId>lombok</artifactId>
                        </exclude>
                    </excludes>
                </configuration>
            </plugin>
        </plugins>
    </build>
</project>
EOF

# application.properties
cat > Back/src/main/resources/application.properties << 'EOF'
spring.application.name=sistema-experto
server.port=8080

# H2 Database
spring.datasource.url=jdbc:h2:mem:testdb
spring.datasource.driverClassName=org.h2.Driver
spring.datasource.username=sa
spring.datasource.password=

# JPA
spring.jpa.database-platform=org.hibernate.dialect.H2Dialect
spring.jpa.hibernate.ddl-auto=create-drop
spring.jpa.show-sql=true

# H2 Console
spring.h2.console.enabled=true
spring.h2.console.path=/h2-console
EOF

# Main Application
cat > Back/src/main/java/com/sistemaexperto/SistemaExpertoApplication.java << 'EOF'
package com.sistemaexperto;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class SistemaExpertoApplication {
    public static void main(String[] args) {
        SpringApplication.run(SistemaExpertoApplication.class, args);
    }
}
EOF

# Enums
cat > Back/src/main/java/com/sistemaexperto/model/enums/TipoElectrodomestico.java << 'EOF'
package com.sistemaexperto.model.enums;

public enum TipoElectrodomestico {
    HELADERA,
    LAVARROPAS,
    MICROONDAS
}
EOF

cat > Back/src/main/java/com/sistemaexperto/model/enums/EstadoCaso.java << 'EOF'
package com.sistemaexperto.model.enums;

public enum EstadoCaso {
    EN_DIAGNOSTICO,
    RESUELTO_DIY,
    REQUIERE_TECNICO,
    CERRADO
}
EOF

cat > Back/src/main/java/com/sistemaexperto/model/enums/Urgencia.java << 'EOF'
package com.sistemaexperto.model.enums;

public enum Urgencia {
    BAJA,
    MEDIA,
    ALTA,
    CRITICA
}
EOF

# Models
cat > Back/src/main/java/com/sistemaexperto/model/Caso.java << 'EOF'
package com.sistemaexperto.model;

import com.sistemaexperto.model.enums.EstadoCaso;
import com.sistemaexperto.model.enums.TipoElectrodomestico;
import jakarta.persistence.*;
import org.hibernate.annotations.CreationTimestamp;
import lombok.*;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "casos")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Caso {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    private String clienteNombre;
    private String clienteTelefono;
    
    @Enumerated(EnumType.STRING)
    private TipoElectrodomestico tipo;
    
    private String marca;
    private String modelo;
    private Integer antiguedad;
    private String sintomaReportado;
    
    @Enumerated(EnumType.STRING)
    private EstadoCaso estado;
    
    @CreationTimestamp
    private LocalDateTime fechaCreacion;
    
    @OneToMany(mappedBy = "caso", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<Respuesta> respuestas = new ArrayList<>();
}
EOF

cat > Back/src/main/java/com/sistemaexperto/model/Respuesta.java << 'EOF'
package com.sistemaexperto.model;

import jakarta.persistence.*;
import org.hibernate.annotations.CreationTimestamp;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "respuestas")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Respuesta {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne
    @JoinColumn(name = "caso_id")
    private Caso caso;
    
    private Long preguntaId;
    private String valor;
    
    @CreationTimestamp
    private LocalDateTime timestamp;
}
EOF

cat > Back/src/main/java/com/sistemaexperto/model/Pregunta.java << 'EOF'
package com.sistemaexperto.model;

import lombok.*;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Pregunta {
    private Long id;
    private String texto;
    private String ayuda;
    private List<String> opciones;
}
EOF

cat > Back/src/main/java/com/sistemaexperto/model/Diagnostico.java << 'EOF'
package com.sistemaexperto.model;

import com.sistemaexperto.model.enums.Urgencia;
import lombok.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Diagnostico {
    private Long casoId;
    private String causaProbable;
    private Integer certeza;
    private String componenteAfectado;
    private Boolean requiereTecnico;
    private Urgencia urgencia;
    private Integer costoMinimo;
    private Integer costoMaximo;
    private Integer tiempoEstimado;
    private Double probabilidadExitoDIY;
    private String scriptCliente;
}
EOF

cat > Back/src/main/java/com/sistemaexperto/model/Hipotesis.java << 'EOF'
package com.sistemaexperto.model;

import lombok.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Hipotesis {
    private String nombre;
    private Integer probabilidad;
    private String nivel;
}
EOF

# DTOs
cat > Back/src/main/java/com/sistemaexperto/dto/CasoDTO.java << 'EOF'
package com.sistemaexperto.dto;

import com.sistemaexperto.model.enums.TipoElectrodomestico;
import lombok.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class CasoDTO {
    private String clienteNombre;
    private String clienteTelefono;
    private TipoElectrodomestico tipo;
    private String marca;
    private String modelo;
    private Integer antiguedad;
    private String sintomaReportado;
}
EOF

cat > Back/src/main/java/com/sistemaexperto/dto/RespuestaDTO.java << 'EOF'
package com.sistemaexperto.dto;

import lombok.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class RespuestaDTO {
    private Long preguntaId;
    private String valor;
}
EOF

cat > Back/src/main/java/com/sistemaexperto/dto/MetricasDTO.java << 'EOF'
package com.sistemaexperto.dto;

import lombok.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class MetricasDTO {
    private Long casosTotales;
    private Long diyExitosos;
    private Long tecnicoEnviados;
    private Double tiempoPromedio;
}
EOF

# Repositories
cat > Back/src/main/java/com/sistemaexperto/repository/CasoRepository.java << 'EOF'
package com.sistemaexperto.repository;

import com.sistemaexperto.model.Caso;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface CasoRepository extends JpaRepository<Caso, Long> {
    @Query("SELECT c FROM Caso c WHERE DATE(c.fechaCreacion) = CURRENT_DATE")
    List<Caso> findByFechaCreacionToday();
}
EOF

cat > Back/src/main/java/com/sistemaexperto/repository/RespuestaRepository.java << 'EOF'
package com.sistemaexperto.repository;

import com.sistemaexperto.model.Respuesta;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface RespuestaRepository extends JpaRepository<Respuesta, Long> {
}
EOF

echo -e "${YELLOW}⚙️  Generando InferenceEngine.java (archivo grande)...${NC}"

# InferenceEngine - Service principal (archivo grande, lo divido)
cat > Back/src/main/java/com/sistemaexperto/service/InferenceEngine.java << 'EOF'
package com.sistemaexperto.service;

import com.sistemaexperto.model.*;
import com.sistemaexperto.model.enums.TipoElectrodomestico;
import com.sistemaexperto.model.enums.Urgencia;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.stream.Collectors;

@Service
public class InferenceEngine {
    
    public Pregunta getSiguientePregunta(Caso caso, List<Respuesta> respuestas) {
        if (respuestas.isEmpty()) {
            return getPrimeraPregunta(caso.getTipo());
        }
        
        if (caso.getTipo() == TipoElectrodomestico.HELADERA) {
            return siguientePreguntaHeladera(respuestas);
        } else if (caso.getTipo() == TipoElectrodomestico.LAVARROPAS) {
            return siguientePreguntaLavarropas(respuestas);
        } else if (caso.getTipo() == TipoElectrodomestico.MICROONDAS) {
            return siguientePreguntaMicroondas(respuestas);
        }
        
        return null;
    }
    
    private Pregunta getPrimeraPregunta(TipoElectrodomestico tipo) {
        switch (tipo) {
            case HELADERA:
                return new Pregunta(1L, "¿La luz interior funciona?", 
                    "Esto nos indica si hay alimentación eléctrica", 
                    List.of("si", "no", "no_sabe"));
            case LAVARROPAS:
                return new Pregunta(1L, "¿El lavarropas enciende normalmente?",
                    "Verificamos si hay problema eléctrico general",
                    List.of("si", "no", "no_sabe"));
            case MICROONDAS:
                return new Pregunta(1L, "¿La luz interior y el plato funcionan?",
                    "Verificamos componentes básicos",
                    List.of("si", "no", "no_sabe"));
            default:
                return null;
        }
    }
    
    private Pregunta siguientePreguntaHeladera(List<Respuesta> respuestas) {
        Respuesta luzFunciona = findRespuesta(respuestas, 1L);
        
        if (luzFunciona != null && "si".equals(luzFunciona.getValor())) {
            if (respuestas.size() == 1) {
                return new Pregunta(2L, "¿Escucha el motor funcionando?",
                    "El compresor hace un zumbido característico",
                    List.of("si", "no", "no_sabe"));
            }
            
            Respuesta motorFunciona = findRespuesta(respuestas, 2L);
            if (motorFunciona != null && "no".equals(motorFunciona.getValor())) {
                if (respuestas.size() == 2) {
                    return new Pregunta(3L, "¿El motor está caliente al tacto?",
                        "Toque con cuidado la parte trasera inferior",
                        List.of("si", "no", "no_sabe"));
                }
            }
        }
        
        return null;
    }
    
    private Pregunta siguientePreguntaLavarropas(List<Respuesta> respuestas) {
        Respuesta enciende = findRespuesta(respuestas, 1L);
        
        if (enciende != null && "si".equals(enciende.getValor())) {
            if (respuestas.size() == 1) {
                return new Pregunta(2L, "¿Carga agua correctamente?",
                    "Verificar si el agua entra al tambor",
                    List.of("si", "no", "no_sabe"));
            }
        }
        
        return null;
    }
    
    private Pregunta siguientePreguntaMicroondas(List<Respuesta> respuestas) {
        Respuesta luzPlato = findRespuesta(respuestas, 1L);
        
        if (luzPlato != null && "si".equals(luzPlato.getValor())) {
            if (respuestas.size() == 1) {
                return new Pregunta(2L, "¿Calienta la comida?",
                    "Pruebe con un vaso de agua por 1 minuto",
                    List.of("si", "no", "no_sabe"));
            }
        }
        
        return null;
    }
    
    public Diagnostico generarDiagnostico(Caso caso, List<Respuesta> respuestas) {
        Diagnostico diag = new Diagnostico();
        diag.setCasoId(caso.getId());
        
        if (caso.getTipo() == TipoElectrodomestico.HELADERA) {
            diagnosticarHeladera(caso, respuestas, diag);
        } else if (caso.getTipo() == TipoElectrodomestico.LAVARROPAS) {
            diagnosticarLavarropas(caso, respuestas, diag);
        } else if (caso.getTipo() == TipoElectrodomestico.MICROONDAS) {
            diagnosticarMicroondas(caso, respuestas, diag);
        }
        
        return diag;
    }
    
    private void diagnosticarHeladera(Caso caso, List<Respuesta> respuestas, Diagnostico diag) {
        Respuesta luz = findRespuesta(respuestas, 1L);
        Respuesta motor = findRespuesta(respuestas, 2L);
        
        if (luz != null && "no".equals(luz.getValor())) {
            diag.setCausaProbable("Problema eléctrico - Sin alimentación");
            diag.setCerteza(90);
            diag.setComponenteAfectado("Circuito eléctrico");
            diag.setRequiereTecnico(false);
            diag.setUrgencia(Urgencia.MEDIA);
            diag.setCostoMinimo(0);
            diag.setCostoMaximo(0);
            diag.setTiempoEstimado(10);
            diag.setProbabilidadExitoDIY(0.95);
            diag.setScriptCliente("Verificar enchufe y fusibles del tablero.");
        } else if (motor != null && "no".equals(motor.getValor())) {
            diag.setCausaProbable("Compresor defectuoso");
            diag.setCerteza(85);
            diag.setComponenteAfectado("Compresor");
            diag.setRequiereTecnico(true);
            diag.setUrgencia(Urgencia.ALTA);
            diag.setCostoMinimo(80000);
            diag.setCostoMaximo(150000);
            diag.setTiempoEstimado(180);
            diag.setProbabilidadExitoDIY(0.15);
            diag.setScriptCliente("Requiere técnico especializado.");
        }
    }
    
    private void diagnosticarLavarropas(Caso caso, List<Respuesta> respuestas, Diagnostico diag) {
        diag.setCausaProbable("Diagnóstico básico");
        diag.setCerteza(70);
        diag.setRequiereTecnico(true);
        diag.setUrgencia(Urgencia.MEDIA);
    }
    
    private void diagnosticarMicroondas(Caso caso, List<Respuesta> respuestas, Diagnostico diag) {
        diag.setCausaProbable("Diagnóstico básico");
        diag.setCerteza(70);
        diag.setRequiereTecnico(true);
        diag.setUrgencia(Urgencia.MEDIA);
    }
    
    public List<Hipotesis> calcularHipotesis(Caso caso, List<Respuesta> respuestas) {
        List<Hipotesis> hipotesis = new ArrayList<>();
        
        if (caso.getTipo() == TipoElectrodomestico.HELADERA) {
            hipotesis.add(new Hipotesis("Compresor defectuoso", 30, "media"));
            hipotesis.add(new Hipotesis("Termostato", 25, "media"));
            hipotesis.add(new Hipotesis("Problema eléctrico", 20, "baja"));
        }
        
        return hipotesis;
    }
    
    private Respuesta findRespuesta(List<Respuesta> respuestas, Long preguntaId) {
        return respuestas.stream()
            .filter(r -> r.getPreguntaId().equals(preguntaId))
            .findFirst()
            .orElse(null);
    }
}
EOF

# CasoService
cat > Back/src/main/java/com/sistemaexperto/service/CasoService.java << 'EOF'
package com.sistemaexperto.service;

import com.sistemaexperto.dto.CasoDTO;
import com.sistemaexperto.dto.RespuestaDTO;
import com.sistemaexperto.model.Caso;
import com.sistemaexperto.model.Respuesta;
import com.sistemaexperto.model.enums.EstadoCaso;
import com.sistemaexperto.repository.CasoRepository;
import com.sistemaexperto.repository.RespuestaRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Service
public class CasoService {
    
    @Autowired
    private CasoRepository casoRepository;
    
    @Autowired
    private RespuestaRepository respuestaRepository;
    
    @Transactional
    public Caso crearCaso(CasoDTO dto) {
        Caso caso = new Caso();
        caso.setClienteNombre(dto.getClienteNombre());
        caso.setClienteTelefono(dto.getClienteTelefono());
        caso.setTipo(dto.getTipo());
        caso.setMarca(dto.getMarca());
        caso.setModelo(dto.getModelo());
        caso.setAntiguedad(dto.getAntiguedad());
        caso.setSintomaReportado(dto.getSintomaReportado());
        caso.setEstado(EstadoCaso.EN_DIAGNOSTICO);
        
        return casoRepository.save(caso);
    }
    
    public Optional<Caso> findById(Long id) {
        return casoRepository.findById(id);
    }
    
    public List<Caso> findAll() {
        return casoRepository.findAll();
    }
    
    public List<Caso> findByFecha(LocalDate fecha) {
        return casoRepository.findByFechaCreacionToday();
    }
    
    @Transactional
    public void agregarRespuesta(Long casoId, RespuestaDTO dto) {
        Caso caso = casoRepository.findById(casoId)
            .orElseThrow(() -> new RuntimeException("Caso no encontrado"));
        
        Respuesta respuesta = new Respuesta();
        respuesta.setCaso(caso);
        respuesta.setPreguntaId(dto.getPreguntaId());
        respuesta.setValor(dto.getValor());
        
        respuestaRepository.save(respuesta);
    }
    
    @Transactional
    public Caso save(Caso caso) {
        return casoRepository.save(caso);
    }
}
EOF

# Controllers
cat > Back/src/main/java/com/sistemaexperto/controller/CasoController.java << 'EOF'
package com.sistemaexperto.controller;

import com.sistemaexperto.dto.CasoDTO;
import com.sistemaexperto.dto.RespuestaDTO;
import com.sistemaexperto.model.*;
import com.sistemaexperto.model.enums.EstadoCaso;
import com.sistemaexperto.service.CasoService;
import com.sistemaexperto.service.InferenceEngine;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/casos")
@CrossOrigin(origins = "*")
public class CasoController {
    
    @Autowired
    private CasoService casoService;
    
    @Autowired
    private InferenceEngine inferenceEngine;
    
    @PostMapping
    public ResponseEntity<Caso> crearCaso(@RequestBody CasoDTO dto) {
        Caso caso = casoService.crearCaso(dto);
        return ResponseEntity.ok(caso);
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<Caso> getCaso(@PathVariable Long id) {
        return casoService.findById(id)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }
    
    @GetMapping("/{id}/siguiente-pregunta")
    public ResponseEntity<Pregunta> getSiguientePregunta(@PathVariable Long id) {
        Caso caso = casoService.findById(id)
            .orElseThrow(() -> new RuntimeException("Caso no encontrado"));
        
        Pregunta pregunta = inferenceEngine.getSiguientePregunta(caso, caso.getRespuestas());
        
        if (pregunta == null) {
            return ResponseEntity.noContent().build();
        }
        
        return ResponseEntity.ok(pregunta);
    }
    
    @PostMapping("/{id}/responder")
    public ResponseEntity<Void> responderPregunta(
        @PathVariable Long id,
        @RequestBody RespuestaDTO dto
    ) {
        casoService.agregarRespuesta(id, dto);
        return ResponseEntity.ok().build();
    }
    
    @GetMapping("/{id}/hipotesis")
    public ResponseEntity<List<Hipotesis>> getHipotesis(@PathVariable Long id) {
        Caso caso = casoService.findById(id)
            .orElseThrow(() -> new RuntimeException("Caso no encontrado"));
        
        List<Hipotesis> hipotesis = inferenceEngine.calcularHipotesis(caso, caso.getRespuestas());
        return ResponseEntity.ok(hipotesis);
    }
    
    @PostMapping("/{id}/finalizar")
    public ResponseEntity<Diagnostico> finalizarDiagnostico(@PathVariable Long id) {
        Caso caso = casoService.findById(id)
            .orElseThrow(() -> new RuntimeException("Caso no encontrado"));
        
        Diagnostico diagnostico = inferenceEngine.generarDiagnostico(caso, caso.getRespuestas());
        
        if (diagnostico.getRequiereTecnico()) {
            caso.setEstado(EstadoCaso.REQUIERE_TECNICO);
        } else {
            caso.setEstado(EstadoCaso.RESUELTO_DIY);
        }
        casoService.save(caso);
        
        return ResponseEntity.ok(diagnostico);
    }
    
    @GetMapping
    public ResponseEntity<List<Caso>> listarCasos() {
        return ResponseEntity.ok(casoService.findAll());
    }
}
EOF

cat > Back/src/main/java/com/sistemaexperto/controller/MetricasController.java << 'EOF'
package com.sistemaexperto.controller;

import com.sistemaexperto.dto.MetricasDTO;
import com.sistemaexperto.model.Caso;
import com.sistemaexperto.model.enums.EstadoCaso;
import com.sistemaexperto.service.CasoService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/api/metricas")
@CrossOrigin(origins = "*")
public class MetricasController {
    
    @Autowired
    private CasoService casoService;
    
    @GetMapping
    public ResponseEntity<MetricasDTO> getMetricas() {
        List<Caso> casosHoy = casoService.findByFecha(LocalDate.now());
        
        long total = casosHoy.size();
        long diyExitosos = casosHoy.stream()
            .filter(c -> c.getEstado() == EstadoCaso.RESUELTO_DIY)
            .count();
        long tecnicoEnviados = casosHoy.stream()
            .filter(c -> c.getEstado() == EstadoCaso.REQUIERE_TECNICO)
            .count();
        
        MetricasDTO metricas = new MetricasDTO();
        metricas.setCasosTotales(total);
        metricas.setDiyExitosos(diyExitosos);
        metricas.setTecnicoEnviados(tecnicoEnviados);
        metricas.setTiempoPromedio(4.2);
        
        return ResponseEntity.ok(metricas);
    }
}
EOF

# Config
cat > Back/src/main/java/com/sistemaexperto/config/CorsConfig.java << 'EOF'
package com.sistemaexperto.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class CorsConfig {
    
    @Bean
    public WebMvcConfigurer corsConfigurer() {
        return new WebMvcConfigurer() {
            @Override
            public void addCorsMappings(CorsRegistry registry) {
                registry.addMapping("/api/**")
                        .allowedOrigins("http://localhost:5173", "http://localhost:3000")
                        .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS")
                        .allowedHeaders("*")
                        .allowCredentials(true);
            }
        };
    }
}
EOF

echo -e "${GREEN}✅ Backend completo generado!${NC}\n"

# ============================================
# FRONTEND - Archivos
# ============================================
echo -e "${BLUE}📝 Generando archivos Frontend...${NC}"

# package.json
cat > Front/package.json << 'EOF'
{
  "name": "sistema-experto-frontend",
  "version": "1.0.0",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "tsc && vite build",
    "preview": "vite preview"
  },
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-router-dom": "^6.20.0",
    "axios": "^1.6.2",
    "framer-motion": "^10.16.16",
    "lucide-react": "^0.294.0",
    "class-variance-authority": "^0.7.0",
    "clsx": "^2.0.0",
    "tailwind-merge": "^2.2.0"
  },
  "devDependencies": {
    "@types/react": "^18.2.43",
    "@types/react-dom": "^18.2.17",
    "@vitejs/plugin-react": "^4.2.1",
    "typescript": "^5.3.3",
    "vite": "^5.0.8",
    "tailwindcss": "^3.4.0",
    "autoprefixer": "^10.4.16",
    "postcss": "^8.4.32"
  }
}
EOF

# tsconfig.json
cat > Front/tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "target": "ES2020",
    "useDefineForClassFields": true,
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "skipLibCheck": true,
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "jsx": "react-jsx",
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noFallthroughCasesInSwitch": true,
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"]
    }
  },
  "include": ["src"],
  "references": [{ "path": "./tsconfig.node.json" }]
}
EOF

# vite.config.ts
cat > Front/vite.config.ts << 'EOF'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import path from 'path'

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
    },
  },
})
EOF

# tailwind.config.js
cat > Front/tailwind.config.js << 'EOF'
/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {},
  },
  plugins: [],
}
EOF

# postcss.config.js
cat > Front/postcss.config.js << 'EOF'
export default {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
}
EOF

# index.html
cat > Front/index.html << 'EOF'
<!doctype html>
<html lang="es">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Sistema Experto - Diagnóstico</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.tsx"></script>
  </body>
</html>
EOF

# src/index.css
cat > Front/src/index.css << 'EOF'
@tailwind base;
@tailwind components;
@tailwind utilities;

body {
  margin: 0;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', sans-serif;
  -webkit-font-smoothing: antialiased;
}
EOF

# src/types/index.ts
cat > Front/src/types/index.ts << 'EOF'
export enum TipoElectrodomestico {
  HELADERA = 'HELADERA',
  LAVARROPAS = 'LAVARROPAS',
  MICROONDAS = 'MICROONDAS'
}

export enum EstadoCaso {
  EN_DIAGNOSTICO = 'EN_DIAGNOSTICO',
  RESUELTO_DIY = 'RESUELTO_DIY',
  REQUIERE_TECNICO = 'REQUIERE_TECNICO',
  CERRADO = 'CERRADO'
}

export interface Caso {
  id: number;
  clienteNombre: string;
  clienteTelefono: string;
  tipo: TipoElectrodomestico;
  marca: string;
  modelo: string;
  antiguedad: number;
  sintomaReportado: string;
  estado: EstadoCaso;
  fechaCreacion: string;
}

export interface Pregunta {
  id: number;
  texto: string;
  ayuda: string;
  opciones: string[];
}

export interface Diagnostico {
  casoId: number;
  causaProbable: string;
  certeza: number;
  componenteAfectado: string;
  requiereTecnico: boolean;
  costoMinimo: number;
  costoMaximo: number;
  scriptCliente: string;
}
EOF

# src/services/api.ts
cat > Front/src/services/api.ts << 'EOF'
import axios from 'axios';

const API_URL = 'http://localhost:8080/api';

const api = axios.create({
  baseURL: API_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

export const casoApi = {
  crear: (data: any) => api.post('/casos', data),
  obtener: (id: number) => api.get(`/casos/${id}`),
  listar: () => api.get('/casos'),
  getSiguientePregunta: (id: number) => api.get(`/casos/${id}/siguiente-pregunta`),
  responder: (id: number, preguntaId: number, valor: string) => 
    api.post(`/casos/${id}/responder`, { preguntaId, valor }),
  finalizar: (id: number) => api.post(`/casos/${id}/finalizar`),
};

export default api;
EOF

# src/main.tsx
cat > Front/src/main.tsx << 'EOF'
import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App'
import './index.css'

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
)
EOF

# src/App.tsx
cat > Front/src/App.tsx << 'EOF'
import React from 'react';
import { BrowserRouter, Routes, Route } from 'react-router-dom';

function App() {
  return (
    <BrowserRouter>
      <div className="min-h-screen bg-gray-50">
        <Routes>
          <Route path="/" element={
            <div className="flex items-center justify-center h-screen">
              <div className="text-center">
                <h1 className="text-4xl font-bold mb-4">Sistema Experto</h1>
                <p className="text-gray-600">Proyecto creado exitosamente ✅</p>
                <p className="text-sm text-gray-500 mt-2">
                  Ejecuta: cd Front && npm install && npm run dev
                </p>
              </div>
            </div>
          } />
        </Routes>
      </div>
    </BrowserRouter>
  );
}

export default App;
EOF

# tsconfig.node.json
cat > Front/tsconfig.node.json << 'EOF'
{
  "compilerOptions": {
    "composite": true,
    "skipLibCheck": true,
    "module": "ESNext",
    "moduleResolution": "bundler",
    "allowSyntheticDefaultImports": true
  },
  "include": ["vite.config.ts"]
}
EOF

# .gitignore
cat > Front/.gitignore << 'EOF'
node_modules
dist
.env
.DS_Store
EOF

cat > Back/.gitignore << 'EOF'
target/
.mvn/
.idea/
*.iml
.DS_Store
EOF

echo -e "${GREEN}✅ Frontend completo generado!${NC}\n"

# ============================================
# README
# ============================================
cat > README.md << 'EOF'
# Sistema Experto de Diagnóstico

## 🚀 Estructura del Proyecto
