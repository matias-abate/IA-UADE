package com.sistemaexperto.service;

import com.sistemaexperto.model.*;
import com.sistemaexperto.repository.CasoRepository;
import com.sistemaexperto.repository.DiagnosticoRepository;
import com.sistemaexperto.repository.HipotesisRepository;
import com.sistemaexperto.repository.RespuestaRepository;
import com.sistemaexperto.service.rules.DiagnosticRule;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;
import java.util.stream.Collectors;

/**
 * Motor de Inferencia - Sistema Experto de Diagnóstico
 * Implementa la lógica de razonamiento basado en reglas
 */
@Slf4j
@Service
public class InferenceEngine {

    @Autowired
    private CasoRepository casoRepository;

    @Autowired
    private RespuestaRepository respuestaRepository;

    @Autowired
    private HipotesisRepository hipotesisRepository;

    @Autowired
    private DiagnosticoRepository diagnosticoRepository;

    @Autowired
    private List<DiagnosticRule> todasLasReglas;

    @Autowired(required = false)
    private ClipsIntegrationService clipsIntegration;

    private Map<Long, DiagnosticRule> reglasActivas = new HashMap<>();
    private Map<Long, Map<String, Object>> respuestasPorCaso = new HashMap<>();
    private Map<Long, String> ultimaPreguntaPorCaso = new HashMap<>();

    /**
     * Obtiene la siguiente pregunta para un caso
     */
    @Transactional(readOnly = true)
    public Pregunta obtenerSiguientePregunta(Caso caso) {
        log.info("Obteniendo siguiente pregunta para caso {}", caso.getId());

        // Si es la primera vez, seleccionar la regla aplicable
        if (!reglasActivas.containsKey(caso.getId())) {
            DiagnosticRule regla = seleccionarReglaAplicable(caso);
            if (regla == null) {
                log.warn("No se encontró regla aplicable para el caso {}", caso.getId());
                return null;
            }
            reglasActivas.put(caso.getId(), regla);
            respuestasPorCaso.put(caso.getId(), new HashMap<>());

            // Crear hipótesis iniciales
            crearHipotesisIniciales(caso, regla);

            // Retornar primera pregunta
            Pregunta primera = regla.getPrimeraPregunta();
            log.info("Primera pregunta para caso {}: {}", caso.getId(), primera.getTexto());
            return primera;
        }

        // Obtener la regla activa y las respuestas previas
        DiagnosticRule regla = reglasActivas.get(caso.getId());
        Map<String, Object> respuestas = respuestasPorCaso.get(caso.getId());
        String ultimaPregunta = ultimaPreguntaPorCaso.get(caso.getId());

        if (ultimaPregunta == null) {
            return regla.getPrimeraPregunta();
        }

        // Obtener última respuesta
        Object ultimaRespuesta = respuestas.get(ultimaPregunta);

        // Obtener siguiente pregunta
        Pregunta siguiente = regla.getSiguientePregunta(ultimaPregunta, ultimaRespuesta, respuestas);

        if (siguiente == null) {
            log.info("No hay más preguntas para caso {}. Listo para diagnóstico final.", caso.getId());
        } else {
            log.info("Siguiente pregunta para caso {}: {}", caso.getId(), siguiente.getTexto());
        }

        return siguiente;
    }

    /**
     * Procesa una respuesta del operador
     */
    @Transactional
    public void procesarRespuesta(Caso caso, Respuesta respuesta) {
        log.info("Procesando respuesta para caso {}: pregunta={}, valor={}",
                caso.getId(), respuesta.getPreguntaId(), respuesta.getValor());

        // Obtener la regla activa
        DiagnosticRule regla = reglasActivas.get(caso.getId());
        if (regla == null) {
            log.error("No hay regla activa para caso {}", caso.getId());
            throw new RuntimeException("No se puede procesar respuesta sin regla activa");
        }

        // Obtener el ID string de la pregunta
        String preguntaIdString = regla.getPreguntaIdString(respuesta.getPreguntaId());
        log.debug("ID string de pregunta: {}", preguntaIdString);

        Map<String, Object> respuestas = respuestasPorCaso.computeIfAbsent(
            caso.getId(), k -> new HashMap<>()
        );

        // Convertir respuesta a tipo apropiado
        Object valorProcesado = procesarValorRespuesta(respuesta.getValor());
        respuestas.put(preguntaIdString, valorProcesado);
        ultimaPreguntaPorCaso.put(caso.getId(), preguntaIdString);

        // Actualizar hipótesis basándose en la respuesta
        actualizarHipotesis(caso, respuestas);

        log.info("Respuesta procesada. Total respuestas para caso {}: {}",
                caso.getId(), respuestas.size());
    }

