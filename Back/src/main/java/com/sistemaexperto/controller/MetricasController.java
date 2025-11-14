package com.sistemaexperto.controller;

import com.sistemaexperto.dto.MetricasDTO;
import com.sistemaexperto.model.Caso;
import com.sistemaexperto.model.enums.EstadoCaso;
import com.sistemaexperto.service.CasoService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/api/metricas")
@CrossOrigin(origins = "*")
public class MetricasController {
    
    @Autowired
    private CasoService casoService;
    
    @GetMapping
    public ResponseEntity<MetricasDTO> getMetricas() {
        List<Caso> casosHoy = casoService.findByFecha(LocalDate.now());
        
        long total = casosHoy.size();
        long diyExitosos = casosHoy.stream()
            .filter(c -> c.getEstado() == EstadoCaso.RESUELTO_DIY)
            .count();
        long tecnicoEnviados = casosHoy.stream()
            .filter(c -> c.getEstado() == EstadoCaso.REQUIERE_TECNICO)
            .count();
        
        MetricasDTO metricas = new MetricasDTO();
        metricas.setCasosTotales(total);
        metricas.setDiyExitosos(diyExitosos);
        metricas.setTecnicoEnviados(tecnicoEnviados);
        metricas.setTiempoPromedio(4.2);
        
        return ResponseEntity.ok(metricas);
    }
}
