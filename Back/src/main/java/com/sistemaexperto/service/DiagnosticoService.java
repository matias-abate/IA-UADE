package com.sistemaexperto.service;

import com.sistemaexperto.dto.RespuestaDTO;
import com.sistemaexperto.model.Caso;
import com.sistemaexperto.model.Pregunta;
import com.sistemaexperto.model.Respuesta;
import com.sistemaexperto.model.enums.EstadoCaso;
import com.sistemaexperto.repository.CasoRepository;
import com.sistemaexperto.repository.RespuestaRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class DiagnosticoService {

    private final CasoRepository casoRepository;
    private final RespuestaRepository respuestaRepository;
    private final InferenceEngine inferenceEngine;

    @Transactional(readOnly = true)
    public Pregunta obtenerSiguientePregunta(Long casoId) {
        Caso caso = casoRepository.findById(casoId)
                .orElseThrow(() -> new RuntimeException("Caso no encontrado"));

        // Utilizar el motor de inferencia para obtener la siguiente pregunta
        return inferenceEngine.obtenerSiguientePregunta(caso);
    }

    @Transactional
    public void procesarRespuesta(Long casoId, RespuestaDTO respuestaDTO) {
        Caso caso = casoRepository.findById(casoId)
                .orElseThrow(() -> new RuntimeException("Caso no encontrado"));

        Respuesta respuesta = new Respuesta();
        respuesta.setCaso(caso);
        respuesta.setPreguntaId(respuestaDTO.getPreguntaId());
        respuesta.setValor(respuestaDTO.getValor());

        respuestaRepository.save(respuesta);

        // Actualizar el motor de inferencia con la nueva respuesta
        inferenceEngine.procesarRespuesta(caso, respuesta);

        casoRepository.save(caso);
    }

    @Transactional(readOnly = true)
    public List<Map<String, Object>> obtenerHipotesisActuales(Long casoId) {
        Caso caso = casoRepository.findById(casoId)
                .orElseThrow(() -> new RuntimeException("Caso no encontrado"));

        List<Map<String, Object>> hipotesis = new ArrayList<>();

        if (caso.getHipotesis() != null) {
            caso.getHipotesis().forEach(h -> {
                Map<String, Object> hipotesisMap = new HashMap<>();
                hipotesisMap.put("id", h.getId());
                hipotesisMap.put("descripcion", h.getDescripcion());
                hipotesisMap.put("probabilidad", h.getProbabilidad());
                hipotesisMap.put("activa", h.isActiva());
                hipotesis.add(hipotesisMap);
            });
        }

        return hipotesis;
    }

    @Transactional
    public Caso finalizarDiagnostico(Long casoId) {
        Caso caso = casoRepository.findById(casoId)
                .orElseThrow(() -> new RuntimeException("Caso no encontrado"));

        // Realizar el diagnóstico final utilizando el motor de inferencia
        inferenceEngine.realizarDiagnostico(caso);

        caso.setEstado(EstadoCaso.DIAGNOSTICADO);

        return casoRepository.save(caso);
    }
}

