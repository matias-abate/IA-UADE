package com.sistemaexperto.service.rules;

import com.sistemaexperto.model.Caso;
import com.sistemaexperto.model.Pregunta;
import com.sistemaexperto.model.Diagnostico;
import com.sistemaexperto.model.enums.TipoElectrodomestico;

import java.util.List;
import java.util.Map;

/**
 * Interfaz base para todas las reglas de diagnóstico
 */
public interface DiagnosticRule {

    /**
     * Obtiene el ID único de la regla
     */
    String getId();

    /**
     * Obtiene el tipo de electrodoméstico al que aplica esta regla
     */
    TipoElectrodomestico getTipoElectrodomestico();

    /**
     * Verifica si esta regla es aplicable al síntoma reportado
     */
    boolean esAplicable(String sintomaReportado);

    /**
     * Obtiene todas las preguntas de esta regla
     */
    List<Pregunta> getPreguntas();

    /**
     * Obtiene la primera pregunta de la secuencia
     */
    Pregunta getPrimeraPregunta();

    /**
     * Obtiene la siguiente pregunta basándose en la respuesta anterior
     */
    Pregunta getSiguientePregunta(String preguntaActualId, Object respuesta, Map<String, Object> todasLasRespuestas);

    /**
     * Evalúa todas las respuestas y genera el diagnóstico final
     */
    Diagnostico evaluarDiagnostico(Map<String, Object> respuestas, Caso caso);

    /**
     * Obtiene el ID string de una pregunta desde su ID numérico
     */
    String getPreguntaIdString(Long preguntaIdNumerico);

    /**
     * Obtiene la prioridad de la regla (mayor valor = mayor prioridad)
     */
    default int getPrioridad() {
        return 0;
    }
}

