package com.sistemaexperto.service.mapper;

import com.sistemaexperto.model.*;
import com.sistemaexperto.model.enums.EstadoCaso;
import com.sistemaexperto.model.enums.TipoElectrodomestico;
import org.springframework.stereotype.Component;

import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * Mapper para convertir entre objetos Java y hechos CLIPS
 */
@Component
public class ClipsMapper {
    
    private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd");
    
    /**
     * Convierte un Caso Java a string de hechos CLIPS
     */
    public String casoToClipsFact(Caso caso) {
        String estado = mapearEstado(caso.getEstado());
        String fecha = caso.getFechaCreacion() != null 
            ? caso.getFechaCreacion().format(DATE_FORMATTER)
            : "2025-01-01";
        
        return String.format(
            "(caso (id %d) (fecha \"%s\") (cliente \"%s\") " +
            "(telefono \"%s\") (direccion \"\") (estado %s))",
            caso.getId(),
            fecha,
            escapeString(caso.getClienteNombre() != null ? caso.getClienteNombre() : ""),
            escapeString(caso.getClienteTelefono() != null ? caso.getClienteTelefono() : ""),
            estado
        );
    }
    
    /**
     * Convierte electrodoméstico a hecho CLIPS
     */
    public String electrodomesticoToClipsFact(Caso caso) {
        String tipo = mapearTipoElectrodomestico(caso.getTipoElectrodomestico());
        String enGarantia = "no"; // Por defecto, se puede mejorar
        
        return String.format(
            "(electrodomestico (tipo %s) (marca \"%s\") (modelo \"%s\") " +
            "(antiguedad %d) (en-garantia %s))",
            tipo,
            escapeString(caso.getMarca() != null ? caso.getMarca() : ""),
            escapeString(caso.getModelo() != null ? caso.getModelo() : ""),
            caso.getAntiguedad() != null ? caso.getAntiguedad() : 0,
            enGarantia
        );
    }
    
    /**
     * Convierte síntoma a hecho CLIPS
     */
    public String sintomaToClipsFact(Caso caso) {
        String gravedad = "media"; // Por defecto
        if (caso.getSintomaReportado() != null) {
            String sintoma = caso.getSintomaReportado().toLowerCase();
            if (sintoma.contains("chispas") || sintoma.contains("incendio")) {
                gravedad = "critica";
            } else if (sintoma.contains("no enfría") || sintoma.contains("no funciona")) {
                gravedad = "alta";
            }
        }
        
        return String.format(
            "(sintoma (caso-id %d) (descripcion \"%s\") (gravedad %s))",
            caso.getId(),
            escapeString(caso.getSintomaReportado() != null ? caso.getSintomaReportado() : ""),
            gravedad
        );
    }
    
    /**
     * Convierte respuestas a hechos CLIPS
     */
    public List<String> respuestasToClipsFacts(List<Respuesta> respuestas) {
        return respuestas.stream()
            .map(this::respuestaToClipsFact)
            .collect(Collectors.toList());
    }
    
    /**
     * Convierte una respuesta a hecho CLIPS
     */
    public String respuestaToClipsFact(Respuesta respuesta) {
        String valor = convertirValorRespuesta(respuesta.getValor());
        String preguntaId = respuesta.getPreguntaId() != null 
            ? respuesta.getPreguntaId().toString()
            : "0";
        
        return String.format(
            "(respuesta (caso-id %d) (pregunta \"%s\") (valor %s))",
            respuesta.getCaso().getId(),
            preguntaId,
            valor
        );
    }
    
