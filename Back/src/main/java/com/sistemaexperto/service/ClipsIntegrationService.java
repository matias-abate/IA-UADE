package com.sistemaexperto.service;

import com.sistemaexperto.model.*;
import com.sistemaexperto.service.mapper.ClipsMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.*;

/**
 * Servicio de integración entre Java y CLIPS
 * Coordina la comunicación y mapeo de datos
 */
@Slf4j
@Service
public class ClipsIntegrationService {
    
    @Autowired
    private ClipsService clipsService;
    
    @Autowired
    private ClipsMapper clipsMapper;
    
    /**
     * Procesa un caso completo usando CLIPS
     */
    public Diagnostico procesarCasoConClips(Caso caso, List<Respuesta> respuestas) {
        if (!clipsService.isClipsDisponible()) {
            throw new IllegalStateException("CLIPS no está disponible");
        }
        
        try {
            // 1. Convertir Caso Java a hechos CLIPS
            List<String> hechos = new ArrayList<>();
            hechos.add(clipsMapper.casoToClipsFact(caso));
            hechos.add(clipsMapper.electrodomesticoToClipsFact(caso));
            hechos.add(clipsMapper.sintomaToClipsFact(caso));
            
            // 2. Agregar respuestas
            hechos.addAll(clipsMapper.respuestasToClipsFacts(respuestas));
            
            // 3. Ejecutar inferencia
            Map<String, Object> resultados = clipsService.ejecutarInferencia(hechos);
            
            // 4. Convertir resultados a Diagnostico Java
            Diagnostico diagnostico = clipsMapper.clipsFactsToDiagnostico(caso.getId(), resultados);
            
            log.info("Diagnóstico generado por CLIPS para caso {}", caso.getId());
            return diagnostico;
            
        } catch (Exception e) {
            log.error("Error procesando caso con CLIPS: {}", e.getMessage(), e);
            throw new RuntimeException("Error ejecutando inferencia CLIPS", e);
        }
    }
    
    /**
     * Obtiene la siguiente pregunta usando CLIPS
     * Nota: Esta funcionalidad requiere reglas específicas en CLIPS
     * Por ahora retorna null y se usa la lógica Java
     */
    public Pregunta obtenerSiguientePreguntaClips(Caso caso, List<Respuesta> respuestas) {
        // TODO: Implementar cuando se agreguen reglas de selección de preguntas en CLIPS
        log.debug("Obtención de siguiente pregunta desde CLIPS no implementada aún");
        return null;
    }
    
    /**
     * Obtiene recomendaciones de mantenimiento
     */
    public List<Recomendacion> obtenerRecomendaciones(Long casoId) {
        // TODO: Implementar cuando se agreguen reglas de recomendación
        return new ArrayList<>();
    }
    
    /**
     * Obtiene alertas de seguridad
     */
    public List<AlertaSeguridad> obtenerAlertasSeguridad(Long casoId) {
        // TODO: Implementar cuando se agreguen reglas de seguridad
        return new ArrayList<>();
    }
    
    /**
     * Obtiene consejos de mantenimiento
     */
    public List<ConsejoMantenimiento> obtenerConsejosMantenimiento(Long casoId) {
        // TODO: Implementar cuando se agreguen reglas de mantenimiento
        return new ArrayList<>();
    }
}