    /**
     * Realiza el diagnóstico final
     * Prioriza CLIPS si está disponible, fallback a reglas Java
     */
    @Transactional
    public void realizarDiagnostico(Caso caso) {
        log.info("Realizando diagnóstico final para caso {}", caso.getId());

        Map<String, Object> respuestas = respuestasPorCaso.get(caso.getId());
        if (respuestas == null || respuestas.isEmpty()) {
            log.error("No hay respuestas para caso {}", caso.getId());
            throw new RuntimeException("No se puede realizar diagnóstico sin respuestas");
        }

        Diagnostico diagnostico = null;

        // Intentar usar CLIPS primero si está disponible
        if (clipsIntegration != null) {
            try {
                // Obtener respuestas del caso desde la base de datos
                List<Respuesta> respuestasList = respuestaRepository.findByCasoId(caso.getId());
                
                diagnostico = clipsIntegration.procesarCasoConClips(caso, respuestasList);
                log.info("Diagnóstico generado por CLIPS para caso {}", caso.getId());
            } catch (Exception e) {
                log.warn("Error usando CLIPS, fallback a reglas Java: {}", e.getMessage());
                // Continuar con fallback a Java
            }
        }

        // Fallback a reglas Java si CLIPS no está disponible o falló
        if (diagnostico == null) {
            DiagnosticRule regla = reglasActivas.get(caso.getId());
            if (regla == null) {
                log.error("No hay regla activa para caso {}", caso.getId());
                throw new RuntimeException("No se puede realizar diagnóstico sin regla activa");
            }

            // Evaluar diagnóstico usando la regla Java
            diagnostico = regla.evaluarDiagnostico(respuestas, caso);
            log.info("Diagnóstico generado por reglas Java para caso {}", caso.getId());
        }

        // Convertir listas inmutables en mutables para que JPA pueda persistirlas
        if (diagnostico.getInstruccionesDiy() != null) {
            diagnostico.setInstruccionesDiy(new ArrayList<>(diagnostico.getInstruccionesDiy()));
        }
        if (diagnostico.getAlertasSeguridad() != null) {
            diagnostico.setAlertasSeguridad(new ArrayList<>(diagnostico.getAlertasSeguridad()));
        }
        if (diagnostico.getRepuestosProbables() != null) {
            diagnostico.setRepuestosProbables(new ArrayList<>(diagnostico.getRepuestosProbables()));
        }
        if (diagnostico.getMensajesCliente() != null) {
            diagnostico.setMensajesCliente(new ArrayList<>(diagnostico.getMensajesCliente()));
        }

        // Guardar diagnóstico
        diagnostico = diagnosticoRepository.save(diagnostico);
        caso.setDiagnostico(diagnostico);

        // Actualizar hipótesis finales
        actualizarHipotesisFinales(caso, diagnostico);

        // Limpiar caché
        limpiarCache(caso.getId());

        log.info("Diagnóstico completado para caso {}: {} (probabilidad: {}%)",
                caso.getId(), diagnostico.getCausaProbable(), diagnostico.getProbabilidad());
    }

