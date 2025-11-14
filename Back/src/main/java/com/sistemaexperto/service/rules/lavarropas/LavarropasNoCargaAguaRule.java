package com.sistemaexperto.service.rules.lavarropas;

import com.sistemaexperto.model.Caso;
import com.sistemaexperto.model.Diagnostico;
import com.sistemaexperto.model.Pregunta;
import com.sistemaexperto.model.enums.TipoElectrodomestico;
import com.sistemaexperto.model.enums.TipoSolucion;
import com.sistemaexperto.model.enums.Urgencia;
import com.sistemaexperto.service.rules.DiagnosticRule;
import org.springframework.stereotype.Component;

import java.util.*;
import java.util.regex.Pattern;

/**
 * Regla CRÍTICA: Lavarropas no carga agua
 * Prioridad 1 - Muy común
 */
@Component
public class LavarropasNoCargaAguaRule implements DiagnosticRule {

    private static final String RULE_ID = "lavarropas_no_carga_agua";
    private static final Pattern SINTOMA_PATTERN = Pattern.compile(
        ".*(no\\s+(carga|entra|llena|toma)\\s+agua|sin\\s+agua|no\\s+hay\\s+agua).*",
        Pattern.CASE_INSENSITIVE
    );

    private final Map<String, Pregunta> preguntasMap = new HashMap<>();

    public LavarropasNoCargaAguaRule() {
        inicializarPreguntas();
    }

    private void inicializarPreguntas() {
        // Pregunta 1: Verificar canilla abierta
        Pregunta p1 = Pregunta.builder()
            .id(10L)
            .texto("¿La canilla de paso de agua al lavarropas está completamente abierta?")
            .tipo(Pregunta.TipoPregunta.SI_NO)
            .critica(true)
            .ayuda("Verificar la canilla ubicada detrás o debajo del lavarropas")
            .build();
        preguntasMap.put("l_nca_p1", p1);

        // Pregunta 2: Verificar presión de agua
        Pregunta p2 = Pregunta.builder()
            .id(11L)
            .texto("¿Hay presión de agua normal en otras canillas de la casa?")
            .tipo(Pregunta.TipoPregunta.SI_NO)
            .critica(true)
            .ayuda("Abrir otra canilla para verificar que haya presión normal")
            .build();
        preguntasMap.put("l_nca_p2", p2);

        // Pregunta 3: Verificar manguera de entrada
        Pregunta p3 = Pregunta.builder()
            .id(12L)
            .texto("¿La manguera de entrada de agua está doblada o aplastada?")
            .tipo(Pregunta.TipoPregunta.SI_NO)
            .ayuda("Revisar toda la manguera desde la canilla hasta el lavarropas")
            .build();
        preguntasMap.put("l_nca_p3", p3);
    }

    @Override
    public String getId() {
        return RULE_ID;
    }

    @Override
    public TipoElectrodomestico getTipoElectrodomestico() {
        return TipoElectrodomestico.LAVARROPAS;
    }

    @Override
    public boolean esAplicable(String sintomaReportado) {
        return sintomaReportado != null &&
               SINTOMA_PATTERN.matcher(sintomaReportado).matches();
    }

    @Override
    public List<Pregunta> getPreguntas() {
        return new ArrayList<>(preguntasMap.values());
    }

    @Override
    public Pregunta getPrimeraPregunta() {
        return preguntasMap.get("l_nca_p1");
    }

    @Override
    public Pregunta getSiguientePregunta(String preguntaActualId, Object respuesta, Map<String, Object> todasLasRespuestas) {
        switch (preguntaActualId) {
            case "l_nca_p1":
                // Si canilla NO está abierta → terminar (solución DIY inmediata)
                if (Boolean.FALSE.equals(respuesta)) {
                    return null;
                }
                // Si canilla SÍ está abierta → verificar presión de agua
                return preguntasMap.get("l_nca_p2");

            case "l_nca_p2":
                // Si NO hay presión → terminar (problema de suministro)
                if (Boolean.FALSE.equals(respuesta)) {
                    return null;
                }
                // Si SÍ hay presión → verificar manguera
                return preguntasMap.get("l_nca_p3");

            case "l_nca_p3":
                // Última pregunta
                return null;

            default:
                return null;
        }
    }

