package com.sistemaexperto.service.rules.microondas;

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
 * Regla CRÍTICA: Microondas hace chispas
 * Prioridad MÁXIMA - SEGURIDAD
 */
@Component
public class MicroondasHaceChispasRule implements DiagnosticRule {

    private static final String RULE_ID = "microondas_hace_chispas";
    private static final Pattern SINTOMA_PATTERN = Pattern.compile(
        ".*(chispa|chispazo|centella|arco\\s+eléctrico|destello|luz.*interior).*",
        Pattern.CASE_INSENSITIVE
    );

    private final Map<String, Pregunta> preguntasMap = new HashMap<>();

    public MicroondasHaceChispasRule() {
        inicializarPreguntas();
    }

    private void inicializarPreguntas() {
        // Pregunta 1: CRÍTICA - Verificar si hay metal
        Pregunta p1 = Pregunta.builder()
            .id(20L)
            .texto("⚠️ IMPORTANTE: ¿Había algún objeto metálico dentro del microondas? (cubiertos, papel aluminio, recipientes con bordes dorados)")
            .tipo(Pregunta.TipoPregunta.SI_NO)
            .critica(true)
            .ayuda("El metal causa chispas peligrosas en el microondas. Verificar también decoraciones doradas en platos.")
            .build();
        preguntasMap.put("m_hc_p1", p1);

        // Pregunta 2: Verificar plato giratorio
        Pregunta p2 = Pregunta.builder()
            .id(21L)
            .texto("¿El plato giratorio está correctamente colocado sobre el eje?")
            .tipo(Pregunta.TipoPregunta.SI_NO)
            .ayuda("Un plato mal colocado puede causar fricción y chispas")
            .build();
        preguntasMap.put("m_hc_p2", p2);
    }

    @Override
    public String getId() {
        return RULE_ID;
    }

    @Override
    public TipoElectrodomestico getTipoElectrodomestico() {
        return TipoElectrodomestico.MICROONDAS;
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
        return preguntasMap.get("m_hc_p1");
    }

    @Override
    public Pregunta getSiguientePregunta(String preguntaActualId, Object respuesta, Map<String, Object> todasLasRespuestas) {
        switch (preguntaActualId) {
            case "m_hc_p1":
                // Si había metal → terminar (solución DIY)
                if (Boolean.TRUE.equals(respuesta)) {
                    return null;
                }
                // Si NO había metal → verificar plato
                return preguntasMap.get("m_hc_p2");

            case "m_hc_p2":
                // Última pregunta
                return null;

            default:
                return null;
        }
    }

