package com.sistemaexperto.service.rules.heladera;

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
 * Regla CRÍTICA: Heladera no enfría
 * Prioridad 1 - Más común y urgente
 */
@Component
public class HeladeraNoEnfriaRule implements DiagnosticRule {

    private static final String RULE_ID = "heladera_no_enfria";
    private static final Pattern SINTOMA_PATTERN = Pattern.compile(
        ".*(no\\s+(enfr[ií]a|fr[ií]o|congela|funciona)|temperatura|caliente|tibio).*",
        Pattern.CASE_INSENSITIVE
    );

    private final Map<String, Pregunta> preguntasMap = new HashMap<>();

    public HeladeraNoEnfriaRule() {
        inicializarPreguntas();
    }

    private void inicializarPreguntas() {
        // Pregunta 1: Verificar alimentación eléctrica
        Pregunta p1 = Pregunta.builder()
            .id(1L)
            .texto("¿La luz interior de la heladera funciona cuando abre la puerta?")
            .tipo(Pregunta.TipoPregunta.SI_NO)
            .critica(true)
            .ayuda("Esta pregunta verifica si hay alimentación eléctrica correcta")
            .build();
        preguntasMap.put("h_ne_p1", p1);

        // Pregunta 2: Verificar funcionamiento del compresor
        Pregunta p2 = Pregunta.builder()
            .id(2L)
            .texto("¿Escucha algún sonido del motor/compresor en la parte trasera?")
            .tipo(Pregunta.TipoPregunta.SI_NO)
            .critica(true)
            .ayuda("El motor debe hacer un sonido de zumbido periódicamente")
            .build();
        preguntasMap.put("h_ne_p2", p2);

        // Pregunta 3: Verificar temperatura del motor
        Pregunta p3 = Pregunta.builder()
            .id(3L)
            .texto("Con cuidado, ¿el motor está caliente al tacto?")
            .tipo(Pregunta.TipoPregunta.SI_NO)
            .ayuda("⚠️ ADVERTENCIA: El motor puede estar muy caliente, tocar con precaución")
            .build();
        preguntasMap.put("h_ne_p3", p3);

        // Pregunta 4: Verificar ciclos del motor
        Pregunta p4 = Pregunta.builder()
            .id(4L)
            .texto("¿El motor funciona constantemente o hace ciclos (prende y apaga)?")
            .tipo(Pregunta.TipoPregunta.OPCION_MULTIPLE)
            .opciones(Arrays.asList("Constantemente sin parar", "Hace ciclos (prende/apaga)", "No sé"))
            .ayuda("Un funcionamiento normal implica ciclos de encendido y apagado")
            .build();
        preguntasMap.put("h_ne_p4", p4);

        // Pregunta 5: Verificar acumulación de hielo
        Pregunta p5 = Pregunta.builder()
            .id(5L)
            .texto("¿Hay acumulación excesiva de hielo en el freezer o en las paredes?")
            .tipo(Pregunta.TipoPregunta.SI_NO)
            .ayuda("Una capa gruesa de hielo puede indicar problemas de desescarche")
            .build();
        preguntasMap.put("h_ne_p5", p5);
    }

    @Override
    public String getId() {
        return RULE_ID;
    }

    @Override
    public TipoElectrodomestico getTipoElectrodomestico() {
        return TipoElectrodomestico.HELADERA;
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
        return preguntasMap.get("h_ne_p1");
    }

    @Override
    public Pregunta getSiguientePregunta(String preguntaActualId, Object respuesta, Map<String, Object> todasLasRespuestas) {
        switch (preguntaActualId) {
            case "h_ne_p1":
                // Si la luz NO funciona → terminar (problema eléctrico)
                if (Boolean.FALSE.equals(respuesta)) {
                    return null;
                }
                // Si la luz SÍ funciona → siguiente pregunta
                return preguntasMap.get("h_ne_p2");

            case "h_ne_p2":
                // Si NO escucha motor → preguntar por temperatura
                if (Boolean.FALSE.equals(respuesta)) {
                    return preguntasMap.get("h_ne_p3");
                }
                // Si SÍ escucha motor → preguntar por ciclos
                return preguntasMap.get("h_ne_p4");

            case "h_ne_p3":
                // Terminar después de verificar temperatura del motor
                return null;

            case "h_ne_p4":
                // Después de preguntar por ciclos, preguntar por hielo
                return preguntasMap.get("h_ne_p5");

            case "h_ne_p5":
                // Última pregunta
                return null;

            default:
                return null;
        }
    }

