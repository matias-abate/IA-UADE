package com.sistemaexperto.controller;

import com.sistemaexperto.dto.CasoCreateDTO;
import com.sistemaexperto.dto.RespuestaDTO;
import com.sistemaexperto.model.Caso;
import com.sistemaexperto.model.Pregunta;
import com.sistemaexperto.service.CasoService;
import com.sistemaexperto.service.DiagnosticoService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/casos")
@CrossOrigin(origins = "*")
@RequiredArgsConstructor
public class CasoController {

    private final CasoService casoService;
    private final DiagnosticoService diagnosticoService;

    @PostMapping
    public ResponseEntity<Caso> crearCaso(@RequestBody CasoCreateDTO dto) {
        Caso caso = casoService.crearCaso(dto);
        return ResponseEntity.ok(caso);
    }

    @GetMapping
    public ResponseEntity<List<Caso>> listarCasos() {
        return ResponseEntity.ok(casoService.listarTodos());
    }

    @GetMapping("/{id}")
    public ResponseEntity<Caso> obtenerCaso(@PathVariable Long id) {
        return ResponseEntity.ok(casoService.obtenerPorId(id));
    }

    @GetMapping("/{id}/siguiente-pregunta")
    public ResponseEntity<Pregunta> obtenerSiguientePregunta(@PathVariable Long id) {
        Pregunta pregunta = diagnosticoService.obtenerSiguientePregunta(id);
        if (pregunta == null) {
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.ok(pregunta);
    }

    @PostMapping("/{id}/responder")
    public ResponseEntity<Void> responderPregunta(
            @PathVariable Long id,
            @RequestBody RespuestaDTO respuesta) {
        diagnosticoService.procesarRespuesta(id, respuesta);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/{id}/hipotesis")
    public ResponseEntity<List<Map<String, Object>>> obtenerHipotesis(@PathVariable Long id) {
        return ResponseEntity.ok(diagnosticoService.obtenerHipotesisActuales(id));
    }

    @PostMapping("/{id}/finalizar")
    public ResponseEntity<Caso> finalizarDiagnostico(@PathVariable Long id) {
        Caso caso = diagnosticoService.finalizarDiagnostico(id);
        return ResponseEntity.ok(caso);
    }

    @PostMapping("/{id}/diagnosticar")
    public ResponseEntity<Caso> diagnosticar(@PathVariable Long id) {
        // Este endpoint puede ser opcional si prefieres usar el wizard interactivo
        Caso caso = diagnosticoService.finalizarDiagnostico(id);
        return ResponseEntity.ok(caso);
    }
}