    @Override
    public Diagnostico evaluarDiagnostico(Map<String, Object> respuestas, Caso caso) {
        // ÁRBOL DE DECISIÓN - CASO CRÍTICO DE SEGURIDAD

        // Rama 1: Había metal dentro → Solución DIY pero CON ADVERTENCIA
        if (Boolean.TRUE.equals(respuestas.get("m_hc_p1")) {
            return Diagnostico.builder()
                .causaProbable("Objeto metálico dentro del microondas")
                .probabilidad(95)
                .componenteAfectado("Ninguno (uso incorrecto)")
                .requiereTecnico(false)
                .tipoSolucion(TipoSolucion.DIY)
                .urgencia(Urgencia.CRITICA)
                .costoEstimadoMin(0.0)
                .costoEstimadoMax(0.0)
                .tiempoEstimado(5)
                .instruccionesDiy(Arrays.asList(
                    "1. NO volver a usar metal en el microondas",
                    "2. Verificar que no haya daños en las paredes interiores",
                    "3. Si hay manchas negras o perforaciones → NO USAR y llamar técnico",
                    "4. Si está intacto, probar con un vaso de agua por 30 segundos",
                    "5. Si funciona normal, el problema está resuelto"
                ))
                .alertasSeguridad(Arrays.asList(
                    "⚠️ NUNCA usar objetos metálicos en el microondas",
                    "⚠️ Incluye papel aluminio, cubiertos, recipientes con decoración metálica",
                    "⚠️ Si detecta olor a quemado o daños, NO USAR el microondas"
                ))
                .mensajesCliente(Arrays.asList(
                    "El metal causa arcos eléctricos peligrosos",
                    "Siempre usar recipientes aptos para microondas"
                ))
                .generarOrdenTrabajo(false)
                .build();
        }

        // Rama 2: Plato mal colocado
        if (Boolean.FALSE.equals(respuestas.get("m_hc_p1")) &&
            Boolean.FALSE.equals(respuestas.get("m_hc_p2")) {

            return Diagnostico.builder()
                .causaProbable("Plato giratorio mal colocado causa fricción")
                .probabilidad(80)
                .componenteAfectado("Plato giratorio / Eje")
                .requiereTecnico(false)
                .tipoSolucion(TipoSolucion.DIY)
                .urgencia(Urgencia.MEDIA)
                .costoEstimadoMin(0.0)
                .costoEstimadoMax(8000.0)
                .tiempoEstimado(5)
                .instruccionesDiy(Arrays.asList(
                    "1. Retirar el plato giratorio",
                    "2. Verificar que el eje central gire libremente",
                    "3. Limpiar el eje y la base del plato",
                    "4. Colocar el plato correctamente centrado",
                    "5. Debe girar suavemente sin trabarse",
                    "6. Probar con un vaso de agua"
                ))
                .repuestosProbables(Arrays.asList("Plato giratorio (si está roto)"))
                .generarOrdenTrabajo(false)
                .build();
        }

        // Rama 3: NO había metal y plato OK → PROBLEMA SERIO
        if (Boolean.FALSE.equals(respuestas.get("m_hc_p1")) &&
            Boolean.TRUE.equals(respuestas.get("m_hc_p2")) {

            return Diagnostico.builder()
                .causaProbable("Mica protectora perforada o magnetrón defectuoso")
                .probabilidad(85)
                .componenteAfectado("Mica protectora / Magnetrón")
                .requiereTecnico(true)
                .tipoSolucion(TipoSolucion.TECNICO_COMPLEJO)
                .urgencia(Urgencia.CRITICA)
                .costoEstimadoMin(25000.0)
                .costoEstimadoMax(80000.0)
                .tiempoEstimado(90)
                .repuestosProbables(Arrays.asList("Mica protectora", "Magnetrón"))
                .alertasSeguridad(Arrays.asList(
                    "🚨 NO USAR EL MICROONDAS hasta que sea revisado por un técnico",
                    "🚨 Las chispas internas pueden causar incendio",
                    "🚨 Desenchufar el microondas inmediatamente",
                    "🚨 El magnetrón defectuoso puede emitir radiación peligrosa"
                ))
                .mensajesCliente(Arrays.asList(
                    "⚠️ POR SEGURIDAD: No usar el microondas",
                    "La mica protectora evita que las ondas dañen el magnetrón",
                    "Si está perforada, se requiere reemplazo urgente",
                    "Técnico especializado visitará en 24hs"
                ))
                .generarOrdenTrabajo(true)
                .prioridadOT("critica")
                .build();
        }

        // Caso por defecto: SIEMPRE crítico
        return Diagnostico.builder()
            .causaProbable("Requiere revisión técnica urgente por seguridad")
            .probabilidad(70)
            .componenteAfectado("Sistema de microondas")
            .requiereTecnico(true)
            .tipoSolucion(TipoSolucion.TECNICO_COMPLEJO)
            .urgencia(Urgencia.CRITICA)
            .costoEstimadoMin(20000.0)
            .costoEstimadoMax(70000.0)
            .tiempoEstimado(90)
            .alertasSeguridad(Arrays.asList(
                "🚨 NO USAR el microondas hasta revisión técnica",
                "🚨 Desenchufar inmediatamente"
            ))
            .mensajesCliente(Arrays.asList(
                "Por seguridad, se requiere revisión técnica urgente"
            ))
            .generarOrdenTrabajo(true)
            .prioridadOT("critica")
            .build();
    }

    @Override
    public int getPrioridad() {
        return 200; // MÁXIMA PRIORIDAD - SEGURIDAD
    }

    @Override
    public String getPreguntaIdString(Long preguntaIdNumerico) {
        // Mapeo de ID numérico a ID string
        switch (preguntaIdNumerico.intValue()) {
            case 20: return "m_hc_p1";
            case 21: return "m_hc_p2";
            default: return "m_hc_p" + preguntaIdNumerico;
        }
    }
}

