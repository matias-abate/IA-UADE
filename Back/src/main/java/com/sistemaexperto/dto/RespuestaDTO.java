package com.sistemaexperto.dto;

import lombok.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class RespuestaDTO {
    private Long preguntaId;
    private String valor;
}