    /**
     * Selecciona la regla más apropiada para el caso
     */
    private DiagnosticRule seleccionarReglaAplicable(Caso caso) {
        log.info("Seleccionando regla para caso {}: tipo={}, síntoma={}",
                caso.getId(), caso.getTipo(), caso.getSintomaReportado());

        // Filtrar reglas por tipo de electrodoméstico
        List<DiagnosticRule> reglasCompatibles = todasLasReglas.stream()
            .filter(regla -> regla.getTipoElectrodomestico() == caso.getTipo())
            .collect(Collectors.toList());

        log.debug("Reglas compatibles con tipo {}: {}", caso.getTipo(), reglasCompatibles.size());

        // Buscar regla que coincida con el síntoma (ordenadas por prioridad)
        Optional<DiagnosticRule> reglaSeleccionada = reglasCompatibles.stream()
            .filter(regla -> regla.esAplicable(caso.getSintomaReportado()))
            .sorted((r1, r2) -> Integer.compare(r2.getPrioridad(), r1.getPrioridad()))
            .findFirst();

        if (reglaSeleccionada.isPresent()) {
            log.info("Regla seleccionada: {} (prioridad: {})",
                    reglaSeleccionada.get().getId(), reglaSeleccionada.get().getPrioridad());
            return reglaSeleccionada.get();
        }

        // Si no hay coincidencia exacta, usar la de mayor prioridad para ese tipo
        log.warn("No se encontró regla específica, usando regla genérica");
        return reglasCompatibles.stream()
            .sorted((r1, r2) -> Integer.compare(r2.getPrioridad(), r1.getPrioridad()))
            .findFirst()
            .orElse(null);
    }

    /**
     * Crea hipótesis iniciales basadas en el síntoma
     */
    private void crearHipotesisIniciales(Caso caso, DiagnosticRule regla) {
        log.debug("Creando hipótesis iniciales para caso {}", caso.getId());

        // Limpiar hipótesis previas
        hipotesisRepository.deleteAll(hipotesisRepository.findByCasoId(caso.getId()));

        // Crear hipótesis genéricas basadas en el tipo de problema
        List<Hipotesis> hipotesisIniciales = new ArrayList<>();

        // Hipótesis basadas en la regla seleccionada
        if (regla.getId().contains("no_enfria")) {
            hipotesisIniciales.add(crearHipotesis(caso, "Problema eléctrico", 30));
            hipotesisIniciales.add(crearHipotesis(caso, "Falla del compresor", 25));
            hipotesisIniciales.add(crearHipotesis(caso, "Termostato defectuoso", 20));
            hipotesisIniciales.add(crearHipotesis(caso, "Fuga de gas refrigerante", 15));
            hipotesisIniciales.add(crearHipotesis(caso, "Sistema de desescarche", 10));
        } else if (regla.getId().contains("no_carga_agua")) {
            hipotesisIniciales.add(crearHipotesis(caso, "Canilla cerrada", 35));
            hipotesisIniciales.add(crearHipotesis(caso, "Filtro obstruido", 30));
            hipotesisIniciales.add(crearHipotesis(caso, "Electroválvula defectuosa", 25));
            hipotesisIniciales.add(crearHipotesis(caso, "Problema de presión", 10));
        } else if (regla.getId().contains("hace_chispas")) {
            hipotesisIniciales.add(crearHipotesis(caso, "Objeto metálico dentro", 50));
            hipotesisIniciales.add(crearHipotesis(caso, "Mica protectora dañada", 30));
            hipotesisIniciales.add(crearHipotesis(caso, "Magnetrón defectuoso", 15));
            hipotesisIniciales.add(crearHipotesis(caso, "Plato mal colocado", 5));
        }

        hipotesisRepository.saveAll(hipotesisIniciales);
        log.info("Creadas {} hipótesis iniciales para caso {}", hipotesisIniciales.size(), caso.getId());
    }