    @Override
    public Diagnostico evaluarDiagnostico(Map<String, Object> respuestas, Caso caso) {
        // ÁRBOL DE DECISIÓN

        // Rama 1: Luz NO funciona → Problema eléctrico DIY
        if (Boolean.FALSE.equals(respuestas.get("h_ne_p1")) {
            return Diagnostico.builder()
                .causaProbable("Sin alimentación eléctrica")
                .probabilidad(85)
                .componenteAfectado("Circuito eléctrico / Enchufe")
                .requiereTecnico(false)
                .tipoSolucion(TipoSolucion.DIY)
                .urgencia(Urgencia.ALTA)
                .costoEstimadoMin(0.0)
                .costoEstimadoMax(5000.0)
                .tiempoEstimado(10)
                .instruccionesDiy(new ArrayList<>(Arrays.asList(
                    "1. Verificar que el enchufe esté correctamente conectado",
                    "2. Probar con otro electrodoméstico en el mismo tomacorriente",
                    "3. Revisar los fusibles del tablero eléctrico",
                    "4. Si nada funciona, llamar a un electricista"
                ))
                .generarOrdenTrabajo(false)
                .build();
        }

        // Rama 2: Luz SÍ pero motor NO suena
        if (Boolean.TRUE.equals(respuestas.get("h_ne_p1")) &&
            Boolean.FALSE.equals(respuestas.get("h_ne_p2")) {

            Boolean motorCaliente = (Boolean) respuestas.get("h_ne_p3");

            // Sub-rama 2a: Motor caliente → Compresor defectuoso
            if (Boolean.TRUE.equals(motorCaliente)) {
                return Diagnostico.builder()
                    .causaProbable("Compresor defectuoso o relé de arranque dañado")
                    .probabilidad(75)
                    .componenteAfectado("Compresor / Relé de arranque")
                    .requiereTecnico(true)
                    .tipoSolucion(TipoSolucion.TECNICO_COMPLEJO)
                    .urgencia(Urgencia.ALTA)
                    .costoEstimadoMin(80000.0)
                    .costoEstimadoMax(150000.0)
                    .tiempoEstimado(180)
                    .repuestosProbables(Arrays.asList("Compresor", "Relé de arranque", "Capacitor"))
                    .mensajesCliente(Arrays.asList(
                        "Trasladar alimentos perecederos a otro lugar",
                        "Mantener la puerta cerrada mientras tanto",
                        "Se programará visita técnica en 24hs"
                    ))
                    .alertasSeguridad(Arrays.asList(
                        "Desconectar la heladera si el motor está muy caliente"
                    ))
                    .generarOrdenTrabajo(true)
                    .prioridadOT("urgente")
                    .build();
            } else {
                // Sub-rama 2b: Motor frío → Problema eléctrico del compresor
                return Diagnostico.builder()
                    .causaProbable("Problema eléctrico del compresor o termostato")
                    .probabilidad(70)
                    .componenteAfectado("Sistema eléctrico del compresor")
                    .requiereTecnico(true)
                    .tipoSolucion(TipoSolucion.TECNICO_SIMPLE)
                    .urgencia(Urgencia.ALTA)
                    .costoEstimadoMin(25000.0)
                    .costoEstimadoMax(50000.0)
                    .tiempoEstimado(90)
                    .repuestosProbables(Arrays.asList("Relé de arranque", "Termostato"))
                    .generarOrdenTrabajo(true)
                    .prioridadOT("alta")
                    .build();
            }
        }

        // Rama 3: Motor funciona constantemente
        if (Boolean.TRUE.equals(respuestas.get("h_ne_p2")) &&
            "Constantemente sin parar".equals(respuestas.get("h_ne_p4")) {

            Boolean hieloExcesivo = (Boolean) respuestas.get("h_ne_p5");

            // Sub-rama 3a: Sin hielo excesivo → Termostato defectuoso
            if (Boolean.FALSE.equals(hieloExcesivo)) {
                return Diagnostico.builder()
                    .causaProbable("Termostato defectuoso (no corta el ciclo)")
                    .probabilidad(80)
                    .componenteAfectado("Termostato")
                    .requiereTecnico(true)
                    .tipoSolucion(TipoSolucion.TECNICO_SIMPLE)
                    .urgencia(Urgencia.MEDIA)
                    .costoEstimadoMin(20000.0)
                    .costoEstimadoMax(35000.0)
                    .tiempoEstimado(45)
                    .repuestosProbables(Arrays.asList("Termostato"))
                    .generarOrdenTrabajo(true)
                    .prioridadOT("media")
                    .build();
            } else {
                // Sub-rama 3b: Con hielo excesivo → Sistema de desescarche
                return Diagnostico.builder()
                    .causaProbable("Sistema de desescarche automático defectuoso")
                    .probabilidad(75)
                    .componenteAfectado("Resistencia de desescarche / Timer")
                    .requiereTecnico(true)
                    .tipoSolucion(TipoSolucion.TECNICO_SIMPLE)
                    .urgencia(Urgencia.MEDIA)
                    .costoEstimadoMin(25000.0)
                    .costoEstimadoMax(45000.0)
                    .tiempoEstimado(60)
                    .repuestosProbables(Arrays.asList("Resistencia de desescarche", "Timer", "Termostato de desescarche"))
                    .instruccionesDiy(Arrays.asList(
                        "Mientras espera al técnico, puede descongelar manualmente"
                    ))
                    .generarOrdenTrabajo(true)
                    .prioridadOT("media")
                    .build();
            }
        }

        // Rama 4: Motor hace ciclos normales
        if (Boolean.TRUE.equals(respuestas.get("h_ne_p2")) &&
            "Hace ciclos (prende/apaga)".equals(respuestas.get("h_ne_p4")) {

            Boolean hieloExcesivo = (Boolean) respuestas.get("h_ne_p5");

            if (Boolean.TRUE.equals(hieloExcesivo)) {
                // Obstrucción del flujo de aire
                return Diagnostico.builder()
                    .causaProbable("Obstrucción del flujo de aire por exceso de hielo")
                    .probabilidad(70)
                    .componenteAfectado("Sistema de ventilación / Circulación")
                    .requiereTecnico(false)
                    .tipoSolucion(TipoSolucion.DIY)
                    .urgencia(Urgencia.MEDIA)
                    .costoEstimadoMin(0.0)
                    .costoEstimadoMax(15000.0)
                    .tiempoEstimado(30)
                    .instruccionesDiy(Arrays.asList(
                        "1. Desconectar la heladera completamente",
                        "2. Vaciar y limpiar el interior",
                        "3. Dejar descongelar por 6-8 horas con puertas abiertas",
                        "4. Secar completamente antes de reconectar",
                        "5. Si el problema persiste, llamar técnico"
                    ))
                    .generarOrdenTrabajo(false)
                    .build();
            } else {
                // Fuga de gas refrigerante
                return Diagnostico.builder()
                    .causaProbable("Posible fuga de gas refrigerante")
                    .probabilidad(65)
                    .componenteAfectado("Sistema de refrigeración sellado")
                    .requiereTecnico(true)
                    .tipoSolucion(TipoSolucion.TECNICO_COMPLEJO)
                    .urgencia(Urgencia.ALTA)
                    .costoEstimadoMin(50000.0)
                    .costoEstimadoMax(120000.0)
                    .tiempoEstimado(150)
                    .mensajesCliente(Arrays.asList(
                        "Requiere técnico especializado en refrigeración",
                        "Se necesita equipo especializado para detectar fugas"
                    ))
                    .generarOrdenTrabajo(true)
                    .prioridadOT("alta")
                    .build();
            }
        }

        // Caso por defecto: Diagnóstico técnico presencial necesario
        return crearDiagnosticoDefault(caso);
    }

    private Diagnostico crearDiagnosticoDefault(Caso caso) {
        // Si el electrodoméstico es muy antiguo, sugerir reemplazo
        if (caso.getAntiguedad() != null && caso.getAntiguedad() > 10) {
            return Diagnostico.builder()
                .causaProbable("Requiere diagnóstico técnico presencial (evaluar reemplazo)")
                .probabilidad(50)
                .componenteAfectado("Por determinar")
                .requiereTecnico(true)
                .tipoSolucion(TipoSolucion.REEMPLAZO)
                .urgencia(Urgencia.MEDIA)
                .costoEstimadoMin(30000.0)
                .costoEstimadoMax(80000.0)
                .tiempoEstimado(120)
                .mensajesCliente(Arrays.asList(
                    "Dado que el electrodoméstico tiene más de 10 años,",
                    "el técnico evaluará si es conveniente reparar o reemplazar"
                ))
                .generarOrdenTrabajo(true)
                .prioridadOT("media")
                .build();
        }

        return Diagnostico.builder()
            .causaProbable("Requiere diagnóstico técnico presencial")
            .probabilidad(50)
            .componenteAfectado("Por determinar")
            .requiereTecnico(true)
            .tipoSolucion(TipoSolucion.TECNICO_COMPLEJO)
            .urgencia(Urgencia.MEDIA)
            .costoEstimadoMin(30000.0)
            .costoEstimadoMax(80000.0)
            .tiempoEstimado(120)
            .generarOrdenTrabajo(true)
            .prioridadOT("media")
            .build();
    }

    @Override
    public int getPrioridad() {
        return 100; // Máxima prioridad
    }

    @Override
    public String getPreguntaIdString(Long preguntaIdNumerico) {
        // Mapeo de ID numérico a ID string
        switch (preguntaIdNumerico.intValue()) {
            case 1: return "h_ne_p1";
            case 2: return "h_ne_p2";
            case 3: return "h_ne_p3";
            case 4: return "h_ne_p4";
            case 5: return "h_ne_p5";
            default: return "h_ne_p" + preguntaIdNumerico;
        }
    }
}

