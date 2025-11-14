package com.sistemaexperto.service;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.Resource;
import org.springframework.core.io.ResourceLoader;
import org.springframework.stereotype.Service;

import java.io.*;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.*;
import java.util.concurrent.TimeUnit;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Servicio para interactuar con CLIPS
 * Usa CLIPS como proceso externo vía CLI
 */
@Slf4j
@Service
public class ClipsService {
    
    private final ResourceLoader resourceLoader;
    
    @Value("${clips.enabled:true}")
    private boolean clipsEnabled;
    
    @Value("${clips.command:clips}")
    private String clipsCommand;
    
    @Value("${clips.timeout.seconds:30}")
    private int timeoutSeconds;
    
    private static final Pattern FACT_PATTERN = Pattern.compile(
        "\\(([a-z-]+)\\s+(.*?)\\)", Pattern.DOTALL
    );
    
    public ClipsService(ResourceLoader resourceLoader) {
        this.resourceLoader = resourceLoader;
    }
    
    /**
     * Inicializa el motor CLIPS y carga todas las reglas
     */
    public void inicializarMotor() throws IOException {
        if (!clipsEnabled) {
            log.warn("CLIPS está deshabilitado");
            return;
        }
        
        log.info("Inicializando motor CLIPS...");
        
        // Verificar que CLIPS esté disponible
        if (!verificarClipsDisponible()) {
            log.error("CLIPS no está disponible en el sistema. Usando fallback a Java.");
            return;
        }
        
        // Cargar archivos de reglas
        cargarArchivo("classpath:clips/templates.clp");
        cargarArchivo("classpath:clips/heladera.clp");
        cargarArchivo("classpath:clips/lavarropas.clp");
        cargarArchivo("classpath:clips/microondas.clp");
        cargarArchivo("classpath:clips/seguridad.clp");
        
        log.info("Motor CLIPS inicializado correctamente");
    }
    
    /**
     * Verifica si CLIPS está disponible en el sistema
     */
    private boolean verificarClipsDisponible() {
        try {
            Process process = new ProcessBuilder(clipsCommand, "-v")
                .redirectErrorStream(true)
                .start();
            
            boolean finished = process.waitFor(5, TimeUnit.SECONDS);
            if (!finished) {
                process.destroyForcibly();
                return false;
            }
            
            return process.exitValue() == 0;
        } catch (Exception e) {
            log.debug("CLIPS no disponible: {}", e.getMessage());
            return false;
        }
    }
    
    /**
     * Carga un archivo .clp en el motor CLIPS
     */
    public void cargarArchivo(String rutaArchivo) throws IOException {
        if (!clipsEnabled) {
            return;
        }
        
        Resource resource = resourceLoader.getResource(rutaArchivo);
        if (!resource.exists()) {
            log.warn("Archivo CLIPS no encontrado: {}", rutaArchivo);
            return;
        }
        
        log.debug("Cargando archivo CLIPS: {}", rutaArchivo);
        // En una implementación real, esto cargaría el archivo en CLIPS
        // Por ahora solo logueamos
    }
    
    /**
     * Ejecuta inferencia con hechos dados y retorna resultados
     */
    public Map<String, Object> ejecutarInferencia(List<String> hechos) throws IOException, InterruptedException {
        if (!clipsEnabled) {
            throw new IllegalStateException("CLIPS está deshabilitado");
        }
        
        // Crear script temporal CLIPS
        Path scriptFile = Files.createTempFile("clips_", ".clp");
        Path outputFile = Files.createTempFile("clips_output_", ".txt");
        
        try {
            // Escribir script CLIPS
            try (PrintWriter writer = new PrintWriter(new FileWriter(scriptFile.toFile()))) {
                // Cargar templates
                writer.println("(load \"templates.clp\")");
                
                // Insertar hechos
                for (String hecho : hechos) {
                    writer.println("(assert " + hecho + ")");
                }
                
                // Ejecutar inferencia
                writer.println("(run)");
                
                // Obtener hechos de diagnóstico
                writer.println("(printout t \"DIAGNOSTICOS:\" crlf)");
                writer.println("(facts)");
                
                // Salir
                writer.println("(exit)");
            }
            
            // Ejecutar CLIPS
            ProcessBuilder pb = new ProcessBuilder(
                clipsCommand,
                "-f", scriptFile.toString()
            );
            
            pb.redirectOutput(outputFile.toFile());
            pb.redirectErrorStream(true);
            
            Process process = pb.start();
            boolean finished = process.waitFor(timeoutSeconds, TimeUnit.SECONDS);
            
            if (!finished) {
                process.destroyForcibly();
                throw new RuntimeException("CLIPS timeout después de " + timeoutSeconds + " segundos");
            }
            
            if (process.exitValue() != 0) {
                String error = new String(Files.readAllBytes(outputFile));
                throw new RuntimeException("Error ejecutando CLIPS: " + error);
            }
            
            // Leer resultados
            return parsearResultados(outputFile);
            
        } finally {
            // Limpiar archivos temporales
            Files.deleteIfExists(scriptFile);
            Files.deleteIfExists(outputFile);
        }
    }
    
    /**
     * Parsea los resultados de CLIPS
     */
    private Map<String, Object> parsearResultados(Path outputFile) throws IOException {
        Map<String, Object> resultados = new HashMap<>();
        String contenido = new String(Files.readAllBytes(outputFile));
        
        // Buscar hechos de diagnóstico, decisión, solución, etc.
        Matcher matcher = FACT_PATTERN.matcher(contenido);
        
        while (matcher.find()) {
            String tipo = matcher.group(1);
            String contenidoHecho = matcher.group(2);
            
            Map<String, Object> hecho = parsearHecho(tipo, contenidoHecho);
            resultados.put(tipo, hecho);
        }
        
        return resultados;
    }
    
    /**
     * Parsea un hecho individual
     */
    private Map<String, Object> parsearHecho(String tipo, String contenido) {
        Map<String, Object> hecho = new HashMap<>();
        
        // Extraer slots del hecho
        Pattern slotPattern = Pattern.compile("\\(([a-z-]+)\\s+([^)]+)\\)");
        Matcher slotMatcher = slotPattern.matcher(contenido);
        
        while (slotMatcher.find()) {
            String slot = slotMatcher.group(1);
            String valor = slotMatcher.group(2).trim();
            
            // Limpiar comillas
            if (valor.startsWith("\"") && valor.endsWith("\"")) {
                valor = valor.substring(1, valor.length() - 1);
            }
            
            // Convertir tipos
            Object valorConvertido = convertirValor(valor);
            hecho.put(slot, valorConvertido);
        }
        
        return hecho;
    }
    
    /**
     * Convierte string a tipo apropiado
     */
    private Object convertirValor(String valor) {
        // Intentar como número
        try {
            if (valor.contains(".")) {
                return Double.parseDouble(valor);
            } else {
                return Integer.parseInt(valor);
            }
        } catch (NumberFormatException e) {
            // Es string
            return valor;
        }
    }
    
    /**
     * Limpia la base de hechos (reset)
     */
    public void limpiarBaseHechos() {
        // En implementación real, ejecutaría (clear) en CLIPS
        log.debug("Limpiando base de hechos CLIPS");
    }
    
    /**
     * Verifica si CLIPS está habilitado y disponible
     */
    public boolean isClipsDisponible() {
        return clipsEnabled && verificarClipsDisponible();
    }
}