    /**
     * Convierte hechos CLIPS a Diagnostico Java
     */
    public Diagnostico clipsFactsToDiagnostico(Long casoId, Map<String, Object> hechos) {
        Diagnostico.DiagnosticoBuilder builder = Diagnostico.builder();
        
        // Extraer diagnóstico
        if (hechos.containsKey("diagnostico")) {
            Map<String, Object> diag = (Map<String, Object>) hechos.get("diagnostico");
            builder.causaProbable((String) diag.get("causa-probable"));
            builder.probabilidad(((Number) diag.get("probabilidad")).intValue());
            builder.componenteAfectado((String) diag.get("componente-afectado"));
        }
        
        // Extraer decisión
        if (hechos.containsKey("decision")) {
            Map<String, Object> decision = (Map<String, Object>) hechos.get("decision");
            builder.requiereTecnico("si".equals(decision.get("requiere-tecnico")));
            builder.tipoSolucion(mapearTipoSolucion((String) decision.get("tipo")));
            builder.urgencia(mapearUrgencia((String) decision.get("urgencia")));
        }
        
        // Extraer solución
        if (hechos.containsKey("solucion")) {
            Map<String, Object> solucion = (Map<String, Object>) hechos.get("solucion");
            builder.tiempoEstimado(((Number) solucion.get("tiempo-estimado")).intValue());
            builder.costoEstimadoMax(((Number) solucion.get("costo-estimado")).doubleValue());
            builder.costoEstimadoMin(0.0);
            
            String pasos = (String) solucion.get("pasos");
            if (pasos != null) {
                builder.instruccionesDiy(List.of(pasos.split("\\|")));
            }
        }
        
        // Extraer orden de trabajo
        if (hechos.containsKey("orden-trabajo")) {
            Map<String, Object> ot = (Map<String, Object>) hechos.get("orden-trabajo");
            builder.generarOrdenTrabajo(true);
            builder.prioridadOT((String) ot.get("prioridad"));
            
            String repuestos = (String) ot.get("repuestos-probables");
            if (repuestos != null) {
                builder.repuestosProbables(List.of(repuestos.split(",")));
            }
        }
        
        return builder.build();
    }
    
    // Métodos auxiliares de mapeo
    
    private String mapearEstado(EstadoCaso estado) {
        if (estado == null) return "en-diagnostico";
        return switch (estado) {
            case EN_DIAGNOSTICO -> "en-diagnostico";
            case DIAGNOSTICADO -> "en-diagnostico";
            case RESUELTO_DIY -> "resuelto-remoto";
            case REQUIERE_TECNICO -> "requiere-tecnico";
            case CERRADO -> "cerrado";
        };
    }
    
    private String mapearTipoElectrodomestico(TipoElectrodomestico tipo) {
        if (tipo == null) return "heladera";
        return switch (tipo) {
            case HELADERA -> "heladera";
            case LAVARROPAS -> "lavarropas";
            case MICROONDAS -> "microondas";
        };
    }
    
    private String convertirValorRespuesta(String valor) {
        if (valor == null) return "no";
        String val = valor.toLowerCase().trim();
        if (val.equals("sí") || val.equals("si") || val.equals("yes") || val.equals("true") || val.equals("1")) {
            return "si";
        }
        if (val.equals("no") || val.equals("not") || val.equals("false") || val.equals("0")) {
            return "no";
        }
        return val;
    }
    
    private com.sistemaexperto.model.enums.TipoSolucion mapearTipoSolucion(String tipo) {
        if (tipo == null) return com.sistemaexperto.model.enums.TipoSolucion.TECNICO_COMPLEJO;
        return switch (tipo) {
            case "diy" -> com.sistemaexperto.model.enums.TipoSolucion.DIY;
            case "tecnico-simple" -> com.sistemaexperto.model.enums.TipoSolucion.TECNICO_SIMPLE;
            case "tecnico-complejo" -> com.sistemaexperto.model.enums.TipoSolucion.TECNICO_COMPLEJO;
            case "reemplazo" -> com.sistemaexperto.model.enums.TipoSolucion.REEMPLAZO;
            default -> com.sistemaexperto.model.enums.TipoSolucion.TECNICO_COMPLEJO;
        };
    }
    
    private com.sistemaexperto.model.enums.Urgencia mapearUrgencia(String urgencia) {
        if (urgencia == null) return com.sistemaexperto.model.enums.Urgencia.MEDIA;
        return switch (urgencia) {
            case "baja" -> com.sistemaexperto.model.enums.Urgencia.BAJA;
            case "media" -> com.sistemaexperto.model.enums.Urgencia.MEDIA;
            case "alta" -> com.sistemaexperto.model.enums.Urgencia.ALTA;
            case "critica" -> com.sistemaexperto.model.enums.Urgencia.CRITICA;
            default -> com.sistemaexperto.model.enums.Urgencia.MEDIA;
        };
    }
    
    private String escapeString(String str) {
        if (str == null) return "";
        return str.replace("\"", "\\\"").replace("\n", " ").replace("\r", "");
    }
}

