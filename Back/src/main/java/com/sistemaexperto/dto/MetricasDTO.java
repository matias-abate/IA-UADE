package com.sistemaexperto.dto;

import lombok.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class MetricasDTO {
    private Long casosTotales;
    private Long diyExitosos;
    private Long tecnicoEnviados;
    private Double tiempoPromedio;
}