    /**
     * Actualiza probabilidades de hipótesis según respuestas
     */
    private void actualizarHipotesis(Caso caso, Map<String, Object> respuestas) {
        log.debug("Actualizando hipótesis para caso {} con {} respuestas",
                caso.getId(), respuestas.size());

        List<Hipotesis> hipotesis = hipotesisRepository.findByCasoId(caso.getId());
        DiagnosticRule regla = reglasActivas.get(caso.getId());

        // Ajustar probabilidades basándose en las respuestas
        // (Lógica simplificada - en producción sería más sofisticada)

        for (Hipotesis h : hipotesis) {
            int ajuste = calcularAjusteProbabilidad(h, respuestas, regla);
            int nuevaProbabilidad = Math.max(0, Math.min(100, h.getProbabilidad() + ajuste));
            h.setProbabilidad(nuevaProbabilidad);
            h.setActiva(nuevaProbabilidad > 10); // Desactivar hipótesis muy improbables
        }

        // Normalizar probabilidades
        normalizarProbabilidades(hipotesis);

        hipotesisRepository.saveAll(hipotesis);
    }

    /**
     * Actualiza hipótesis finales con el diagnóstico
     */
    private void actualizarHipotesisFinales(Caso caso, Diagnostico diagnostico) {
        List<Hipotesis> hipotesis = hipotesisRepository.findByCasoId(caso.getId());

        // Desactivar todas excepto la que coincide con el diagnóstico
        for (Hipotesis h : hipotesis) {
            if (h.getDescripcion().toLowerCase().contains(
                    diagnostico.getComponenteAfectado().toLowerCase().split("/")[0].trim())) {
                h.setProbabilidad(diagnostico.getProbabilidad());
                h.setActiva(true);
            } else {
                h.setActiva(false);
            }
        }

        hipotesisRepository.saveAll(hipotesis);
    }

    /**
     * Calcula ajuste de probabilidad para una hipótesis
     */
    private int calcularAjusteProbabilidad(Hipotesis hipotesis,
                                           Map<String, Object> respuestas,
                                           DiagnosticRule regla) {
        // Lógica simplificada - ajusta según respuestas específicas
        int ajuste = 0;

        // Ejemplo: si la luz funciona, reducir probabilidad de problema eléctrico
        if (hipotesis.getDescripcion().contains("eléctrico")) {
            if (Boolean.TRUE.equals(respuestas.get("h_ne_p1"))) {
                ajuste -= 20;
            } else if (Boolean.FALSE.equals(respuestas.get("h_ne_p1"))) {
                ajuste += 40;
            }
        }

        return ajuste;
    }

    /**
     * Normaliza probabilidades para que sumen aproximadamente 100%
     */
    private void normalizarProbabilidades(List<Hipotesis> hipotesis) {
        int total = hipotesis.stream()
            .filter(Hipotesis::isActiva)
            .mapToInt(Hipotesis::getProbabilidad)
            .sum();

        if (total > 0 && total != 100) {
            double factor = 100.0 / total;
            for (Hipotesis h : hipotesis) {
                if (h.isActiva()) {
                    h.setProbabilidad((int) Math.round(h.getProbabilidad() * factor));
                }
            }
        }
    }

    /**
     * Crea una hipótesis
     */
    private Hipotesis crearHipotesis(Caso caso, String descripcion, int probabilidad) {
        return Hipotesis.builder()
            .caso(caso)
            .descripcion(descripcion)
            .probabilidad(probabilidad)
            .activa(true)
            .build();
    }

    /**
     * Procesa el valor de una respuesta al tipo correcto
     */
    private Object procesarValorRespuesta(String valor) {
        if (valor == null) {
            return null;
        }

        // Intentar convertir a booleano
        if ("true".equalsIgnoreCase(valor) || "si".equalsIgnoreCase(valor) || "sí".equalsIgnoreCase(valor)) {
            return true;
        }
        if ("false".equalsIgnoreCase(valor) || "no".equalsIgnoreCase(valor)) {
            return false;
        }

        // Intentar convertir a número
        try {
            return Integer.parseInt(valor);
        } catch (NumberFormatException e) {
            // No es número, devolver como string
        }

        return valor;
    }

    /**
     * Limpia la caché para un caso
     */
    private void limpiarCache(Long casoId) {
        reglasActivas.remove(casoId);
        respuestasPorCaso.remove(casoId);
        ultimaPreguntaPorCaso.remove(casoId);
        log.debug("Caché limpiada para caso {}", casoId);
    }
}