    @Override
    public Diagnostico evaluarDiagnostico(Map<String, Object> respuestas, Caso caso) {
        // ÁRBOL DE DECISIÓN

        // Rama 1: Canilla NO está abierta → Solución DIY inmediata
        if (Boolean.FALSE.equals(respuestas.get("l_nca_p1")) {
            return Diagnostico.builder()
                .causaProbable("Canilla de paso cerrada o semi-cerrada")
                .probabilidad(95)
                .componenteAfectado("Canilla de paso")
                .requiereTecnico(false)
                .tipoSolucion(TipoSolucion.DIY)
                .urgencia(Urgencia.BAJA)
                .costoEstimadoMin(0.0)
                .costoEstimadoMax(0.0)
                .tiempoEstimado(2)
                .instruccionesDiy(Arrays.asList(
                    "1. Abrir completamente la canilla de paso de agua",
                    "2. Verificar que gire hasta el tope",
                    "3. Iniciar un ciclo de lavado para verificar"
                ))
                .generarOrdenTrabajo(false)
                .build();
        }

        // Rama 2: NO hay presión de agua general
        if (Boolean.TRUE.equals(respuestas.get("l_nca_p1")) &&
            Boolean.FALSE.equals(respuestas.get("l_nca_p2")) {

            return Diagnostico.builder()
                .causaProbable("Problema de suministro de agua general")
                .probabilidad(90)
                .componenteAfectado("Suministro de agua de la vivienda")
                .requiereTecnico(false)
                .tipoSolucion(TipoSolucion.DIY)
                .urgencia(Urgencia.MEDIA)
                .costoEstimadoMin(0.0)
                .costoEstimadoMax(0.0)
                .tiempoEstimado(5)
                .instruccionesDiy(Arrays.asList(
                    "1. Verificar si hay un corte de agua en la zona",
                    "2. Revisar la bomba de agua si tiene",
                    "3. Contactar con el administrador del edificio",
                    "4. Esperar a que se restablezca el servicio"
                ))
                .mensajesCliente(Arrays.asList(
                    "El problema no es del lavarropas sino del suministro de agua"
                ))
                .generarOrdenTrabajo(false)
                .build();
        }

        // Rama 3: Manguera doblada o aplastada
        if (Boolean.TRUE.equals(respuestas.get("l_nca_p3")) {
            return Diagnostico.builder()
                .causaProbable("Manguera de entrada obstruida o doblada")
                .probabilidad(85)
                .componenteAfectado("Manguera de entrada")
                .requiereTecnico(false)
                .tipoSolucion(TipoSolucion.DIY)
                .urgencia(Urgencia.BAJA)
                .costoEstimadoMin(0.0)
                .costoEstimadoMax(5000.0)
                .tiempoEstimado(10)
                .instruccionesDiy(Arrays.asList(
                    "1. Desconectar el lavarropas de la corriente",
                    "2. Cerrar la canilla de paso de agua",
                    "3. Mover el lavarropas para acceder a la parte trasera",
                    "4. Enderezar la manguera y verificar que no esté aplastada",
                    "5. Si la manguera está dañada, considerar reemplazo",
                    "6. Abrir la canilla y reconectar el lavarropas"
                ))
                .repuestosProbables(Arrays.asList("Manguera de entrada (si está dañada)"))
                .generarOrdenTrabajo(false)
                .build();
        }

        // Rama 4: Manguera OK pero no carga → Problema de electroválvula o filtro
        if (Boolean.TRUE.equals(respuestas.get("l_nca_p1")) &&
            Boolean.TRUE.equals(respuestas.get("l_nca_p2")) &&
            Boolean.FALSE.equals(respuestas.get("l_nca_p3")) {

            // Verificar si el cliente tiene experiencia DIY
            boolean clienteExperimentado = false; // TODO: obtener del historial

            if (clienteExperimentado) {
                return Diagnostico.builder()
                    .causaProbable("Filtro de entrada obstruido o electroválvula defectuosa")
                    .probabilidad(75)
                    .componenteAfectado("Filtro de entrada / Electroválvula")
                    .requiereTecnico(false)
                    .tipoSolucion(TipoSolucion.DIY)
                    .urgencia(Urgencia.MEDIA)
                    .costoEstimadoMin(0.0)
                    .costoEstimadoMax(15000.0)
                    .tiempoEstimado(30)
                    .instruccionesDiy(Arrays.asList(
                        "1. Desconectar el lavarropas de la corriente",
                        "2. Cerrar la canilla de paso",
                        "3. Desenroscar la manguera de la entrada del lavarropas",
                        "4. Extraer el filtro (pequeña rejilla) con pinzas",
                        "5. Limpiar el filtro bajo el chorro de agua",
                        "6. Volver a colocar el filtro y la manguera",
                        "7. Abrir la canilla y probar",
                        "8. Si no funciona, puede ser la electroválvula → llamar técnico"
                    ))
                    .alertasSeguridad(Arrays.asList(
                        "Tener trapos a mano, puede salir algo de agua",
                        "Asegurarse de que esté desconectado de la corriente"
                    ))
                    .repuestosProbables(Arrays.asList("Electroválvula"))
                    .generarOrdenTrabajo(false)
                    .build();
            } else {
                return Diagnostico.builder()
                    .causaProbable("Filtro de entrada obstruido o electroválvula defectuosa")
                    .probabilidad(75)
                    .componenteAfectado("Filtro de entrada / Electroválvula")
                    .requiereTecnico(true)
                    .tipoSolucion(TipoSolucion.TECNICO_SIMPLE)
                    .urgencia(Urgencia.MEDIA)
                    .costoEstimadoMin(15000.0)
                    .costoEstimadoMax(35000.0)
                    .tiempoEstimado(45)
                    .repuestosProbables(Arrays.asList("Electroválvula", "Filtro"))
                    .mensajesCliente(Arrays.asList(
                        "Probablemente sea una limpieza de filtro o cambio de electroválvula",
                        "Reparación sencilla"
                    ))
                    .generarOrdenTrabajo(true)
                    .prioridadOT("media")
                    .build();
            }
        }

        // Caso por defecto
        return Diagnostico.builder()
            .causaProbable("Requiere diagnóstico técnico (posible problema de electroválvula o control)")
            .probabilidad(60)
            .componenteAfectado("Sistema de carga de agua")
            .requiereTecnico(true)
            .tipoSolucion(TipoSolucion.TECNICO_SIMPLE)
            .urgencia(Urgencia.MEDIA)
            .costoEstimadoMin(20000.0)
            .costoEstimadoMax(45000.0)
            .tiempoEstimado(60)
            .generarOrdenTrabajo(true)
            .prioridadOT("media")
            .build();
    }

    @Override
    public int getPrioridad() {
        return 95; // Alta prioridad
    }

    @Override
    public String getPreguntaIdString(Long preguntaIdNumerico) {
        // Mapeo de ID numérico a ID string
        switch (preguntaIdNumerico.intValue()) {
            case 10: return "l_nca_p1";
            case 11: return "l_nca_p2";
            case 12: return "l_nca_p3";
            default: return "l_nca_p" + preguntaIdNumerico;
        }
    }
}

